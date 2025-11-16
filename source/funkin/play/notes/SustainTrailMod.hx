package funkin.play.notes;

import funkin.play.notes.notestyle.NoteStyle;
import funkin.data.song.SongData.SongNoteData;
import funkin.mobile.ui.FunkinHitbox.FunkinHitboxControlSchemes;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.data.song.SongData.SongNoteData;
import funkin.graphics.FunkinSprite;
import funkin.graphics.ZSprite;
import funkin.graphics.shaders.HSVNotesShader;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.ModHandler;
import funkin.play.modchartSystem.NoteData;
import funkin.play.notes.StrumlineNote;
import funkin.play.notes.notestyle.NoteStyle;
import funkin.ui.options.PreferencesMenu;
import lime.math.Vector2;
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;

/**
 * **[MAJOR WORK IN PROGRESS]**
 *
 * An edited version of SustainTrail to support modchart maths, allowing them to bend and transform in 3D space to match notes.
 *
 * Works by acting as a group of mini sustain trails that are all rendered together as a group to form a big sustain strip.
 * With the pieces being recycled from the parent Strumline
 * Keep in mind this is developed as downscroll so any comments like "the bottom of the hold" would be the top for upscroll
 * @author Hazard24
 */
class SustainTrailMod extends SustainTrail // Extend from SustainTrail for all the sustainTrail logic.
{
  // A variable containing information relating to the root / base of this sustain.
  // May be changed in future to instead use this sprites variables instead.
  public var rootData:SustainTrailRootPieceData = new SustainTrailRootPieceData();

  // An effect that vibrates every point in the sustain.
  public var vibrateEffect:Float = 0.0;

  // Set to true to treat this SustainTrail like an arrowpath.
  public var isArrowPath:Bool = false;

  // The strumNote this hold is tied to.
  public var whichStrumNote:StrumlineNote;

  // The grain (detail) of this sustain piece. Higher grain means less detail and vice versa.
  public var grain(default, set):Float = ModConstants.defaultHoldGrain;

  // A modifier that allows this hold to be rendered straight instead of wavey. Supports negative values (makes it MORE wavey)
  public var straightHolds:Float = 0;

  // A modifier that stretches this hold to make it visually look longer then what it actually is.
  public var longHolds(default, set):Float = 0;

  // A modifier that, when enabled, will rotate the pieces to face the direction of travel.
  public var spiralHolds:Bool = false;

  // A modifier that, when enabled, will prevent the holds going back on themselves, similar to regular holds in NotITG / StepMania.
  public var forwardHolds:Bool = false;

  // If enabled, each vertex will be projected in 3D space to create the illusion of 3D. Otherwise, will just project the entire sprite as one big piece for z axis movement.
  public var is3D:Bool = true;

  public var cullMode = TriangleCulling.NONE;

  // An array of all the pieces. This array is used to sort the draw order of each piece.
  var susPieces:Array<SustainTrailModPiece> = [];

  public function getPieces():Array<SustainTrailModPiece>
  {
    return susPieces;
  }

  /**
   * Normally you would take noteDirection:NoteDirection, SustainLength:Float, noteStyle:NoteStyle
   * @param noteDirection
   * @param SustainLength Length in milliseconds.
   * @param noteStyle
   */
  public function new(noteDirection:NoteDirection, sustainLength:Float, noteStyle:NoteStyle, isArrowPath:Bool)
  {
    super(noteDirection, sustainLength, noteStyle);
    this.active = true;
    this.shader = hsvShader;
    this.isArrowPath = isArrowPath;
  }

  function set_longHolds(s:Float):Float
  {
    if (this.longHolds == s) return s;
    this.longHolds = s;
    recalculatePiecesArray();
    return this.longHolds;
  }

  function set_grain(s:Float):Float
  {
    if (s < 1.0) s = 1.0;
    if (this.grain == s) return s;
    this.grain = s;
    recalculatePiecesArray();
    return this.grain;
  }

  override function set_fullSustainLength(s:Float):Float
  {
    if (s < 0.0) s = 0.0;
    if (this.fullSustainLength == s) return s;
    this.fullSustainLength = s;
    recalculatePiecesArray();
    return this.fullSustainLength;
  }

  /**
   * Set this to true if you are using a sparrow atlas (for animated holds)
   */
  public var usingSparrow:Bool = false;

  /**
   * If holds are animated with sparrowAtlas, this will determine if each pieces' frame is tied to this animations frame.
   * For this to work, make sure each piece all share the same number of frames (including the end caps)!
   * If false, each piece will animate on their own terms.
   */
  public var sharedAnimFrames:Bool = false;

