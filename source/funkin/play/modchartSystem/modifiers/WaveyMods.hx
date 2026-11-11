package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to wavey! Includes Tan variant!

class WaveyModBase extends Modifier
{
  var speed:ModifierSubValue;
  var desync:ModifierSubValue;
  var offset:ModifierSubValue;
  var oldMath:ModifierSubValue;
  var timertype:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 77;

    speed = createSubMod("speed", 1.0, ["frequency"]);
    desync = createSubMod("desync", 0.2, ["spacing"]);
    offset = createSubMod("time_add", 0.0, ["offset", "timeadd", "time_offset", "timeoffset"]);
    timertype = createSubMod("timertype", 0.0);
    oldMath = createSubMod("oldmath", 0.0, ["legacy", "old"]);
  }

  function tanWaveyMath(lane:Int, curPos:Float):Float
  {
    var returnValue:Float = 0.0;

    if (oldMath.value >= 0.5)
    {
      final waveyX_timeMult:Float = speed.value;
      final waveyX_timeAdd:Float = offset.value;
      final waveyX_desync:Float = desync.value;
      returnValue = currentValue * (ModConstants.fastTan(
        (((beatTime + waveyX_timeAdd / Conductor.instance.beatLengthMs) * waveyX_timeMult) + (lane * waveyX_desync)) * Math.PI
      ) * ModConstants.strumSize / 2);
    }
    else
    {
      var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
      time *= speed.value;
      time += offset.value;
      returnValue = currentValue * ModConstants.fastTan(time + (lane * desync.value) * Math.PI) * (ModConstants.strumSize / 2);
    }

    return returnValue;
  }

  function waveyMath(lane:Int, curPos:Float):Float
  {
    var returnValue:Float = 0.0;

    if (oldMath.value >= 0.5)
    {
      final waveyX_timeMult:Float = speed.value;
      final waveyX_timeAdd:Float = offset.value;
      final waveyX_desync:Float = desync.value;
      returnValue = currentValue * (sin(
        (((beatTime + waveyX_timeAdd / Conductor.instance.beatLengthMs) * waveyX_timeMult) + (lane * waveyX_desync)) * Math.PI
      ) * ModConstants.strumSize / 2);
    }
    else
    {
      var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
      time *= speed.value;
      time += offset.value;
      returnValue = currentValue * sin(time + (lane * desync.value) * Math.PI) * (ModConstants.strumSize / 2);
    }

    return returnValue;
  }
}

class WaveyXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "WaveyX";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += waveyMath(data.direction, data.curPos);
  }
}

class WaveyYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    displayName = "WaveyY";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += waveyMath(data.direction, data.curPos);
  }
}

class WaveyZMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    displayName = "WaveyZ";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += waveyMath(data.direction, data.curPos);
  }
}

class WaveyAngleMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "WaveyAngle";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += waveyMath(data.direction, data.curPos);
  }
}

class WaveyAngleXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    displayName = "WaveyAngleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += waveyMath(data.direction, data.curPos);
  }
}

class WaveyAngleYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "WaveyAngleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += waveyMath(data.direction, data.curPos);
  }
}

class WaveyScaleMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    displayName = "WaveyScale";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final s:Float = waveyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}

class WaveySkewXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "WaveySkewX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += waveyMath(data.direction, data.curPos);
  }
}

class WaveySkewYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "WaveySkewY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += waveyMath(data.direction, data.curPos);
  }
}

class WaveyScaleXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
    displayName = "WaveyScaleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += waveyMath(data.direction, data.curPos) * 0.01;
  }
}

class WaveyScaleYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
    displayName = "WaveyScaleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += waveyMath(data.direction, data.curPos) * 0.01;
  }
}

class TanWaveyXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "TanWaveyX";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.x += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    displayName = "TanWaveyY";
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.y += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyZMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    displayName = "TanWaveyZ";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.z += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyAngleMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "TanWaveyAngle";
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.angleZ += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyAngleXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "TanWaveyAngleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleX += tanWaveyMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.angleX += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyAngleYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    invertForDad = true;
    displayName = "TanWaveyAngleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleY += tanWaveyMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.angleY += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyScaleMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    displayName = "TanWaveyScale";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    final s:Float = tanWaveyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    final s:Float = tanWaveyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}

class TanWaveyScaleXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    displayName = "TanWaveyScaleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += tanWaveyMath(data.direction, data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.scaleX += tanWaveyMath(data.direction, data.curPos) * 0.01;
  }
}

class TanWaveyScaleYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
    displayName = "TanWaveyScaleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += tanWaveyMath(data.direction, data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.scaleY += tanWaveyMath(data.direction, data.curPos) * 0.01;
  }
}

class TanWaveySkewXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
    displayName = "TanWaveySkewX";
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewX += tanWaveyMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.skewX += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveySkewYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    displayName = "TanWaveySkewY";
    strumsMod = true;
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += tanWaveyMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0) return;
    data.skewY += tanWaveyMath(data.direction, data.curPos);
  }
}
