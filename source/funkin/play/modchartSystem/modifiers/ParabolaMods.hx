package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class ParabolaModBase extends Modifier
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
    pos += offset.value;
    pos /= 100;
    return pos * pos * currentValue;
  }
}

class ParabolaXMod extends ParabolaModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.x -= strumResult[data.direction];
    data.x += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
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

class ParabolaYMod extends ParabolaModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.y -= strumResult[data.direction];
    data.y += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
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

class ParabolaZMod extends ParabolaModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.z -= strumResult[data.direction];
    data.z += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
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

class ParabolaAngleZMod extends ParabolaModBase
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class ParabolaAngleYMod extends ParabolaModBase
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class ParabolaAngleXMod extends ParabolaModBase
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class ParabolaSkewXMod extends ParabolaModBase
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class ParabolaSkewYMod extends ParabolaModBase
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class ParabolaScaleXMod extends ParabolaModBase
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleX += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.scaleX += strumResult[data.direction];
    }
  }
}

class ParabolaScaleYMod extends ParabolaModBase
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleY += daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.scaleY += strumResult[data.direction];
    }
  }
}

class ParabolaScaleMod extends ParabolaModBase
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    final s:Float = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      strumResult[data.direction] = daMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}