  override public function setupHoldNoteGraphic(noteStyle:NoteStyle):Void
  {
    usingSparrow = false;
    // Hard coded for now as Animated holds aren't supported by FNF.
    if (StringTools.contains(noteStyle.getHoldNoteAssetPath(), "animated_hold_test"))
    {
      trace("HOLD ANIM TEST ASSET DETECTED!");
      usingSparrow = true;
      sharedAnimFrames = true;
    }
    super.setupHoldNoteGraphic(noteStyle);
    if (usingSparrow && sharedAnimFrames)
    {
      // Here would be the setup for your animation frames IF you're using sharedAnimFrames!
      // this.frames = Paths.getSparrowAtlas(noteStyle.getHoldNoteAssetPath());
      this.frames = Paths.getSparrowAtlas("hold_debug_noteskin/animated_hold_test");
      this.animation.addByPrefix('idle', 'piece', 24, true);
      this.animation.play("idle");
      this.updateAnimation(0);
    }
    for (piece in susPieces)
    {
      checkAndUpdatePieceGraphic(piece);
    }
  }

  // Check this piece to see if it's graphic needs to be updated.
  function checkAndUpdatePieceGraphic(piece:SustainTrailModPiece):Void
  {
    if (piece.noteStyleWITF != this.noteStyleWITF) piece.setupHoldNoteGraphic(noteStyleWITF);
    if (piece.usingSparrow) piece.animation.play(piece.isEnd ? "cap" : "piece");
  }

  // Adds a piece to the array
  function addPiece():Void
  {
    var daPiece = parentStrumline.constructHoldPiece();
    susPieces.push(daPiece);
  }

  /**
   * Removes a piece from the array and kills it, ready to be recycled elsewhere.
   */
  function removePiece():Void
  {
    var daPiece = susPieces.pop();
    if (daPiece == null)
    {
      trace(" uh oh we null");
      return;
    }
    daPiece.kill();
  }

  function recalculatePiecesArray():Void
  {
    if (parentStrumline == null || !this.alive || !this.exists) return;

    var sussy:Float = this.fullSustainLength;
    if (sussy <= 0)
    {
      clearPiecesArray();
      return; // errrr lol, we have nothing
    }

    var _longHolds = this.longHolds;

    if (!isArrowPath && _longHolds != 0)
    {
      var songTime:Float = getSongPos();
      var percentageTillCompletion_part:Float = 0;
      if (songTime >= strumTime) percentageTillCompletion_part = songTime - strumTime;
      if (percentageTillCompletion_part < 0) percentageTillCompletion_part = 0;
      var percentageTillCompletion:Float = percentageTillCompletion_part / sussy;
      percentageTillCompletion = FlxMath.bound(percentageTillCompletion, 0, 1); // clamp
      percentageTillCompletion = 1 - percentageTillCompletion;
      _longHolds *= percentageTillCompletion;
    }

    _longHolds += 1;

    // calculate how many pieces we need using sussy
    var howManyPieces:Int = 2;
    howManyPieces = Math.floor(sussy * _longHolds / grain);

    // Must ALWAYS have one piece.
    if (howManyPieces < 1) howManyPieces = 1;
    howManyPieces += 1; // Add one for the end cap.

    // pieceAdder1(howManyPieces);
    pieceAdder2(howManyPieces);
    validatePieces();
  }

  function pieceAdder2(howMany:Int):Void
  {
    clearPiecesArray();
    for (i in 0...howMany)
    {
      addPiece();
    }
  }

  function pieceAdder1(howMany:Int):Void
  {
    var howManyDif:Int = howMany - susPieces.length;

    // trace("length: " + sussy);
    // trace("long: " + _longHolds);
    // trace("grain: " + grain);
    // trace("TARGET PIECES: " + howMany);
    // trace("TARGET DIF: " + howManyDif);

    // if we do not have the required pieces (the susPieces array length isnt equal )
    // generate the required pieces from the parent strumline using recycling behaviour.
    if (howManyDif > 0)
    {
      for (i in 0...howManyDif)
      {
        addPiece();
      }
    }
    // if we are OVER the required pieces, kill and remove the susPieces that we don't need ready to be recycled elsewhere.
    else if (howManyDif < 0)
    {
      howManyDif *= -1;
      for (i in 0...howManyDif)
      {
        removePiece();
      }
    }
  }

  // Goes through each piece, removing it and killing it at the same time.
  public function clearPiecesArray():Void
  {
    for (i in susPieces)
    {
      i.kill();
    }
    susPieces = [];
    susPieces_sorted1 = [];
  }

  // let go of all the pieces to be reuse elsewhere!
  public override function kill():Void
  {
    super.kill();
    clearPiecesArray();
    validateAttempts = 0;
    rootData.reset();
  }

  var validateAttempts:Int = 0;

