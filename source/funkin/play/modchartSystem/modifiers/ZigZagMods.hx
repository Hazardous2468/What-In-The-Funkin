package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related zig zagging!
// :p
class ZigZagBaseMod extends Modifier
{
  var mult:ModifierSubValue;
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0);
  }

  function ziggyMath(curPos:Float):Float
  {
    var mult:Float = ModConstants.strumSize * mult.value;
    var mm:Float = mult * 2;

    var p:Float = curPos;
    if (p < 0)
    {
      p *= -1;
      p += mult;
    }

    var ppp:Float = p + (mult / 2);
    var funny:Float = (ppp + mult) % mm;
    var result:Float = funny - mult;
    if (ppp % mm * 2 >= mm)
    {
      result *= -1;
    }
    result -= mult / 2;
    return result;
  }

  function mod(a:Float, b:Float):Float
  {
    return (a / b);
  }
}

class ZigZagXMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagYMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagZMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagAngleMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagAngleXMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagAngleYMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += ziggyMath(data.curPos) * currentValue;
  }
}

class ZigZagScaleMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = ziggyMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }
}

class ZigZagScaleXMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = ziggyMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
  }
}

class ZigZagScaleYMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = ziggyMath(data.curPos) * currentValue * 0.01;
    data.scaleY += r;
  }
}

class ZigZagSkewXMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = ziggyMath(data.curPos) * currentValue;
    data.skewX += r;
  }
}

class ZigZagSkewYMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = ziggyMath(data.curPos) * currentValue;
    data.skewY += r;
  }
}

class ZigZagSpeedMod extends ZigZagBaseMod
{
  public function new(name:String)
  {
    super(name);
    modPriority = 401;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    return (ziggyMath(curPos) * currentValue * 0.005) + 1;
  }
}
