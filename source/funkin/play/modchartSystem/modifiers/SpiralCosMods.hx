package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class SpiralCosXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    data.x += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    var curVal:Float = currentValue * (Preferences.downscroll ? 1 : -1) / 100;

    data.y += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * curVal;
  }
}

class SpiralCosZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    data.z += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosAngleZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    unknown = false;
    notesMod = true;
    // holdsMod = true;
    // pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    data.angleZ += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    // pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;

    data.scaleX += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    data.scaleY += (sin(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100 * 0.01;
  }
}

class SpiralCosSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 0.05);
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
    var curPos_:Float = curPos2 * -0.1;
    r += (cos(curPos_ * Math.PI * getSubVal("mult")) * curPos_ * curPos_) * currentValue / 100;

    return (r * 0.005) + 1;
  }
}
