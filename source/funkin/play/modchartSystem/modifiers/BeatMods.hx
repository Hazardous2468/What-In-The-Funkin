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
  var speed:ModifierSubValue; // Controls the speed / frequency of the effect (higher means faster)
  var mult:ModifierSubValue; // Controls the period / size of the effect
  var offset:ModifierSubValue; // The effect time offset (in beats)
  var alternate:ModifierSubValue; // if 0.5 or higher, will alternate. otherwise, the beat will always move in one direction (never from side to side)
  // var cap:ModifierSubValue; // By default, the speed gets halved if the BPM is too high. However we don't have this behaviour making this obsolete
  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
    speed = createSubMod("speed", 1.0, ["frequency"]);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0, ["time_add", "timeadd", "time_offset", "timeoffset"]);
    alternate = createSubMod("alternate", 1.0);
    fAccelTimeSubmod = createSubMod("accel", 0.2);
    fTotalTimeSubmod = createSubMod("total", 0.5);
  }

  // Control the acceleration and modifier timings:
  var fAccelTimeSubmod:ModifierSubValue;
  var fTotalTimeSubmod:ModifierSubValue;

  function beatMath(curPos:Float):Float
  {
    final fAccelTime = fAccelTimeSubmod.value;
    final fTotalTime = fTotalTimeSubmod.value;

    final timmy:Float = (beatTime + offset.value) * speed.value;

    final posMult:Float = mult.value * 2; // Multiplied by 2 to make the effect more pronounced for FNF

    var fBeat = timmy + fAccelTime;
    final bEvenBeat = (Math.floor(fBeat) % 2) != 0;

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

    final fShift = 20.0 * fAmount * FlxMath.fastSin((curPos * 0.01 * posMult) + (Math.PI / 2.0));
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
    data.x -= strumResult[data.direction]; // undo the strum  movement.
    data.x += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.x += strumResult[data.direction];
    }
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
    data.y -= strumResult[data.direction]; // undo the strum  movement.
    data.y += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.y += strumResult[data.direction];
    }
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
    data.z -= strumResult[data.direction]; // undo the strum  movement.
    data.z += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.z += strumResult[data.direction];
    }
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
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction]; // undo the strum  movement.
    data.angleZ += beatMath(data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.angleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleX += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.angleX += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleY += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.angleY += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.inOrientPass || data.noteType == "receptor") return; // skip math if mod is 0
    final s:Float = beatMath(data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleY += s;
    data.scaleZ += s;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.inOrientPass || data.noteType == "receptor") return; // skip math if mod is 0
    data.scaleX += beatMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.inOrientPass || data.noteType == "receptor") return; // skip math if mod is 0
    data.scaleY += beatMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class BeatSkewXMod extends BeatModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.inOrientPass || data.noteType == "receptor") return; // skip math if mod is 0
    data.skewX += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.skewX += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.inOrientPass || data.noteType == "receptor") return; // skip math if mod is 0
    data.skewY += beatMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = beatMath(data.curPos);
      data.skewY += strumResult[data.direction];
    }
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
