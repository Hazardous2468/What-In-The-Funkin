package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class CubicModBase extends Modifier
{
  var offset:ModifierSubValue;
  var altCurposSubmod:ModifierSubValue;
  var strumResult:Array<Float> = [0, 0, 0, 0];

  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  public function new(name:String)
  {
    super(name);
    offset = createSubMod("offset", 0.0);
    altCurposSubmod = createSubMod("altcurpos", 0.0, ["use_unscaled", "alt_curpos", "type"]);
  }

  function daMath(pos:Float):Float
  {
    if (currentValue == 0) return 0;
    // Botched together based on eye from NotITG
    pos += offset.value;
    pos /= 100;
    return Math.pow(pos, 3) * -1 * currentValue;
  }
}

class CubicXMod extends CubicModBase
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

class CubicYMod extends CubicModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      data.y += strumResult[data.direction];
    }
  }
}

class CubicZMod extends CubicModBase
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

class CubicAngleZMod extends CubicModBase
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

class CubicAngleXMod extends CubicModBase
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
    data.angleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}

class CubicAngleYMod extends CubicModBase
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
    data.angleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}

class CubicScaleXMod extends CubicModBase
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
    data.scaleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}

class CubicScaleYMod extends CubicModBase
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
    data.scaleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}

class CubicScaleMod extends CubicModBase
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
    final a = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
    data.scaleX += a;
    data.scaleY += a;
    data.scaleZ += a;
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
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class CubicSkewXMod extends CubicModBase
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
    data.skewX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}

class CubicSkewYMod extends CubicModBase
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
    data.skewY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }
}
