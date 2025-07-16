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

  public function new(name:String, isCos:Bool = false)
  {
    super(name);
    forceUseCos = isCos;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;

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

  function getMult():Float
  {
    return multSubmod?.value ?? 0.05;
  }

  function getOffset():Float
  {
    return offsetSubmod?.value ?? 0.0;
  }
}

class SpiralXMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    if (useCos)
    {
      data.x += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.x += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralYMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    var curVal:Float = currentValue * (Preferences.downscroll ? 1 : -1) / 100;
    if (useCos)
    {
      data.y += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * curVal;
    }
    else
    {
      data.y += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * curVal;
    }
  }
}

class SpiralZMod extends SpiralModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    if (useCos)
    {
      data.z += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.z += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralAngleZMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name);
    holdsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    if (useCos)
    {
      data.angleZ += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.angleZ += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralScaleMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name);
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    if (useCos)
    {
      data.scaleX += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
      data.scaleY += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    }
    else
    {
      data.scaleX += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
      data.scaleY += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    }
  }
}

class SpiralSpeedMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 395;
    speedMod = true;
    notesMod = false;
    holdsMod = false;
    pathMod = false;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1;

    var r:Float = 0;

    if (currentValue == 0) return 1; // skip math if mod is 0
    var curPos2:Float = curPos * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    if (useCos)
    {
      r += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      r += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
    }

    return (r * 0.005) + 1;
  }
}