  function validatePieces():Void
  {
    var startingTime:Float = this.strumTime;

    var pieceLength:Float = fullSustainLength / (susPieces.length - 1);

    // var bottomHeight:Float = graphic.height * zoom * endOffset;
    // var endCapLength:Float = bottomHeight;

    susPieces_sorted1 = [];

    for (i in 0...susPieces.length)
    {
      var daPiece = susPieces[i];
      if (daPiece == null)
      {
        validateAttempts++;
        if (validateAttempts > 2)
        {
          trace("ERROR: PIECE VALIDATION ERROR!");
          throw "Hold Pieces Validation error!";
        }
        else
        {
          trace("WARNING: PIECE VALIDATION ERROR! Trying again...");
          clearPiecesArray();
          recalculatePiecesArray();
        }
        return;
      }
      if (!daPiece.alive)
      {
        trace(" uh oh not alive");
        daPiece.revive();
      }
      daPiece.validated = false;
      var curPieceTime:Float = startingTime;
      var curPieceLength:Float = pieceLength;
      curPieceTime += (i * curPieceLength);
      if (i == susPieces.length - 1) // end cap
      {
        curPieceLength = pieceLength * daPiece.bottomClip;
      }

      daPiece.noteDirection = this.noteDirection;
      daPiece.parentStrumline = this.parentStrumline;
      daPiece.noteData = this.noteData;

      daPiece.strumTime = curPieceTime;
      daPiece.fullSustainLength = curPieceLength;
      daPiece.sustainLength = curPieceLength;

      if (daPiece.noteStyleWITF?.id ?? "funkin" != this.noteStyleWITF?.id ?? "funkin") daPiece.setupHoldNoteGraphic(this.noteStyleWITF);

      daPiece.pieceID = i;
      daPiece.parent = this;
      daPiece.isEnd = false;
      daPiece.isRoot = false;
      daPiece.anglePivot = this.anglePivot;
      daPiece.hsvShader.hue = this.hsvShader.hue;
      daPiece.hsvShader.saturation = this.hsvShader.saturation;
      daPiece.hsvShader.value = this.hsvShader.value;

      if (i > 0)
      {
        daPiece.isRoot = false;
        daPiece.previousPiece = susPieces[i - 1];
        if (i == susPieces.length - 1) daPiece.isEnd = true;
      }
      else
      {
        daPiece.isRoot = true;
        daPiece.previousPiece = null;
      }
      checkAndUpdatePieceGraphic(daPiece);
      daPiece.validated = true;
      susPieces_sorted1.push(daPiece);
    }
    validateAttempts = 0;
    this.update(0); // Run the update func to update everything, including updating the verts ready to be drawn.
  }

  public var anglePivot:Vector2 = new Vector2();

  // This now controls how the pieces are laid out and their lengths
  override public function updateClipping(songTime:Float = 0):Void
  {
    // This function controls how the notes get clipped... maybe? idk

    // recalculatePiecesArray();

    for (daPiece in susPieces)
    {
      if (daPiece == null || !daPiece.alive)
      {
        continue;
      }
      // if difference between the top and bottom is 0, then we don't need this piece anymore.
      // if (daPiece?.topNoteModData?.clipped ?? false)
      // {
      // daPiece.kill();
      // susPieces.remove(daPiece);
      // }
    }

    return;
  }

  override public function desaturate():Void
  {
    super.desaturate();
    for (piece in susPieces)
    {
      piece.hsvShader.saturation = 0.2;
    }
  }

  override public function setSaturation(sat:Float):Void
  {
    super.setSaturation(sat);
    for (piece in susPieces)
    {
      piece.hsvShader.saturation = sat;
    }
  }

  override public function setValue(val:Float):Void
  {
    super.setValue(val);
    for (piece in susPieces)
    {
      piece.hsvShader.value = val;
    }
  }

  override public function setHue(hue:Float):Void
  {
    super.setHue(hue);
    for (piece in susPieces)
    {
      piece.hsvShader.hue = hue;
    }
  }

  // A copy of the susPieces array, but sorted by the piece index. This is to ensure when updating the clipping, we start from bottom to top.
  // Done as the original array will be sorted by z
  var susPieces_sorted1:Array<SustainTrailModPiece> = [];

  // Call this function to update all the verts of each piece, stitch them all together, then sort the pieces by their z value.
  public function updatePieces():Void
  {
    for (piece in susPieces_sorted1)
    {
      piece.updateClipAndStitch();
    }
  }

  override function update(elapsed):Void
  {
    super.update(elapsed);
    updatePieces();
  }

  override public function draw():Void
  {
    return; // Do nothing. as the drawing logic is handled elsewhere. We only exist to manage all the data between each piece.
  }

  /**
   * A function that will clamp the provided strumTime based on the current status of this hold
   * (such as limiting it to the current song position if currently being hit)
   * @param strumTime the strumTime of this 'fake note' to sample at.
   * @return The updated, clamped strumTime.
   */
  function clipTime(strumTime:Float, pieceModData:NoteData):Float
  {
    // Note is currently being hit!
    if ((hitNote && !missedNote))
    {
      var songTime:Float = getSongPos();
      if (strumTime < songTime)
      {
        pieceModData.clipped = songTime - strumTime;
        strumTime = songTime;
      }
      else
      {
        pieceModData.clipped = 0;
      }
    }
    return strumTime;
  }

  public function getSongPos():Float
  {
    return parentStrumline?.conductorInUse?.songPosition ?? Conductor.instance?.songPosition ?? 0;
  }

  public function clearNoteMods():Void
  {
    this.noteModData.clearNoteMods();
  }

