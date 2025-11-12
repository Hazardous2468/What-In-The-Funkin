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

  var useOldStealthGlowStyle:Bool = false;

  // An array of all the pieces. This array is used to sort the draw order of each piece.
  var susPieces:Array<SustainTrailModPiece> = [];

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

  override public function setupHoldNoteGraphic(noteStyle:NoteStyle):Void
  {
    super.setupHoldNoteGraphic(noteStyle);
    for (piece in susPieces)
    {
      if (piece.noteStyleWITF != this.noteStyleWITF) piece.setupHoldNoteGraphic(noteStyle);
    }
  }

  // Adds a piece to the array
  function addPiece():Void
  {
    var daPiece = parentStrumline.mods.constructHoldPiece();
    susPieces.push(daPiece);
  }

  // Removes a piece from the array and kills it, ready to be recycled elsewhere.
  function removePiece():Void
  {
    var daPiece = susPieces.pop();
    daPiece.kill();
  }

  function recalculatePiecesArray():Void
  {
    if (parentStrumline == null) return; // Don't have access to any recycle behaviour yet :(

    var _longHolds = this.longHolds + 1;

    // calculate how many pieces we need using fullSustainLength
    var howManyPieces:Int = 2;
    howManyPieces = Math.floor(fullSustainLength * _longHolds / grain);
    trace("length: " + fullSustainLength);
    trace("long: " + _longHolds);
    trace("grain: " + grain);
    trace("TARGET PIECES: " + howManyPieces);

    // Must ALWAYS have one piece.
    if (howManyPieces < 1) howManyPieces = 1;
    howManyPieces += 1; // Add one for the end cap.

    var howManyDif:Int = howManyPieces - susPieces.length;
    trace("TARGET DIF: " + howManyDif);

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

    validatePieces();
  }

  var validateAttempts:Int = 0;

  function validatePieces()
  {
    var startingTime:Float = this.strumTime;

    var pieceLength:Float = fullSustainLength / (susPieces.length - 1);

    var bottomHeight:Float = graphic.height * zoom * endOffset;
    var endCapLength:Float = bottomHeight * Constants.PIXELS_PER_MS;

    for (i in 0...susPieces.length)
    {
      var daPiece = susPieces[i];
      if (daPiece == null || !daPiece.alive)
      {
        trace("WARNING: PIECE VALIDATION ERROR!");
        validateAttempts++;
        if (validateAttempts > 2)
        {
          throw "Hold Pieces Validation error!";
        }
        recalculatePiecesArray();
        return;
      }

      var pieceTime:Float = startingTime;
      if (i == susPieces.length - 1) // end cap
      {
        pieceTime += ((i - 1) * pieceLength);
        pieceTime += endCapLength;
      }
      else
      {
        pieceTime += (i * pieceLength);
      }

      daPiece.noteDirection = this.noteDirection;
      daPiece.parentStrumline = this.parentStrumline;
      daPiece.noteData = this.noteData;

      daPiece.strumTime = pieceTime;
      daPiece.fullSustainLength = pieceLength;
      daPiece.sustainLength = pieceLength;

      if (daPiece.noteStyleWITF?.id ?? "funkin" != this.noteStyleWITF?.id ?? "funkin") daPiece.setupHoldNoteGraphic(this.noteStyleWITF);

      daPiece.pieceID = i;
      daPiece.parent = this;
      daPiece.isEnd = false;
      daPiece.isRoot = false;
      // daPiece.anglePivot = ???

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
    }
    validateAttempts = 0;
  }

  // This now controls how the pieces are laid out and their lengths
  override public function updateClipping(songTime:Float = 0)
  {
    // This function controls how the notes get clipped... maybe? idk

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

  /**
   * Go through each piece and render it!
   * Note that the pieces CAN be added to the z-sort group in PlayState for z-Sorting purposes, so keep that in mind!
   */
  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    // if (parentStrumline.zSortMode) return;

    // Sort the array so that the sustain piecs closest to the camera are rendered first.
    susPieces.sort(function(a, b) {
      // Sort by piece order
      if (a.pieceID < b.pieceID) return -1;
      else if (a.pieceID > b.pieceID) return 1;
      else
        return 0;
    });

    // Go through each piece and prepare all the verts to ensure they all stich together correctly.
    for (piece in susPieces)
    {
      piece.updateClipAndStitch();
    }

    susPieces.sort(function(a, b) {
      if (a.z < b.z) return -1;
      else if (a.z > b.z) return 1;
      else
      {
        // If z are equal, sort by strumTime instead.
        if (a.strumTime < b.strumTime) return -1;
        else if (a.strumTime > b.strumTime) return 1;
        else
          return 0;
      }
    });

    // Once all prepared, draw each piece, starting from closest to furthest away from camera.
    for (piece in susPieces)
    {
      piece.draw();
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  /**
   * A function that will clamp the provided strumTime based on the current status of this hold
   * (such as limiting it to the current song position if currently being hit)
   * @param strumTime the strumTime of this 'fake note' to sample at.
   * @return The updated, clamped strumTime.
   */
  function clipTime(strumTime:Float):Float
  {
    // Note is currently being hit!
    if ((hitNote && !missedNote))
    {
      var songTime:Float = parentStrumline?.conductorInUse?.songPosition ?? 0;
      if (strumTime < songTime) strumTime = songTime;
    }
    return strumTime;
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
  public function sampleNotePosition(pieceModData:NoteData, strumTime:Float, isRoot:Bool = false):NoteData
  {
    strumTime = clipTime(strumTime);
    strumTime -= whichStrumNote?.strumExtraModData?.strumPos ?? 0;
    var notePos:Float = parentStrumline.calculateNoteYPos(strumTime);

    // Some checks to see if this hold is considered 'too far away' to be worth rendering.
    // -: insert code here :-

    // Setting up the noteData
    pieceModData.defaultValues();
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

    // Setting the x and y and z position of this piece.
    // pieceModData.x = whichStrumNote.x + parentStrumline.mods.getHoldOffsetX(isArrowPath, graphicWidth);
    pieceModData.x = whichStrumNote.x + (ModConstants.strumSize / 2);
    // pieceModData.x += (graphicWidth - Strumline.STRUMLINE_SIZE) / 2; // Center it
    pieceModData.x += graphicWidth / 4; // temp for now!

    var defaultPosition:Array<Float> = parentStrumline.mods.getDefaultStrumPos(pieceModData.direction);
    var xDif:Float = whichStrumNote.x - defaultPosition[0];
    pieceModData.x += xDif;

    var sillyPos:Float = parentStrumline.calculateNoteYPos(pieceModData.strumTime) * scrollMult;
    if (flipY)
    {
      pieceModData.y = (whichStrumNote.y + sillyPos + Strumline.STRUMLINE_SIZE / 2);
    }
    else
    {
      pieceModData.y = (whichStrumNote.y - Strumline.INITIAL_OFFSET + sillyPos + Strumline.STRUMLINE_SIZE / 2);
    }
    pieceModData.y += graphicWidth / 4; // temp for now!

    pieceModData.x -= whichStrumNote.strumExtraModData.noteStyleOffsetX; // undo strum offset
    pieceModData.y -= whichStrumNote.strumExtraModData.noteStyleOffsetY;
    pieceModData.z = whichStrumNote.z;
    pieceModData.curPos = sillyPos;

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
      rootData.rootZ = pieceModData.z;
      rootData.rootScaleX = pieceModData.scaleX;
      rootData.rootScaleY = pieceModData.scaleY;
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

  public function new() {}
}

// A series of data used to determine how a piece should be rendered.
class SustainTrailModPiece extends SustainTrail // Extend from SustainTrail for all the sustainTrail render logic. (tbf, could probably just make this it's own class later on)
{
  // The modData, shared between all the pieces.
  var noteModData:NoteData;

  public var pieceID:Int = 0;

  // Determines if this is the base of the sustain. All subsequent sustain pieces will rely on this pieces' information.
  public var isRoot:Bool = false;

  // Will render with the endcap texture instead of the regular texture.
  public var isEnd:Bool = true;
  public var previousPiece:SustainTrailModPiece = null;

  public var parent:SustainTrailMod;

  // The pivot which this piece will rotate around when this.angle is changed.
  public var anglePivot:Vector2 = new Vector2();

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
    this.active = true;
    noteModData = new NoteData();
    this.hsvShader.setBool('_isHold', true);
    this.shader = hsvShader;
  }

  public function applyPerspective(curVec:Vector3D):Vector3D
  {
    curVec.z *= 0.001;
    if (curVec.z == 0 || Math.isNaN(curVec.z)) return curVec; // do fuck all if no z
    else
      return ModConstants.perspectiveMath(curVec, 0, 0, noteModData.perspectiveOffset);
  }

  /**
   * A function that converts the current noteModData into a 3D point for us to use to position a vert.
   * Note that the noteModData will have the note be positioned already (x being in the center of the strumlineNote)
   * @param leftSide determines whether or not this vert is on the left or right side.
   * @return The Vector3D of this verts position, with perspective math already applied
   */
  public function getVertPos(leftSide:Bool):Vector3D
  {
    var holdWidth = graphicWidth / 2;
    vec3.setTo(noteModData.x, noteModData.y, noteModData.z);

    var rotateOrigin:Vector2 = new Vector2(vec3.x, vec3.y);

    // Push left or right half the graphic width.
    vec3.x += holdWidth / 2 * (leftSide ? -1 : 1) * noteModData.scaleX;

    if (parent.spiralHolds)
    {
      vec3 = applySpiral(vec3, rotateOrigin);
    }

    vec3 = applySkewAndRotation(vec3, rotateOrigin);
    vec3 = applyPerspective(vec3);

    return vec3;
  }

  public function applySkewAndRotation(curVec:Vector3D, rotateOrigin:Vector2):Vector3D
  {
    // apply skew
    // -: update code here :-
    var xPercent_SkewOffset:Float = curVec.x - rotateOrigin.x;
    if (noteModData.skewY != 0) curVec.y += xPercent_SkewOffset * Math.tan(noteModData.skewY * FlxAngle.TO_RAD);

    // Rotate Z
    if (this.angle != 0)
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
    vec2 = ModConstants.rotateAround(rotateModPivotPoint, vec2, noteModData.angleY);
    curVec.x = vec2.x;
    curVec.z = vec2.y;

    // Playfield Skewing
    var playfieldSkewOffset_Y:Float = curVec.x - (noteModData.whichStrumNote?.strumExtraModData?.playfieldX ?? FlxG.width / 2);
    var playfieldSkewOffset_X:Float = curVec.y - (noteModData.whichStrumNote?.strumExtraModData?.playfieldY ?? FlxG.height / 2);

    if (noteModData.skewX_playfield != 0) curVec.x += playfieldSkewOffset_X * Math.tan(noteModData.skewX_playfield * FlxAngle.TO_RAD);
    if (noteModData.skewY_playfield != 0) curVec.y += playfieldSkewOffset_Y * Math.tan(noteModData.skewY_playfield * FlxAngle.TO_RAD);

    return curVec;
  }

  // Takes the current vector and rotates it to face direction of travel...
  public function applySpiral(curVec:Vector3D, rotateOrigin:Vector2):Vector3D
  {
    return curVec;
  }

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
    noteModData = parent.sampleNotePosition(noteModData, strumTime, (isBottom && isRoot));
    updateShaderStuff(isBottom);
    if (isBottom)
    {
      var angleMemory = this.angle;
      this.applyNoteData(noteModData);
      this.x = ModConstants.holdNoteJankX;
      this.y = ModConstants.holdNoteJankY;
      this.angle = angleMemory;
      this.alpha = parentStrumline.alpha;
    }
  }

  function updateShaderStuff(isBottom:Bool):Void
  {
    if (isEnd) isBottom = !isBottom; // Silly fix
    if (isBottom)
    {
      this.hsvShader.setFloat('_bottomStealth', noteModData.stealth);
      this.hsvShader.setFloat('_bottomAlpha', noteModData.alpha);
      this.hsvShader.setFloat('_bottomRed', noteModData.red);
      this.hsvShader.setFloat('_bottomGreen', noteModData.green);
      this.hsvShader.setFloat('_bottomBlue', noteModData.blue);
      this.hsvShader.setFloat('_bottomStealthRed', noteModData.stealthGlowRed);
      this.hsvShader.setFloat('_bottomStealthGreen', noteModData.stealthGlowGreen);
      this.hsvShader.setFloat('_bottomStealthBlue', noteModData.stealthGlowBlue);
    }
    else
    {
      this.hsvShader.setFloat('_topStealth', noteModData.stealth);
      this.hsvShader.setFloat('_topAlpha', noteModData.alpha);
      this.hsvShader.setFloat('_topRed', noteModData.red);
      this.hsvShader.setFloat('_topGreen', noteModData.green);
      this.hsvShader.setFloat('_topBlue', noteModData.blue);
      this.hsvShader.setFloat('_topStealthRed', noteModData.stealthGlowRed);
      this.hsvShader.setFloat('_topStealthGreen', noteModData.stealthGlowGreen);
      this.hsvShader.setFloat('_topStealthBlue', noteModData.stealthGlowBlue);
    }
  }

  /**
   * Updates this pieces' verticies and UV's
   */
  override public function updateClipping(songTime:Float = 0)
  {
    if (noteModData == null || parent == null) return; // Can't continue without it.

    var verts:Array<Float> = [];

    // First we grab the position of where the bottom two verts should be.
    sampleNotePosition(this.strumTime, true);

    // Apply
    var v = getVertPos(false); // Bottom Left
    verts[0 * 2] = v.x;
    verts[0 * 2 + 1] = v.y;

    v = getVertPos(true); // Bottom right
    verts[1 * 2] = v.x;
    verts[1 * 2 + 1] = v.y;

    // Grab the position of where the top two verts should be.
    sampleNotePosition(this.strumTime + this.sustainLength, false);

    // Apply
    v = getVertPos(false); // Top Left
    verts[2 * 2] = v.x;
    verts[2 * 2 + 1] = v.y;

    v = getVertPos(true); // Top Right
    verts[3 * 2] = v.x;
    verts[3 * 2 + 1] = v.y;

    // Set the data!
    setVertices(verts);

    updateUV();
  }

  /**
   * Updates this pieces' uv mapping.
   * Could maybe be updated to support animations similar to zSpriteProjected in the future.
   */
  public function updateUV():Void
  {
    var uv:Array<Float> = [];
    // Do UV's
    // Eventually will make it so that these can be manipulated, as well as making them work properly with clipping.

    var endCapNudge:Float = (isEnd ? (1 / 8) : 0);

    // Bottom Left
    uv[0 * 2] = endCapNudge + 1 / 4 * (noteDirection % 4); // 0%/25%/50%/75% of the way through the image
    uv[0 * 2 + 1] = 0;

    // Bottom Right
    uv[1 * 2] = uvtData[0 * 2] + 1 / 8; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left)
    uv[1 * 2 + 1] = 0;

    // Top left
    uv[2 * 2] = uvtData[0 * 2];
    uv[2 * 2 + 1] = 1;
    // Top Right
    uv[3 * 2] = uvtData[1 * 2];
    uv[3 * 2 + 1] = 1;
    setUVTData(uv);
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
    this.updateClipping();
    this.stichToPrevious();
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (!this.alive) return;

    var alphaMemory:Float = this.alpha;
    for (camera in parent.cameras)
    {
      var newAlpha:Float = alphaMemory * camera.alpha * parent?.parentStrumline?.alpha ?? 1.0;
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

  override public function destroy():Void
  {
    noteModData = null;
    super.destroy();
  }
}
