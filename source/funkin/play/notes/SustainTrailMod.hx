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
 * *An edited version of SustainTrail to support modchart maths, allowing them to bend and transform in 3D space to match notes.*
 *
 * Works by acting as a group of mini sustain trails that are all rendered together as a group to form a big sustain strip.
 * With the pieces being recycled from the parent Strumline.
 * Keep in mind this was developed as downscroll so any comments like "the bottom of the hold" would be the top for upscroll
 *
 * Pros:
 * pieces can be zsorted, allowing holds to go in front and behind each other at the same time.
 * Much cleaner code.
 * Holds can now have their piece visiblity adjusted, no more rendering the entire hold or not at all.
 * More accurate stealth mods: now samples the same data regular notes do, meaning multiple hidden / sudden mods (and custom mods which change stealth) are now supported.
 * Also applies to alpha and color transforms.
 * No more memory leaks with really long, detailed holds.
 * Less intrusive on SustainTrail.hx
 *
 * Though the cons of this system are
 * More unstable at the moment.
 * Possibily much more intensive (way more draw calls could lead to worse performance?)
 * No backwards compatibility planned (e.g old3D holds)
 *
 *
 * TODO:
 * FIX UV / GRAPHICS FLICKERING?!
 * Vibrate Effect (make sure there are no visible gaps!),
 * Long Holds,
 * forwardHolds (improve consistency and maybe math?),
 * spiral holds visual issues at the strum when being clipped (probs use same fix for old sustain logic (tiny time offset))
 * holdCover support (hold covers positioning doesn't work with these new holds as of now),
 * playfield skew mods (inaccurate positions),
 * performance checks (compare performance to old holds to see if it's even worth replacing with this new system),
 *
 * **@author Hazard24**
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
  public var grain:Float = ModConstants.defaultHoldGrain;

  // A modifier that allows this hold to be rendered straight instead of wavey. Supports negative values (makes it MORE wavey)
  public var straightHolds:Float = 0;

  // A modifier that stretches this hold to make it visually look longer then what it actually is.
  public var longHolds:Float = 0;

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
    this.howManyPieces = 0;
    this.active = true;
    this.shader = hsvShader;
    this.isArrowPath = isArrowPath;
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
  function addPiece():SustainTrailModPiece
  {
    var daPiece = parentStrumline.constructHoldPiece();
    susPieces.push(daPiece);
    return daPiece;
  }

  /**
   * Removes a piece from the array and kills it, ready to be recycled elsewhere.
   * Doesn't seem to be very consistent atm
   */
  function removePiece():Void
  {
    var daPiece = susPieces.pop();
    if (daPiece == null)
    {
      trace(" uh oh we null");
      return;
    }
    susPieces_sorted1.remove(daPiece);
    daPiece.kill();
  }

  /**
   * How many pieces this sustain needs.
   * Must always be above 2 (one for base, one for end cap minimum)
   */
  var howManyPieces:Int;

  /**
    * Long hold observations:
    * The long holds modifier in NotITG makes the hold length look longer visually.
    * However as it approaches the receptors, it shrinks.
    * At the receptor, it is normal length.
    * Past the receptor at around -fullSustainLength, the hold shrinks to be 0 length.

   */
  /**
   * some magical shit, idk yet
   * @return Float
   */
  function longHoldMath():Float
  {
    var a:Float = 1;
    if (!isArrowPath && longHolds != 0)
    {
      var curPos:Float = this.strumTime - getSongPos();

      // at curpos = -fullSustainLength, return 0
      // at curpos = 0, normal length, return 1
      // at curpos = fullSustainLength, return 2

      a = FlxMath.remapToRange(curPos, -fullSustainLength, fullSustainLength, 0, 2);
    }
    return a;
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
    clearPiecesArray();
    super.kill();
    rootData.reset();
  }

  // The pivot which we rotate the ENTIRE hold around using this.angle. Is automatically set to the root of the sustain.
  public var anglePivot:Vector2 = new Vector2();

  // This function checks for any pieces that are fully clipped and then kills them, ready to be recycled elsewhere.
  override public function updateClipping(songTime:Float = 0):Void
  {
    if (!clipFromBottom) return;
    for (daPiece in susPieces)
    {
      if (daPiece == null || !daPiece.alive)
      {
        continue;
      }

      // if the top part starts getting clipped, then we assume that the entire thing has been fully clipped and is no longer visible.
      if (daPiece?.topNoteModData?.clipped ?? 0 > 0)
      {
        if (daPiece.isRoot)
        {
          // If we are the root, then we need to define a new root piece before we get killed. Do this by getting the next piece in the sorted array
          if (daPiece.pieceID < susPieces_sorted1.length - 1)
          {
            susPieces_sorted1[daPiece.pieceID + 1].isRoot = true;
            daPiece.isRoot = false;
          }
        }

        daPiece.kill();
        susPieces_sorted1.remove(daPiece);
        susPieces.remove(daPiece);
      }
    }
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

  var susPiecesData:Array<NoteData> = [];

  // If set to false, will instead hold the sustain at the song position when being hit as the sustain length counts down.
  // If set to true, will instead clip the sustain at the bottom and changing sustain length will not do anything.
  var clipFromBottom:Bool = true;

  /**
   * This function is responsible for going through each piece of this sustain,
   * properly setting their noteData's and then updating their verts,
   * stitching them all together to create one seamless sustain strip.
   */
  public function updatePieces():Void
  {
    if (!this.alive || parentStrumline == null) return;

    spiralHolds = false;
    forwardHolds = false;
    is3D = true;

    var needsRecalc:Bool = false;
    var sussy:Float = clipFromBottom ? fullSustainLength : sustainLength;
    if (sussy < 0)
    {
      if (susPieces.length > 0) clearPiecesArray();
      return; // Oh, we... don't have any length. Nothing to render then!
    }

    // Step 1: Calculate the root of the hold to get all the hold meta data like grain or long holds!
    this.noteModData = sampleNotePosition(this.noteModData, this.strumTime, true, true);
    var baseTime:Float = clipFromBottom ? this.strumTime : this.noteModData.strumTime;

    // Step 2: Check if we need to recalculate the pieces array!
    if (grain != noteModData.holdGrain || longHolds != noteModData.longHolds)
    {
      needsRecalc = true;
      clearPiecesArray();
      trace("Recalculate pieces! - meta");
    }

    // Apply the root meta data
    this.is3D = (whichStrumNote?.strumExtraModData?.threeD ?? false);
    this.spiralHolds = noteModData.usingSpiralHolds();
    this.forwardHolds = noteModData.usingForwardHolds();
    this.straightHolds = noteModData.straightHolds;
    this.longHolds = noteModData.longHolds;
    this.grain = noteModData.holdGrain;

    rootData.rootX = noteModData.x;
    rootData.rootY = noteModData.y;
    rootData.rootZ = noteModData.z;
    rootData.rootScaleX = noteModData.scaleX;
    rootData.rootScaleY = noteModData.scaleY;
    anglePivot.x = rootData.rootX;
    anglePivot.y = rootData.rootY;

    susPiecesData = [this.noteModData];

    // long hold math:
    var longBoi:Float = 1;

    var howMany:Int = Math.floor(sussy / grain); // calculate how many pieces we need using sussy
    if (howMany < 1) howMany = 1; // Must ALWAYS have one piece.
    howMany += 1; // Add one for the end cap.

    if ((howMany != this.howManyPieces || susPieces_sorted1.length != howMany) && !needsRecalc)
    {
      needsRecalc = true;
      clearPiecesArray();
      trace('Recalculate pieces! - Different pieces amount ($howMany)');
    }
    this.howManyPieces = howMany;

    // Step 3: Calculate the note data for each step of the sustain!
    for (i in 0...howManyPieces)
    {
      var pieceLength:Float = sussy * longBoi / howManyPieces;
      var curPieceTime:Float = baseTime + (pieceLength * i);

      var daPiece:SustainTrailModPiece;
      if (needsRecalc)
      {
        daPiece = addPiece();
        susPieces_sorted1.push(daPiece);
      }
      else
      {
        daPiece = susPieces_sorted1[i];
        if (!daPiece.alive) continue;
      }

      if (daPiece == null)
      {
        // Something is wrong! Abort everything and try again!
        trace('pieceID "$i" is null! Trying again...');
        this.howManyPieces = 0;
        updatePieces();
        return;
      }

      // Set all the daPiece data here!
      daPiece.noteDirection = this.noteDirection;
      daPiece.parentStrumline = this.parentStrumline;
      daPiece.noteData = this.noteData; // not to be confused with noteModData
      daPiece.pieceID = i;
      daPiece.parent = this;
      daPiece.isEnd = false;
      daPiece.isRoot = false;
      daPiece.anglePivot = this.anglePivot;
      if (i > 0)
      {
        daPiece.isRoot = false;
        daPiece.previousPiece = susPieces[i - 1];
        if (i == susPieces.length - 1)
        {
          daPiece.isEnd = true;
          pieceLength *= daPiece.bottomClip; // adjust length for end cap
        }
      }
      else
      {
        daPiece.isRoot = true;
        daPiece.previousPiece = null;
      }

      // temporarily disabled while I figure out what causes the UV data to be fucked
      if (false)
      {
        daPiece.strumTime = curPieceTime;
        // Clip the time here when being hit so sustainLength is used properly alongside fullSustainLength.
        var clip:Float = 0;
        if ((hitNote && !missedNote))
        {
          var songTime:Float = getSongPos();
          if (songTime >= daPiece.strumTime)
          {
            clip = songTime - daPiece.strumTime;
          }
          if (clip < 0) clip = 0;
          daPiece.strumTime += clip;
        }
        daPiece.sustainLength = pieceLength - clip;
      }

      daPiece.strumTime = curPieceTime;
      daPiece.sustainLength = pieceLength;
      daPiece.fullSustainLength = pieceLength;

      // Check if we need to update the hold graphic
      if (daPiece.noteStyleWITF?.id ?? "funkin" != this.noteStyleWITF?.id ?? "funkin") daPiece.setupHoldNoteGraphic(this.noteStyleWITF);
      daPiece.hsvShader.hue = this.hsvShader.hue;
      daPiece.hsvShader.saturation = this.hsvShader.saturation;
      daPiece.hsvShader.value = this.hsvShader.value;

      // Set the note data for the piece bottom
      if (i == 0)
      {
        daPiece.bottomNoteModData = susPiecesData[0]; // We already calculated the root for all the meta data!
        daPiece.previousPiece = null;
      }
      else
      {
        daPiece.previousPiece = susPieces_sorted1[i - 1];
        if (daPiece.previousPiece != null && daPiece.previousPiece.alive)
        {
          // Re use this note data if available.
          daPiece.bottomNoteModData = daPiece.previousPiece.topNoteModData;
        }
        else
        {
          daPiece.bottomNoteModData = sampleNotePosition(daPiece.bottomNoteModData, daPiece.strumTime, false, true);
        }
        susPiecesData.push(daPiece.bottomNoteModData);
      }

      // Set the note data for the piece top
      var ss:Float = daPiece.strumTime + daPiece.sustainLength;
      daPiece.topNoteModData = sampleNotePosition(daPiece.topNoteModData, ss, false, true);
      susPiecesData.push(daPiece.topNoteModData);
      // if (!daPiece.isEnd) daPiece.nextPiece = susPieces_sorted1[i + 1];
    }

    /**
     * Once all data is in place, we then tell all the pieces to update their verts and stitch it all together to avoid gaps.
     * We *could* do it during the above loop but would rather wait for all the data to be ready
     * so we can look at future or previous pieces with ease if needed (e.g. for spiral holds)
     */
    for (piece in susPieces_sorted1)
    {
      piece.updateClipAndStitch();
      piece.readyToDraw = true;
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

  var tinyOffsetForSpiral:Float = 0.01; // in ms

  /**
   * A function that will clamp the provided strumTime based on the current status of this hold
   * (such as limiting it to the current song position if currently being hit).
   * Will also updated the noteData.clipped variable accordingly.
   * @param pieceModData da data
   */
  function clipTime(pieceModData:NoteData):Void
  {
    // Note is currently being hit!
    if ((hitNote && !missedNote))
    {
      var songTime:Float = getSongPos();
      if (songTime >= pieceModData.strumTime)
      {
        pieceModData.clipped = songTime - pieceModData.strumTime;
      }
      if (pieceModData.clipped < 0) pieceModData.clipped = 0;
      pieceModData.strumTime += pieceModData.clipped;
    }
    else
    {
      pieceModData.clipped = 0;
    }
  }

  /**
   * Gets and returns the current song position.
   * @return Float
   */
  public function getSongPos():Float
  {
    return parentStrumline?.conductorInUse?.songPosition ?? Conductor.instance?.songPosition ?? 0;
  }

  /**
   * Clears any note mods attached to this sustain.
   */
  public function clearNoteMods():Void
  {
    this.noteModData.clearNoteMods();
  }

  // The root data of this hold!
  var noteModData:NoteData = new NoteData();

  /**
   * Uses the provided noteData and updates it with all the relevant positional data of a note given the parameter strumTime.
   * @param pieceModData the noteModData to use and update with the new data.
   * @param strumTime the strumTime of this 'fake note' to sample at.
   * @param isRoot if set to true, will use this noteData information for all the utility information such as grain, straight hold value, etc
   * @param clip whether the strumTime should get clipped by the clipTime function.
   * @return The updated note mod data.
   */
  public function sampleNotePosition(pieceModData:NoteData, daStrumTime:Float, isRoot:Bool = false, clip:Bool = true):NoteData
  {
    if (whichStrumNote == null)
    { // failsafe
      if (parentStrumline == null) return pieceModData; // fail safe in the fail safe
      whichStrumNote = parentStrumline.getByIndex(noteDirection);
    }

    // Setting up the noteData
    pieceModData.defaultValues();
    pieceModData.strumTime = daStrumTime;
    pieceModData.strumTime -= whichStrumNote.strumExtraModData?.strumPos ?? 0;
    if (clip) clipTime(pieceModData);
    else
      pieceModData.clipped = 0;

    pieceModData.holdGrain = ModConstants.defaultHoldGrain;
    pieceModData.direction = noteDirection % Strumline.KEY_COUNT;
    pieceModData.whichStrumNote = whichStrumNote;
    pieceModData.noteType = isArrowPath ? "path" : "hold";

    var notePos:Float = parentStrumline.calculateNoteYPos(pieceModData.strumTime);
    pieceModData.curPos_unscaled = notePos;

    // Some checks to see if this hold is considered 'too far away' to be worth rendering before continuing with any more math.
    // -: insert code here :-

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
    if (!isRoot)
    {
      if (forwardHolds) // Prevents holds from going backwards
      {
        // Improve this maybe?
        var previousHoldY:Float = pieceModData.previousData?.y ?? rootData.rootY;

        var flipThingy:Bool = flipY;
        if (noteModData.getReverse() > 0.5)
        {
          flipThingy = !flipThingy;
        }

        if ((flipThingy && pieceModData.y > previousHoldY) || (!flipThingy && pieceModData.y < previousHoldY))
        {
          pieceModData.y = FlxMath.lerp(pieceModData.y, previousHoldY, 1.0);
        }
      }

      if (straightHolds != 0)
      {
        pieceModData.x = FlxMath.lerp(pieceModData.x, rootData.rootX, straightHolds);
        pieceModData.z = FlxMath.lerp(pieceModData.z, rootData.rootZ, straightHolds);
        pieceModData.scaleX = FlxMath.lerp(pieceModData.scaleX, rootData.rootScaleX, straightHolds);
        pieceModData.scaleY = FlxMath.lerp(pieceModData.scaleY, rootData.rootScaleY, straightHolds);
      }
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

/**
 * A sustain piece!
 * All descriptions are based on downscroll! See below for info:
 *
 * Piece visualised:
 *
 * 2 -- 3
 * |    |
 * 0 -- 1
 *
 * 0: bottom left   (using bottomNoteModData)
 * 1: bottom right  (using bottomNoteModData)
 * 2: top left      (using topModData)
 * 3: top right     (using topModData)
 *
 */
class SustainTrailModPiece extends SustainTrail // Extend from SustainTrail for all the sustainTrail render logic. (tbf, could probably just make this it's own class later on)
{
  // The modData, defines the position and information about this piece. Is centered on the strum!
  public var bottomNoteModData:NoteData;
  public var topNoteModData:NoteData;

  public var pieceID(default, set):Int = 0;

  function set_pieceID(i:Int):Int
  {
    this.pieceID = i;
    if (bottomNoteModData != null) bottomNoteModData.pieceID = i;
    if (topNoteModData != null) topNoteModData.pieceID = i;
    return i;
  }

  // Determines if this is the base of the sustain. All subsequent sustain pieces will rely on this pieces' information.
  public var isRoot:Bool = false;

  // Will render with the endcap texture instead of the regular texture.
  public var isEnd:Bool = true;
  public var previousPiece(default, set):SustainTrailModPiece = null;

  function set_previousPiece(pp:SustainTrailModPiece):SustainTrailModPiece
  {
    if (previousPiece == pp) return pp;
    this.previousPiece = pp;
    if (bottomNoteModData != null)
    {
      if (pp != null)
      {
        bottomNoteModData.previousData = pp.topNoteModData;
      }
      else
      {
        bottomNoteModData.previousData = null;
      }
    }
    return this.previousPiece;
  }

  public var parent:SustainTrailMod;

  // The pivot which this piece will rotate around when this.angle is changed.
  public var anglePivot:Vector2;

  /**
   * The triangles corresponding to the piece
   */
  static final TRIANGLE_VERTEX_INDICES:Array<Int> = [2, 1, 0, 1, 2, 3];

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
    readyToDraw = false;
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
    if (parent != null)
    {
      if (!parent.sharedAnimFrames && this.usingSparrow)
      {
        super.update(elapsed);
      }
    }
  }

  // Some vectors that are reused to avoid creating new ones constantly every frame.
  var vec2:Vector2 = new Vector2();
  var vec3:Vector3D = new Vector3D();

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

    // Apply
    var v = getVertPos(false, true); // Bottom Left
    verts[0 * 2] = v.x;
    verts[0 * 2 + 1] = v.y;

    v = getVertPos(true, true); // Bottom right
    verts[1 * 2] = v.x;
    verts[1 * 2 + 1] = v.y;

    // Apply
    v = getVertPos(false, false); // Top Left
    verts[2 * 2] = v.x;
    verts[2 * 2 + 1] = v.y;

    v = getVertPos(true, false); // Top Right
    verts[3 * 2] = v.x;
    verts[3 * 2 + 1] = v.y;

    setIndices(TRIANGLE_VERTEX_INDICES);

    // Set the data!
    setVertices(verts);
    // this.vertices = new DrawData<Float>(verts.length, true, verts);
    // this.vertices_array = verts;

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
    var uv:Array<Float> = [];
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

    if (this.usingSparrow && false)
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

    /*
      for (k in 0...uv.length)
      {
        if (k % 2 == 1)
        { // all y verts
          uv[k] -= 0.5;
          uv[k] *= uvScale.y;
          uv[k] += 0.5;
          uv[k] += uvOffset.y;
        }
        else
        {
          uv[k] -= 0.5; // try to scale from center
          uv[k] *= uvScale.x;
          uv[k] += 0.5;
          uv[k] += uvOffset.x / 4;
        }
    }*/

    // this.uvtData = new DrawData<Float>(uv.length, true, uv);
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
    if (this.previousPiece != null && this.previousPiece.alive)
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
    // this.stichToPrevious();
    readyToDraw = true;
  }

  /* Variable that gets set to true once all the verts are ready to be drawn. Set to false when killed.
   * Used to avoid drawing this piece in the potential time between reviving this piece and then updating this piece.
   */
  public var readyToDraw:Bool = false;

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (!readyToDraw || this.parent == null || this.vertices == null || this.indices == null || this.uvtData == null || alpha == 0 || !this.visible) return;

    if (topNoteModData.clipped > 0 && bottomNoteModData.clipped > 0)
    {
      return;
    }

    var alphaMemory:Float = this.alpha;
    for (camera in parent.cameras)
    {
      var newAlpha:Float = alphaMemory * camera.alpha * parent.alpha * parent.parentStrumline?.alpha ?? 1.0;
      this.alpha = newAlpha;
      if (!camera.visible || !camera.exists || newAlpha == 0) continue;

      getScreenPosition(_point, camera).subtractPoint(offset);

      camera.drawTriangles(parent.graphic, this.vertices, this.indices, this.uvtData, null, _point, parent.blend, true, parent.antialiasing,
        this.colorTransform, this.shader, parent.cullMode);
    }

    // Reset alpha back to what it was to prevent issues.
    this.alpha = alphaMemory;

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  public override function kill():Void
  {
    pieceID = 0;
    isEnd = false;
    isRoot = false;
    previousPiece = null;
    parent = null;
    anglePivot = null;
    readyToDraw = false;

    if (topNoteModData != null)
    {
      topNoteModData.clipped = 0;
      topNoteModData.pieceID = 0;
      topNoteModData.previousData = null;
    }
    if (bottomNoteModData != null)
    {
      bottomNoteModData.clipped = 0;
      bottomNoteModData.pieceID = 0;
      bottomNoteModData.previousData = null;
    }

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
    topNoteModData.previousData = bottomNoteModData;
    bottomNoteModData.previousData = null;
    readyToDraw = false;
    super.revive();
  }

  override public function destroy():Void
  {
    readyToDraw = false;
    topNoteModData = null;
    bottomNoteModData = null;
    super.destroy();
  }
}