  // We only exist for parity sake (and for easy access to note mods)
  var noteModData:NoteData = new NoteData();

  /**
   * Uses the provided noteData and updates it with all the relevant positional data of a note given the parameter strumTime.
   * @param noteModData the noteModData to use and update with the new data.
   * @param strumTime the strumTime of this 'fake note' to sample at.
   * @param isRoot if set to true, will use this noteData information for all the utility information such as grain, straight hold value, etc
   * @return The updated note mod data.
   */
  public function sampleNotePosition(pieceModData:NoteData, strumTime:Float, isRoot:Bool = false, clip:Bool = true):NoteData
  {
    if (whichStrumNote == null)
    { // failsafe
      if (parentStrumline == null) return pieceModData; // fail safe in the fail safe
      whichStrumNote = parentStrumline.getByIndex(noteDirection);
    }

    if (clip) strumTime = clipTime(strumTime, pieceModData);
    else
      pieceModData.clipped = 0;
    strumTime -= whichStrumNote.strumExtraModData?.strumPos ?? 0;
    var notePos:Float = parentStrumline.calculateNoteYPos(strumTime);

    // Some checks to see if this hold is considered 'too far away' to be worth rendering.
    // -: insert code here :-

    // Setting up the noteData
    var mem = pieceModData.clipped;
    pieceModData.defaultValues();
    pieceModData.clipped = mem;
    pieceModData.holdGrain = ModConstants.defaultHoldGrain;
    pieceModData.strumTime = strumTime;
    pieceModData.direction = noteDirection % Strumline.KEY_COUNT;
    pieceModData.curPos_unscaled = notePos;
    pieceModData.whichStrumNote = whichStrumNote;
    pieceModData.noteType = isArrowPath ? "path" : "hold";

    // Setting the scroll speed multiplier.
    var scrollMult:Float = 1.0;
    for (mod in parentStrumline.mods.mods_speed)
    {
      if (mod.targetLane != -1 && pieceModData.direction != mod.targetLane) continue;
      scrollMult *= mod.speedMath(pieceModData.direction, pieceModData.curPos_unscaled, parentStrumline, true);
    }
    for (mod in this.noteModData.noteMods)
    {
      if (mod.targetLane != -1 && pieceModData.direction != mod.targetLane) continue;
      scrollMult *= mod.speedMath(pieceModData.direction, pieceModData.curPos_unscaled, parentStrumline, true);
    }
    pieceModData.speedMod = scrollMult;

    // vanilla sustain positioning
    pieceModData.x = parentStrumline.x;
    pieceModData.x += parentStrumline.getXPos(Strumline.DIRECTIONS[pieceModData.direction]);
    pieceModData.x += Strumline.STRUMLINE_SIZE / 2;
    // pieceModData.x -= this.graphicWidth / 2;

    // Make it follow strum position.
    var defaultPosition:Array<Float> = parentStrumline.mods.getDefaultStrumPos(pieceModData.direction);
    var xDif:Float = whichStrumNote.x - defaultPosition[0];
    pieceModData.x += xDif;

    // Y positioning
    var sillyPos:Float = parentStrumline.calculateNoteYPos(pieceModData.strumTime) * scrollMult;
    pieceModData.y = whichStrumNote.y - Strumline.INITIAL_OFFSET + sillyPos;
    pieceModData.y += Strumline.STRUMLINE_SIZE / 2;
    pieceModData.y -= whichStrumNote.strumExtraModData.noteStyleOffsetY;
    pieceModData.curPos = sillyPos;

    pieceModData.z = whichStrumNote.z;

    if (!parentStrumline.mods.mathCutOffCheck(sillyPos, pieceModData.direction))
    {
      // Apply the mod math
      for (mod in (isArrowPath ? parentStrumline.mods.mods_arrowpath : parentStrumline.mods.mods_notes))
      {
        if (mod.targetLane != -1 && pieceModData.direction != mod.targetLane) continue;
        mod.noteMath(pieceModData, parentStrumline, true, isArrowPath);
      }

      for (mod in this.noteModData.noteMods)
      {
        if (mod.targetLane != -1 && pieceModData.direction != mod.targetLane) continue;
        mod.noteMath(pieceModData, parentStrumline, true, isArrowPath);
      }
    }
    pieceModData.funnyOffMyself();

    pieceModData.scaleX *= pieceModData.scaleX2; // Account for scale2! Don't need to worry about angle... for now?
    pieceModData.scaleY *= pieceModData.scaleY2;

    // apply notestyle offset here for z math reasons
    pieceModData.x -= noteStyleOffsets[0];
    pieceModData.y -= noteStyleOffsets[1];

    // Applying root information
    if (isRoot)
    {
      is3D = (whichStrumNote.strumExtraModData?.threeD ?? false);
      spiralHolds = pieceModData.usingSpiralHolds();
      forwardHolds = pieceModData.usingForwardHolds();
      straightHolds = pieceModData.straightHolds;
      longHolds = pieceModData.longHolds;
      grain = pieceModData.holdGrain;

      rootData.rootX = pieceModData.x;
      rootData.rootY = pieceModData.y;
      rootData.rootScaleX = pieceModData.scaleX;
      rootData.rootScaleY = pieceModData.scaleY;

      anglePivot.x = rootData.rootX;
      anglePivot.y = rootData.rootY;
    }
    else
    {
      // long note / straight hold logic
    }
    return pieceModData;
  }
}

