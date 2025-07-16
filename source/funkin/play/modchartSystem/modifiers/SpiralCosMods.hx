package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.modifiers.SpiralMods;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class SpiralCosXMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    data.x += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosYMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    var curVal:Float = currentValue * (Preferences.downscroll ? 1 : -1) / 100;

    data.y += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * curVal;
  }
}

class SpiralCosZMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    data.z += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosAngleZMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
    holdsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    data.angleZ += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;
  }
}

class SpiralCosScaleMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curPos_:Float = curPos2 * -0.1;
    curPos_ += getOffset();
    data.scaleX += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
    data.scaleY += (sin(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100 * 0.01;
  }
}

class SpiralCosSpeedMod extends SpiralModBase
{
  public function new(name:String)
  {
    super(name, true);
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
    r += (cos(curPos_ * Math.PI * getMult()) * curPos_ * curPos_) * currentValue / 100;

    return (r * 0.005) + 1;
  }
}
