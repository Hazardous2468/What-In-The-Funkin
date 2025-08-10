package funkin.play.modchartSystem;

import lime.math.Vector2;
import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxSprite;
import funkin.graphics.ZSprite;
import funkin.graphics.FunkinSkewedSprite;
import funkin.play.notes.NoteSprite;
import openfl.geom.Vector3D;
import funkin.play.modchartSystem.modifiers.BaseModifier;

class NoteData
{
  // Which strum receptor is this note targetting?
  public var whichStrumNote:StrumlineNote;

  // note direction
  public var direction:Int = 0;

  // The speed multiplier of the note. Higher means faster speed!
  public var speedMod:Float = 1;

  // Time in the song this note is to be hit at!
  public var strumTime:Float = 0;

  // The distance (in pixels) from receptors, taking into account speedMods.
  public var curPos:Float = 0;

  // The TRUE distance (in pixels) from receptors. Same as Curpos but ignores speed mods.
  public var curPos_unscaled:Float = 0;

  // Position of the strum in terms of curPos. Could be useful later when the strums can follow the notepath in drive2 mod or something lol
  public var strumPosition:Float = 0;

  // The real X position of the note.
  public var x:Float = 0.0;

  // The real Y position of the note.
  public var y:Float = 0.0;

  // The real Z position of the note.
  public var z:Float = 0.0;

  // The stealth glow variable. 1 means fully lit!
  public var stealth:Float = 0;

  // The opacity of the note. 1 is fully visible, 0 is invisible.
  public var alpha:Float = 1;

  // rotation on the z axis (just the default sprite.angle)
  public var angleZ:Float = 0;

  // rotation on the y axis (used for 3D projection thingy)
  public var angleY:Float = 0;

  // rotation on the x axis (used for 3D projection thingy)
  public var angleX:Float = 0;

  // The scale on the x axis
  public var scaleX:Float = 1;

  // The scale on the y axis
  public var scaleY:Float = 1;

  // The scale on the z axis (unused unless 3D models /noteskins are added somehow)
  public var scaleZ:Float = 1;

  // The amount to skew on the x axis
  public var skewX:Float = 0;

  // The amount to skew on the y axis
  public var skewY:Float = 0;

  // The amount to skew on the z axis
  public var skewZ:Float = 0;

  // The amount to skew on the x axis
  public var skewX_playfield:Float = 0;

  // The amount to skew on the y axis
  public var skewY_playfield:Float = 0;

  // The amount to skew on the z axis
  public var skewZ_playfield:Float = 0;

  // offsets for 3D rendering mode:
  public var meshOffsets_SkewX:Float = 0;
  public var meshOffsets_SkewY:Float = 0;
  public var meshOffsets_SkewZ:Float = 0;
  public var meshOffsets_PivotX:Float = 0;
  public var meshOffsets_PivotY:Float = 0;
  public var meshOffsets_PivotZ:Float = 0;

  // The red colour! Is a float value between 0 - 1
  public var red:Float = 1;
  // The green colour! Is a float value between 0 - 1
  public var green:Float = 1;
  // The blue colour! Is a float value between 0 - 1
  public var blue:Float = 1;

  // Value between -180 to 180 which allows you to hueshift the notes with the HSV shader
  public var hueShift:Float = 0;

  public var stealthGlowRed:Float = 1;
  public var stealthGlowGreen:Float = 1;
  public var stealthGlowBlue:Float = 1;

  // Used for orient mod, but could be useful to use?
  public var lastKnownPosition:Vector3D;

  // Sometimes orient mod just has a heart attack and dies.
  // This should make the notes spazz out less in the event that happens. just a bandaid fix for the NaN problem from orient.
  // orient, orientx, orienty, orient2, orientx2, orienty2
  public var lastKnownOrientAngle:Array<Float> = [0, 0, 0, 0, 0, 0];

  public var orient2:Array<Float> = [0, 0, 0];

  // An array of mods which should be done to this note!
  // public var noteMods:Array<String> = [];
  public var noteMods:Array<Modifier> = [];

  // What kind of note is this? Unused for now.
  // Examples: "note", "hurt", "hold", "path", "receptor", "path hold", "my custom note", "roll"
  public var noteType:String = "note";

  // I think these two were for Centered2 mod?
  public var strumPosOffsetThingy:Vector3D;
  public var strumPosWasHere:Vector3D;

  public function new()
  {
    lastKnownPosition = new Vector3D(x, y);
    strumPosOffsetThingy = new Vector3D(0, 0, 0);
    strumPosWasHere = new Vector3D(0, 0, 0);
    defaultValues();
  }

  // Gets the current reverse modifier amount.
  public function getReverse():Float
  {
    if (whichStrumNote?.strumExtraModData == null) return 0;

    var reverseModAmount:Float = whichStrumNote.strumExtraModData.reverseMod + whichStrumNote.strumExtraModData.reverseModLane;
    return reverseModAmount;
  }

