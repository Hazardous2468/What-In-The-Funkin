package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to tipsy! Includes Tan variant!

class TipsyModBase extends Modifier
{
  var speed:ModifierSubValue;
  var desync:ModifierSubValue;
  var time_add:ModifierSubValue;
  var timertype:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);

    speed = createSubMod("speed", 1.0, ["frequency"]);
    desync = createSubMod("desync", 2.0, ["spacing"]);
    time_add = createSubMod("time_add", 0.0, ["offset", "timeadd", "time_offset", "timeoffset"]);
    timertype = createSubMod("timertype", 0.0);

    unknown = false;
    strumsMod = true;
  }

  function tanTipsyMath(lane:Int, curPos:Float = 0):Float
  {
    var time:Float = (timertype.value >= 0.5 ? (beatTime) : (songTime * 0.001 * 1.2));
    time *= speed.value;
    time += time_add.value;

    return currentValue * (tan((time + (lane) * desync.value) * (5) * 1 * 0.2) * ModConstants.strumSize * 0.4);
  }

  function tipsyMath(lane:Int, curPos:Float = 0):Float
  {
    var time:Float = (timertype.value >= 0.5 ? (beatTime) : (songTime * 0.001 * 1.2));
    time *= speed.value;
    time += time_add.value;

    return currentValue * (cos((time + (lane) * desync.value) * (5) * 1 * 0.2) * ModConstants.strumSize * 0.4);
  }
}

class TipsyXMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tipsyMath(data.direction, data.curPos);
  }
}

class TipsyYMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += tipsyMath(data.direction, data.curPos);
  }
}

class TipsyZMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += tipsyMath(data.direction, data.curPos);
  }
}

class TipsyAngleMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tipsyMath(data.direction, data.curPos);
  }
}

class TipsyScaleMod extends TipsyModBase
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
    final s:Float = tipsyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}

class TipsySkewXMod extends TipsyModBase
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
    final s:Float = tipsyMath(data.direction, data.curPos);
    data.skewX += s;
  }
}

class TipsySkewYMod extends TipsyModBase
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
    final s:Float = tipsyMath(data.direction, data.curPos);
    data.skewY += s;
  }
}

class TanTipsyXMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tanTipsyMath(data.direction, data.curPos);
  }
}

class TanTipsyYMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += tanTipsyMath(data.direction, data.curPos);
  }
}

class TanTipsyZMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += tanTipsyMath(data.direction, data.curPos);
  }
}

class TanTipsyAngleMod extends TipsyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tanTipsyMath(data.direction, data.curPos);
  }
}

class TanTipsyScaleMod extends TipsyModBase
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
    final s:Float = tanTipsyMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}
