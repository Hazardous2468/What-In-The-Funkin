package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class SpiralModBase extends Modifier
{
  var useCosSubmod:ModifierSubValue;
  var multSubmod:ModifierSubValue;
  var offsetSubmod:ModifierSubValue;
  var altCurposSubmod:ModifierSubValue;

  public function new(name:String, isCos:Bool = false)
  {
    super(name);
    forceUseCos = isCos;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;

    altCurposSubmod = createSubMod("altcurpos", 0.0, ["use_unscaled", "alt_curpos", "type"]);
    offsetSubmod = createSubMod("offset", 0.0);
    multSubmod = createSubMod("mult", 0.05, ["period", "size"]);
    if (!forceUseCos) useCosSubmod = createSubMod("cos", 0.0);
  }

  // Cos is handled this stupid way for compatibility with using cos Submod from older versions of WITF
  var forceUseCos:Bool = false;
  var useCos(get, never):Bool;

  function get_useCos():Bool
  {
    if (forceUseCos)
    {
      return true;
    }
    else
    {
      return (useCosSubmod?.value ?? 0.0) >= 0.5;
    }
  }

  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  function getMult():Float
  {
    return multSubmod?.value ?? 0.05;
  }

  function getOffset():Float
  {
    return offsetSubmod?.value ?? 0.0;
  }

  function spiralMath(curPos:Float):Float
  {
    curPos = curPos * (Preferences.downscroll ? -1 : 1);
    curPos *= -0.1;
    var curposWithOffset:Float = curPos - getOffset();

    if (useCos)
    {
      return (cos(curposWithOffset * Math.PI * getMult()) * curPos * curPos) * currentValue / 100;
    }
    else
    {
      return (sin(curposWithOffset * Math.PI * getMult()) * curPos * curPos) * currentValue / 100;
    }
  }
}

class SpiralXMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.x += spiralMath((useUnscaledCurpos ? data.curPos_unscaled : data.curPos));
  }
}

class SpiralYMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.y -= spiralMath((useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * (Preferences.downscroll ? -1 : 1));
  }
}

class SpiralZMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.z += spiralMath((useUnscaledCurpos ? data.curPos_unscaled : data.curPos));
  }
}

class SpiralAngleZMod extends SpiralModBase
{
  public function new(name:String, isCos:Bool = false)
  {
    super(name, isCos);
    holdsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.angleZ += spiralMath((useUnscaledCurpos ? data.curPos_unscaled : data.curPos));
  }
}

class SpiralScaleMod extends SpiralModBase
{
  public function new(name:String, isCos:Bool = false)
  {
    super(name, isCos);
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    var modMathResult:Float = spiralMath((useUnscaledCurpos ? data.curPos_unscaled : data.curPos)) * 0.01;
    data.scaleX += modMathResult;
    data.scaleY += modMathResult;
  }
}

class SpiralSpeedMod extends SpiralModBase
{
  public function new(name:String, isCos:Bool = false)
  {
    super(name, isCos);
    modPriority = 395;
    speedMod = true;
    notesMod = false;
    holdsMod = false;
    pathMod = false;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1;
    var r:Float = spiralMath(curPos);
    return (r * 0.005) + 1;
  }
}
