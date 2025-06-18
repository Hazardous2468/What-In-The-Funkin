package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class SpiralXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    if (useCos)
    {
      data.x += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.x += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    var curVal:Float = currentValue * (Preferences.downscroll ? 1 : -1) / 100;
    if (useCos)
    {
      data.y += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * curVal;
    }
    else
    {
      data.y += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * curVal;
    }
  }
}

class SpiralZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    if (useCos)
    {
      data.z += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.z += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralAngleZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    unknown = false;
    notesMod = true;
    // holdsMod = true;
    // pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    if (useCos)
    {
      data.angleZ += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      data.angleZ += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
  }
}

class SpiralScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    // pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    if (useCos)
    {
      data.scaleX += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
      data.scaleY += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    }
    else
    {
      data.scaleX += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
      data.scaleY += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    }
  }
}

class SpiralSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    createSubMod("cos", 0.0);
    modPriority = 395;
    unknown = false;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1;

    var r:Float = 0;

    if (currentValue == 0) return 1; // skip math if mod is 0
    var curPos2:Float = curPos * (Preferences.downscroll ? -1 : 1);
    var useCos:Bool = getSubVal("cos") >= 0.5;
    var curPos_:Float = curPos2 * -0.1;
    if (useCos)
    {
      r += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }
    else
    {
      r += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
    }

    return (r * 0.005) + 1;
  }
}
