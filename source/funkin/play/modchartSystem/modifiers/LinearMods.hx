package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class LinearModifierBase extends Modifier
{
  public function new(name:String)
  {
    super(name);
    offset = createSubMod("offset", 0.0);
    altCurposSubmod = createSubMod("altcurpos", 1.0, ["use_unscaled", "alt_curpos", "type"]);
  }

  var altCurposSubmod:ModifierSubValue;
  var offset:ModifierSubValue;
  var strumResult:Array<Float> = [0, 0, 0, 0];

  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  function daMath(curPos:Float):Float
  {
    curPos *= Preferences.downscroll ? -1 : 1;
    return (curPos + offset.value) * currentValue;
  }
}

class LinearXMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearYMod extends LinearModifierBase
{
  public var flipForDownscroll:Bool = true;

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    data.y -= strumResult[data.direction];
    final curPosToUse:Float = (useUnscaledCurpos ? data.curPos_unscaled : data.curPos);

    data.y += daMath(curPosToUse) * (Preferences.downscroll && flipForDownscroll ? -1 : 1);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      final curPosToUse:Float = (useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      strumResult[data.direction] = daMath(curPosToUse) * (Preferences.downscroll && flipForDownscroll ? -1 : 1);
      data.y += strumResult[data.direction];
    }
  }
}

class LinearZMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearAngleMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearAngleYMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearAngleXMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearScaleMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final daResult:Float = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += daResult;
    data.scaleY += daResult;
    data.scaleZ += daResult;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class LinearScaleXMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class LinearScaleYMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class LinearSkewXMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearSkewYMod extends LinearModifierBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
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

class LinearSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = 395;
    offset = createSubMod("offset", 0.0);
  }

  var offset:ModifierSubValue;

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1;
    return (curPos + offset.value) / 100 * currentValue;
  }
}

// for legacy support
class ScaleLinearLegacyMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0) return;
    final curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    final p:Float = curPos2 * -1;
    data.scaleX = FlxMath.lerp(data.scaleX, currentValue, p / 1000 * 2);
    data.scaleY = FlxMath.lerp(data.scaleY, currentValue, p / 1000 * 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, currentValue, p / 1000 * 2);
  }
}
