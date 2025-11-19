package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;

class CircModBase extends Modifier
{
  var offset:ModifierSubValue;
  var strumResult:Array<Float> = [0, 0, 0, 0];

  var altCurposSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name);
    offset = createSubMod("offset", 0.0);
    altCurposSubmod = createSubMod("altcurpos", 1.0, ["use_unscaled", "alt_curpos", "type"]);
  }

  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  function daMath(curPos:Float):Float
  {
    var curPos2:Float = curPos * (Preferences.downscroll ? -1 : 1);
    curPos2 += offset.value;
    return (curPos2 * curPos2 * currentValue * -0.001);
  }
}

class CircXMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.x += strumResult[data.direction];
    }
  }
}

class CircYMod extends CircModBase
{
  public var flipForDownscroll:Bool = true;

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * (Preferences.downscroll && flipForDownscroll ? -1 : 1);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * (Preferences.downscroll && flipForDownscroll ? -1 : 1);
      data.y += strumResult[data.direction];
    }
  }
}

class CircZMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class CircAngleMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction];
    data.angleZ += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class CircAngleYMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class CircAngleXMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class CircScaleMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
    data.scaleY += r;
    data.scaleX += r;
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
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
      data.scaleY += strumResult[data.direction];
      data.scaleX += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class CircScaleXMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class CircScaleYMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * -0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class CircSkewXMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class CircSkewYMod extends CircModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class CircSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = 396;
    offset = createSubMod("offset", 0.0);
  }

  var offset:ModifierSubValue;

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var curPos2:Float = curPos * (Preferences.downscroll ? -1 : 1);
    curPos2 += offset.value;
    final result:Float = curPos2 * curPos2 * currentValue * -0.001;
    return 1 + result;
  }
}