class SustainTrailRootPieceData
{
  // The x,y,z of this root, positioned in the middle (between the two verts)
  public var rootX:Float = 0;
  public var rootY:Float = 0;
  public var rootZ:Float = 0;

  // The angle this piece is facing, used for spiral holds and for hold covers to point the correct direction.
  public var rootAngle:Float = 0;

  public var rootScaleX:Float = 1;
  public var rootScaleY:Float = 1;

  // Call this to reset all values
  public function reset():Void
  {
    rootX = 0;
    rootY = 0;
    rootZ = 0;
    rootAngle = 0;
    rootScaleY = 1;
    rootScaleY = 1;
  }

  public function new()
  {
    reset();
  }
}

// A series of data used to determine how a piece should be rendered.
class SustainTrailModPiece extends SustainTrail // Extend from SustainTrail for all the sustainTrail render logic. (tbf, could probably just make this it's own class later on)
{
  // The modData, defines the position and information about this piece. Is centered on the strum!
  public var bottomNoteModData:NoteData;
  public var topNoteModData:NoteData;

  public var pieceID:Int = 0;

  // Determines if this is the base of the sustain. All subsequent sustain pieces will rely on this pieces' information.
  public var isRoot:Bool = false;

  // Will render with the endcap texture instead of the regular texture.
  public var isEnd:Bool = true;
  public var previousPiece:SustainTrailModPiece = null;

  public var parent:SustainTrailMod;

  // The pivot which this piece will rotate around when this.angle is changed.
  public var anglePivot:Vector2;

  /**
   * The triangles corresponding to the piece
   */
  static final TRIANGLE_VERTEX_INDICES:Array<Int> = [0, 1, 2, 1, 2, 3];

  /**
   * Normally you would take noteDirection:NoteDirection, SustainLength:Float, noteStyle:NoteStyle
   * @param noteDirection
   * @param SustainLength Length in milliseconds.
   * @param noteStyle
   */
  public function new(noteDirection:NoteDirection, sustainLength:Float, noteStyle:NoteStyle)
  {
    super(noteDirection, sustainLength, noteStyle);
    setIndices(TRIANGLE_VERTEX_INDICES);
    topNoteModData = new NoteData();
    bottomNoteModData = new NoteData();
    this.hsvShader.setBool('_isHold', true);
    this.shader = hsvShader;
    this.active = true;
  }

  public function applyPerspective(curVec:Vector3D, curData:NoteData):Vector3D
  {
    curVec.z *= 0.001;
    if (curVec.z == 0 || Math.isNaN(curVec.z)) return curVec; // do fuck all if no z
    else
      return ModConstants.perspectiveMath(curVec, 0, 0, curData.perspectiveOffset);
  }

  /**
   * A function that converts the current noteModData into a 3D point for us to use to position a vert.
   * Note that the noteModData will have the note be positioned already (x being in the center of the strumlineNote)
   * @param leftSide determines whether or not this vert is on the left or right side.
   * @param bottomSide used to determine if this is the top or bottom of the hold. Used for the spiral hold calcs.
   * @return The Vector3D of this verts position, with perspective math already applied
   */
  public function getVertPos(leftSide:Bool, bottomSide:Bool):Vector3D
  {
    if (parent == null) return vec3;
    var curData:NoteData = bottomSide ? bottomNoteModData : topNoteModData;
    leftSide = !leftSide; // flip fix lol

    var holdWidth = this.usingSparrow ? this.frameWidth : graphicWidth;

    vec3.setTo(curData.x, curData.y, curData.z);

    var rotateOrigin:Vector2 = new Vector2(vec3.x, vec3.y);

    // Push left or right half the graphic width.
    vec3.x += holdWidth / 2 * (leftSide ? -1 : 1) * curData.scaleX;

    if (parent.spiralHolds)
    {
      vec3 = applySpiral(vec3, rotateOrigin, curData, bottomSide);
    }

    vec3 = applySkewAndRotation(vec3, rotateOrigin, curData);
    vec3 = applyPerspective(vec3, curData);

    return vec3;
  }

