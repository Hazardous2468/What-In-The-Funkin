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
      var waveyX_timeMult:Float = speed.value;
      var waveyX_timeAdd:Float = offset.value;
      var waveyX_desync:Float = desync.value;
      returnValue = currentValue * (ModConstants.fastTan((((beatTime + waveyX_timeAdd / Conductor.instance.beatLengthMs) * waveyX_timeMult)
        + (lane * waveyX_desync)) * Math.PI) * ModConstants.strumSize / 2);
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
      var waveyX_timeMult:Float = speed.value;
      var waveyX_timeAdd:Float = offset.value;
      var waveyX_desync:Float = desync.value;
      returnValue = currentValue * (sin((((beatTime + waveyX_timeAdd / Conductor.instance.beatLengthMs) * waveyX_timeMult)
        + (lane * waveyX_desync)) * Math.PI) * ModConstants.strumSize / 2);
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
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += waveyMath(data.direction, data.curPos);
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = waveyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
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
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = waveyMath(data.direction, data.curPos);
    data.skewX += s;
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
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = waveyMath(data.direction, data.curPos);
    data.skewY += s;
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
    pathMod = true;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = waveyMath(data.direction, data.curPos);
    data.skewX += s;
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
    pathMod = true;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = waveyMath(data.direction, data.curPos);
    data.skewY += s;
  }
}

class TanWaveyXMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tanWaveyMath(data.direction, data.curPos);
  }
}

class TanWaveyYMod extends WaveyModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
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
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
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
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tanWaveyMath(data.direction, data.curPos);
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = tanWaveyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = tanWaveyMath(data.direction, data.curPos);
    data.skewX += s;
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
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var s:Float = tanWaveyMath(data.direction, data.curPos);
    data.skewY += s;
  }
}
