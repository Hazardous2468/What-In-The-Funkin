package funkin.play.modchartSystem.modifiers;

import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to beat!

class BeatModBase extends Modifier
{
  var speed:ModifierSubValue;
  var mult:ModifierSubValue;
  var offset:ModifierSubValue;
  var alternate:ModifierSubValue; // if 0.5 or higher, will alternate. otherwise, the beat will always move in one direction (never from side to side)

  // var cap:ModifierSubValue; // By default, the speed gets halved if the BPM is too high. However we don't have this behaviour making this obsolete

  public function new(name:String)
  {
    super(name, 0);
    speed = createSubMod("speed", 1.0, ["frequency"]);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0, ["time_add", "timeadd", "time_offset", "timeoffset"]);
    alternate = createSubMod("alternate", 1.0);
  }

  function beatMath(curPos:Float):Float
  {
    var fAccelTime = 0.2;
    var fTotalTime = 0.5;

    var timmy:Float = (beatTime + offset.value) * speed.value;

    var posMult:Float = mult.value * 2; // Multiplied by 2 to make the effect more pronounced for FNF

    var fBeat = timmy + fAccelTime;
    var bEvenBeat = (Math.floor(fBeat) % 2) != 0;

    if (fBeat < 0) return 0;

    fBeat -= Math.floor(fBeat);
    fBeat += 1;
    fBeat -= Math.floor(fBeat);

    if (fBeat >= fTotalTime) return 0;

    var fAmount:Float;

    if (fBeat < fAccelTime)
    {
      fAmount = FlxMath.remapToRange(fBeat, 0.0, fAccelTime, 0.0, 1.0);
      fAmount *= fAmount;
    }
    else
      /* fBeat < fTotalTime */ {
      fAmount = FlxMath.remapToRange(fBeat, fAccelTime, fTotalTime, 1.0, 0.0);
      fAmount = 1 - (1 - fAmount) * (1 - fAmount);
    }

    if (bEvenBeat && alternate.value >= 0.5) fAmount *= -1;

    var fShift = 20.0 * fAmount * FlxMath.fastSin((curPos * 0.01 * posMult) + (Math.PI / 2.0));
    return fShift * currentValue;
  }
}

class BeatXMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.x += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += beatMath(data.curPos);
  }
}

class BeatYMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.y += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += beatMath(data.curPos);
  }
}

class BeatZMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.z += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += beatMath(data.curPos);
  }
}

class BeatAngleMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleZ -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleZ += beatMath(data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += beatMath(data.curPos);
  }
}

class BeatAngleXMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleX -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleX += beatMath(data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += beatMath(data.curPos);
  }
}

class BeatAngleYMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleY -= beatMath(data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleY += beatMath(data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += beatMath(data.curPos);
  }
}

class BeatScaleMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = beatMath(data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}

class BeatScaleXMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = beatMath(data.curPos);
    data.scaleX += s * 0.01;
  }
}

class BeatScaleYMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = beatMath(data.curPos);
    data.scaleY += s * 0.01;
  }
}

// lmao why not?
class BeatSkewXMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += beatMath(data.curPos);
  }
}

class BeatSkewYMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += beatMath(data.curPos);
  }
}

class BeatSpeedMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 399;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var modWouldBe:Float = beatMath(curPos) * 0.025;
    return modWouldBe + 1;
  }
}