  public function applySkewAndRotation(curVec:Vector3D, rotateOrigin:Vector2, curData:NoteData):Vector3D
  {
    // apply skew
    var xPercent_SkewOffset:Float = curVec.x - rotateOrigin.x;
    if (curData.skewY != 0) curVec.y += xPercent_SkewOffset * Math.tan(curData.skewY * FlxAngle.TO_RAD);

    // Rotate Z
    if (this.angle != 0 && anglePivot != null)
    {
      vec2.setTo(curVec.x, curVec.y);
      var rotateModPivotPoint:Vector2 = new Vector2(anglePivot.x, anglePivot.y);
      vec2 = ModConstants.rotateAround(rotateModPivotPoint, vec2, this.angle);
      curVec.x = vec2.x;
      curVec.y = vec2.y;
    }

    // Rotate Y
    vec2.setTo(curVec.x, curVec.z);
    var rotateModPivotPoint:Vector2 = new Vector2(rotateOrigin.x, curVec.z);
    vec2 = ModConstants.rotateAround(rotateModPivotPoint, vec2, curData.angleY);
    curVec.x = vec2.x;
    curVec.z = vec2.y;

    // Playfield Skewing
    var playfieldSkewOffsetY:Float = curVec.x - (curData.whichStrumNote?.strumExtraModData?.playfieldX ?? FlxG.width / 2);
    var playfieldSkewOffsetX:Float = curVec.y - (curData.whichStrumNote?.strumExtraModData?.playfieldY ?? FlxG.height / 2);

    if (curData.skewX_playfield != 0) curVec.x += playfieldSkewOffsetX * Math.tan(curData.skewX_playfield * FlxAngle.TO_RAD);
    if (curData.skewY_playfield != 0) curVec.y += playfieldSkewOffsetY * Math.tan(curData.skewY_playfield * FlxAngle.TO_RAD);

    return curVec;
  }

  // Takes the current vector and rotates it to face direction of travel...
  public function applySpiral(curVec:Vector3D, rotateOrigin:Vector2, curData:NoteData, bottomSide:Bool):Vector3D
  {
    var prevSample:NoteData;
    if (bottomSide)
    {
      prevSample = this.previousPiece?.topNoteModData ?? null;
    }
    else
    {
      prevSample = this.bottomNoteModData;
    }
    if (prevSample == null)
    {
      /**
       * In this situation, we have two options:
       * We manually simulate a new piece to get accurate data
       * Or for performance, we just reuse the data for the other part.
       */
      prevSample = new NoteData();
      prevSample.strumTime = this.strumTime - this.sustainLength;
      prevSample = parent.sampleNotePosition(prevSample, prevSample.strumTime, false);
      // trace("----------------");
      // trace("root: " + isRoot);
      // trace("our sample x: " + bottomNoteModData.x);
      // trace("custom sample x: " + prevSample.x);
    }

    if (prevSample != null)
    {
      // rotate to face direction of travel

      // calc angle
      var travelAngle:Float = 0;
      var a:Float = (curData.y - prevSample.y) * -1; // height
      var b:Float = (curData.x - prevSample.x); // length

      if (!(a == 0 && b == 0))
      { // if we're NOT in the same spot...
        travelAngle = Math.atan2(b, a);
        lastOrientAngle = travelAngle;
      }
      else
      {
        travelAngle = lastOrientAngle;
      }
      travelAngle = travelAngle * (180 / Math.PI);

      if (travelAngle != 0)
      {
        // apply rot
        vec2.setTo(curVec.x, curVec.y);
        vec2 = ModConstants.rotateAround(rotateOrigin, vec2, travelAngle);
        curVec.x = vec2.x;
        curVec.y = vec2.y;
      }
      parent.rootData.rootAngle = travelAngle;
    }
    return curVec;
  }

  var lastOrientAngle:Float = 0;

  override function update(elapsed):Void
  {
    if (!validated) return;
    if (parent != null)
    {
      if (!parent.sharedAnimFrames && this.usingSparrow)
      {
        super.update(elapsed);
      }
    }
  }

  /**
   * Once set to true, will then allow this piece to be drawn in the draw function.
   * Used to prevent this piece drawing for 1 frame while it's still being set up.
   * Also used to ensure everything is probably initialised before using this piece to avoid any errors.
   */
  public var validated:Bool = false;

  // Some vectors that are reused to avoid creating new ones constantly every frame.
  var vec2:Vector2 = new Vector2();
  var vec3:Vector3D = new Vector3D();

  /**
   * Updates the noteModData to contain the data of where a note would be at the given parameter "strumTime".
   * @param strumTime the strumTime of this 'fake note' to sample at.
   * @param isBottom used with "isRoot" variable to determine whether this sample should be considered the root of the *entire* hold
   */
  public function sampleNotePosition(strumTime:Float = 0, isBottom:Bool = false):Void
  {
    // Check if we are within renderdistance!
    // [ Code here ]

    if (parent == null) return;

    var curData = isBottom ? bottomNoteModData : topNoteModData;
    curData = parent.sampleNotePosition(curData, strumTime, (isBottom && isRoot));
  }

