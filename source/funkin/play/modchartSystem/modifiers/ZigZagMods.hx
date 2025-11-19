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
  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0);
  }

  function ziggyMath(curPos:Float):Float
  {
    curPos += offset.value * (Preferences.downscroll ? -1 : 1);
    final mult:Float = ModConstants.strumSize * mult.value;
    final mm:Float = mult * 2;

    var p:Float = curPos;
    if (p < 0)
    {
      p *= -1;
      p += mult;
    }

    final ppp:Float = p + (mult / 2);
    final funny:Float = (ppp + mult) % mm;
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
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.x += strumResult[data.direction];
    }
  }
}

class ZigZagYMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.y += strumResult[data.direction];
    }
  }
}

class ZigZagZMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.z += strumResult[data.direction];
    }
  }
}

class ZigZagAngleMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class ZigZagAngleXMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.angleX += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.angleX += strumResult[data.direction];
    }
  }
}

class ZigZagAngleYMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.angleY += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.angleY += strumResult[data.direction];
    }
  }
}

class ZigZagScaleMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    final r:Float = ziggyMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class ZigZagScaleXMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += ziggyMath(data.curPos) * currentValue * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class ZigZagScaleYMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += ziggyMath(data.curPos) * currentValue * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class ZigZagSkewXMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.skewX += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.skewX += strumResult[data.direction];
    }
  }
}

class ZigZagSkewYMod extends ZigZagBaseMod
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.skewY += ziggyMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ziggyMath(data.curPos) * currentValue;
      data.skewY += strumResult[data.direction];
    }
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