  public function clearNoteMods():Void
  {
    noteMods = [];
  }

  var dumbMagicNumberForX:Float = 28;

  public function getNoteXOffset():Float
  {
    // return dumbMagicNumberForX;
    return whichStrumNote.weBelongTo.getNoteXOffset();
  }

  public function getNoteYOffset():Float
  {
    return whichStrumNote.weBelongTo.getNoteYOffset();
    // return Strumline.INITIAL_OFFSET * -1;
  }

  // call this to set the values from an already existing sprite!
  public function setValuesFromSkewSprite(spr:FlxSkewedSprite):Void
  {
    this.x = spr.x;
    this.y = spr.y;

    this.angleZ = spr.angle;
    this.scaleX = spr.scale.x;
    this.scaleY = spr.scale.y;
    this.skewX = spr.skew.x;
    this.skewY = spr.skew.y;
    this.alpha = spr.alpha;
  }

  // call this to set the values from an already existing sprite!
  public function setValuesFromFunkinSkewSprite(spr:FunkinSkewedSprite):Void
  {
    this.x = spr.x;
    this.y = spr.y;

    this.angleZ = spr.angle;
    this.scaleX = spr.scale.x;
    this.scaleY = spr.scale.y;
    this.skewX = spr.skew.x;
    this.skewY = spr.skew.y;
    this.alpha = spr.alpha;
  }

  // call this to set the values from an already existing sprite! FOR ZSPRITE
  public function setValuesFromZSprite(spr:ZSprite):Void
  {
    this.z = spr.z;
    this.stealth = spr.stealthGlow;
    this.stealthGlowBlue = spr.stealthGlowBlue;
    this.stealthGlowGreen = spr.stealthGlowGreen;
    this.stealthGlowRed = spr.stealthGlowRed;
    this.hueShift = spr.hueShift;
    setValuesFromFunkinSkewSprite(spr);
  }

  // call this to set the values from an already existing sprite! FOR NOTES
  public function setValuesFromNoteSprite(noteSpr:NoteSprite):Void
  {
    setValuesFromZSprite(noteSpr);
    this.strumTime = noteSpr.strumTime;
    this.noteType = noteSpr.kind;
    this.direction = noteSpr.direction;
  }

  // Call this function to reset all values back to default!
  public function defaultValues():Void
  {
    speedMod = 1;
    strumPosition = 0;

    noteType = "note";

    x = 0;
    y = 0;
    z = 0;

    angleX = 0;
    angleY = 0;
    angleZ = 0;

    scaleX = 1;
    scaleY = 1;
    scaleZ = 1;

    stealth = 0;
    alpha = 1;

    skewX = 0;
    skewY = 0;
    skewZ = 0;
    skewX_playfield = 0;
    skewY_playfield = 0;
    skewZ_playfield = 0;

    red = 1;
    green = 1;
    blue = 1;

    meshOffsets_PivotX = 0;
    meshOffsets_PivotY = 0;
    meshOffsets_PivotZ = 0;

    meshOffsets_SkewX = 0;
    meshOffsets_SkewY = 0;
    meshOffsets_SkewZ = 0;

    stealthGlowRed = 1;
    stealthGlowGreen = 1;
    stealthGlowBlue = 1;

    strumPosWasHere = new Vector3D(0, 0, 0);
    strumPosOffsetThingy = new Vector3D(0, 0, 0);
  }

  public function setStrumPosWasHere():Void
  {
    strumPosWasHere.x += this.x;
    strumPosWasHere.y += this.y;
    strumPosWasHere.z += this.z;
  }

  public function funnyOffMyself():Void
  {
    this.x += whichStrumNote.noteModData.strumPosOffsetThingy.x;
    this.y += whichStrumNote.noteModData.strumPosOffsetThingy.y;
    this.z += whichStrumNote.noteModData.strumPosOffsetThingy.z;
  }

  public function updateLastKnownPos():Void
  {
    lastKnownPosition.x = x;
    lastKnownPosition.y = y;
    lastKnownPosition.z = z;
  }

  // Used in sampling a mod to figure out what it does if unknown
  public function didValueChange():Bool
  {
    if (x != 0) return true;
    if (y != 0) return true;
    if (z != 0) return true;

    if (angleX != 0) return true;
    if (angleY != 0) return true;
    if (angleZ != 0) return true;

    if (stealth != 1) return true;
    if (alpha != 1) return true;

    if (scaleX != 1) return true;
    if (scaleY != 1) return true;
    if (scaleZ != 1) return true;

    if (skewX != 0) return true;
    if (skewY != 0) return true;
    if (skewZ != 0) return true;

    if (red != 1) return true;
    if (blue != 1) return true;
    if (green != 1) return true;

    if (stealthGlowRed != 1) return true;
    if (stealthGlowBlue != 1) return true;
    if (stealthGlowGreen != 1) return true;

    if (hueShift != 1) return true;

    // All other checks failed, then we know nothing changed and can assume that this mod is useless to use
    return false;
  }
}