  function updateShaderStuff():Void
  {
    this.hsvShader.setFloat('_bottomStealth', bottomNoteModData.stealth);
    this.hsvShader.setFloat('_bottomAlpha', bottomNoteModData.alpha);
    this.hsvShader.setFloat('_bottomRed', bottomNoteModData.red);
    this.hsvShader.setFloat('_bottomGreen', bottomNoteModData.green);
    this.hsvShader.setFloat('_bottomBlue', bottomNoteModData.blue);
    this.hsvShader.setFloat('_bottomStealthRed', bottomNoteModData.stealthGlowRed);
    this.hsvShader.setFloat('_bottomStealthGreen', bottomNoteModData.stealthGlowGreen);
    this.hsvShader.setFloat('_bottomStealthBlue', bottomNoteModData.stealthGlowBlue);

    this.hsvShader.setFloat('_topStealth', topNoteModData.stealth);
    this.hsvShader.setFloat('_topAlpha', topNoteModData.alpha);
    this.hsvShader.setFloat('_topRed', topNoteModData.red);
    this.hsvShader.setFloat('_topGreen', topNoteModData.green);
    this.hsvShader.setFloat('_topBlue', topNoteModData.blue);
    this.hsvShader.setFloat('_topStealthRed', topNoteModData.stealthGlowRed);
    this.hsvShader.setFloat('_topStealthGreen', topNoteModData.stealthGlowGreen);
    this.hsvShader.setFloat('_topStealthBlue', topNoteModData.stealthGlowBlue);
  }

  /**
   * Updates this pieces' verticies and UV's
   */
  public function updateClipping_mod():Void
  {
    if (!this.alive || bottomNoteModData == null || topNoteModData == null || parent == null) return;

    var verts:Array<Float> = [];

    // First we grab the position of where the bottom two verts should be.
    sampleNotePosition(this.strumTime, true);

    // Apply
    var v = getVertPos(false, true); // Bottom Left
    verts[0 * 2] = v.x;
    verts[0 * 2 + 1] = v.y;

    v = getVertPos(true, true); // Bottom right
    verts[1 * 2] = v.x;
    verts[1 * 2 + 1] = v.y;

    // Grab the position of where the top two verts should be.
    sampleNotePosition(this.strumTime + this.sustainLength, false);

    // Apply
    v = getVertPos(false, false); // Top Left
    verts[2 * 2] = v.x;
    verts[2 * 2 + 1] = v.y;

    v = getVertPos(true, false); // Top Right
    verts[3 * 2] = v.x;
    verts[3 * 2 + 1] = v.y;

    // Set the data!
    setVertices(verts);

    // Set the z to be the average between the bottom and top

    this.z = bottomNoteModData.z + topNoteModData.z / 2;
    var angleMemory = this.angle;
    this.applyNoteData(bottomNoteModData);
    this.x = ModConstants.holdNoteJankX;
    this.y = ModConstants.holdNoteJankY;
    this.angle = angleMemory;
    this.alpha = parentStrumline.alpha;

    updateUV();
    updateShaderStuff();
  }

  override public function updateClipping(songTime:Float = 0):Void
  {
    return; // do nothing!
  }

  function uvFallback():Void
  {
    uv[0 * 2] = 0;
    uv[0 * 2 + 1] = 0;

    uv[1 * 2] = 1;
    uv[1 * 2 + 1] = 0;

    uv[2 * 2] = 0;
    uv[2 * 2 + 1] = 1;

    uv[3 * 2] = 1;
    uv[3 * 2 + 1] = 1;
    setUVTData(uv);
  }

  /**
   * Updates this pieces' uv mapping.
   */
  public function updateUV():Void
  {
    var uv:Array<Float> = [];

    // Do UV's
    // Eventually will make it so that these can be manipulated, as well as making them work properly with clipping.

    var endCapNudge:Float = (isEnd ? (1 / 8) : 0);

    if (this.usingSparrow)
    {
      if (parent?.sharedAnimFrames ?? false)
      {
        // Set the current frame index to the one in parent.
        this.animation.curAnim.curFrame = parent.animation.curAnim.curFrame;
      }
      this.updateAnimation(0);

      var curFrame = this.frame;
      if (curFrame == null)
      {
        uvFallback();
        return;
      }

      // Bottom Left
      uv[0 * 2] = curFrame.uv.x;
      uv[0 * 2 + 1] = curFrame.uv.y;

      // Bottom Right
      uv[1 * 2] = curFrame.uv.width;
      uv[1 * 2 + 1] = uv[0 * 2 + 1];

      // Top left
      uv[2 * 2] = uvtData[0 * 2];
      uv[2 * 2 + 1] = curFrame.uv.height;

      // Top Right
      uv[3 * 2] = uvtData[1 * 2];
      uv[3 * 2 + 1] = uv[2 * 2 + 1];
    }
    else
    {
      // Bottom Left
      uv[0 * 2] = endCapNudge + 1 / 4 * (noteDirection % 4); // 0%/25%/50%/75% of the way through the image
      uv[0 * 2 + 1] = 0;

      // Bottom Right
      uv[1 * 2] = uvtData[0 * 2] + 1 / 8; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left)
      uv[1 * 2 + 1] = uv[0 * 2 + 1];

      // Top left
      uv[2 * 2] = uvtData[0 * 2];
      uv[2 * 2 + 1] = isEnd ? this.bottomClip : 1;
      // Top Right
      uv[3 * 2] = uvtData[1 * 2];
      uv[3 * 2 + 1] = uv[2 * 2 + 1];
    }
    setUVTData(uv);
  }

  public var usingSparrow:Bool = false;

  override public function setupHoldNoteGraphic(noteStyle:NoteStyle):Void
  {
    this.usingSparrow = false;
    // Hard coded for now as Animated holds aren't supported by FNF.
    if (StringTools.contains(noteStyle.getHoldNoteAssetPath(), "animated_hold_test"))
    {
      trace("HOLD ANIM TEST ASSET DETECTED!");
      usingSparrow = true;
    }

    if (usingSparrow)
    {
      // this.frames = Paths.getSparrowAtlas(noteStyle.getHoldNoteAssetPath());
      this.frames = Paths.getSparrowAtlas("hold_debug_noteskin/animated_hold_test");
      lol(noteStyle);
      this.animation.addByPrefix('piece', 'piece', 24, true);
      this.animation.addByPrefix('cap', 'cap', 24, true);
      this.animation.play("piece");
      updateColorTransform();
    }
    else
    {
      super.setupHoldNoteGraphic(noteStyle);
    }
  }

  function lol(noteStyle:NoteStyle):Void
  {
    this.noteStyleWITF = noteStyle;
    antialiasing = true;
    this.isPixel = noteStyle.isHoldNotePixel();
    if (isPixel)
    {
      endOffset = bottomClip = 1;
      antialiasing = false;
    }
    else
    {
      endOffset = 0.5;
      bottomClip = 0.9;
    }
    zoom = 1.0;
    zoom *= noteStyle.fetchHoldNoteScale();

    flipY = Preferences.downscroll #if mobile
    || (Preferences.controlsScheme == FunkinHitboxControlSchemes.Arrows
      && !funkin.mobile.input.ControlsHandler.usingExternalInputDevice) #end;

    alpha = 1.0;
  }

  public var vertices_array:Array<Float> = [];

  override public function setVertices(vertices:Array<Float>):Void
  {
    super.setVertices(vertices);
    this.vertices_array = vertices;
  }

  /**
   * Stiches this pieces' base verts to the previous pieces' end verts.
   */
  public function stichToPrevious():Void
  {
    // stitch
    if (this.previousPiece != null)
    {
      if (this.previousPiece.vertices_array == null || this.vertices_array == null) return; // Can't stich!

      var v_prev:Array<Float> = this.previousPiece.vertices_array;
      var v:Array<Float> = this.vertices_array;

      v[3] = v_prev[v_prev.length - 1];
      v[2] = v_prev[v_prev.length - 2];
      v[1] = v_prev[v_prev.length - 3];
      v[0] = v_prev[v_prev.length - 4];

      setVertices(v);
    }
  }

  public function updateClipAndStitch():Void
  {
    if (!this.alive) return;
    this.updateClipping_mod();
    this.stichToPrevious();
    readyToDraw = true;
  }

  /* Variable that gets set to true once all the verts are ready to be drawn. Set to false when killed.
   * Used to avoid drawing this piece in the potential time between reviving this piece and then updating this piece.
   */
  var readyToDraw:Bool = false;

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (!validated || !readyToDraw || this.parent == null || this.vertices == null || this.indices == null || this.uvtData == null || alpha == 0
      || !this.visible) return;

    if (topNoteModData.clipped > 0 && bottomNoteModData.clipped > 0)
    {
      return;
    }

    var alphaMemory:Float = this.alpha;
    for (camera in parent.cameras)
    {
      var newAlpha:Float = alphaMemory * camera.alpha * parent.parentStrumline?.alpha ?? 1.0;
      this.alpha = newAlpha;
      if (!camera.visible || !camera.exists || newAlpha == 0) continue;

      getScreenPosition(_point, camera).subtractPoint(offset);

      camera.drawTriangles(parent.graphic, this.vertices, this.indices, this.uvtData, null, _point, parent.blend, true, parent.antialiasing,
        parent.colorTransform, this.shader, parent.cullMode);
    }

    // Reset alpha back to what it was to prevent issues.
    this.alpha = alphaMemory;

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  public override function kill():Void
  {
    validated = false;
    readyToDraw = false;
    pieceID = 0;
    isEnd = false;
    isRoot = false;
    previousPiece = null;
    parent = null;
    anglePivot = null;
    if (topNoteModData != null) topNoteModData.clipped = 0;
    if (bottomNoteModData != null) bottomNoteModData.clipped = 0;
    super.kill();
  }

  public override function revive():Void
  {
    pieceID = 0;
    isEnd = false;
    isRoot = false;
    previousPiece = null;
    topNoteModData.clipped = 0;
    bottomNoteModData.clipped = 0;
    readyToDraw = false;
    validated = false;
    super.revive();
  }

  override public function destroy():Void
  {
    validated = false;
    readyToDraw = false;
    topNoteModData = null;
    bottomNoteModData = null;
    super.destroy();
  }
}
