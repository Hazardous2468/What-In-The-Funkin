package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related sawtooth
// :p

class SawtoothModBase extends Modifier
{
  var mult(get, never):Float;

  function get_mult():Float
  {
    return ModConstants.strumSize * multSubmod?.value ?? 1.0;
  }

  public function new(name:String)
  {
    super(name);
    multSubmod = createSubMod("mult", 1.0, ["period", "size"]);
  }

  var multSubmod:ModifierSubValue;
}

class SawtoothXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothZMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothScaleMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleX += (result * 0.01);
    data.scaleY += (result * 0.01);
    data.scaleZ += (result * 0.01);
  }
}

class SawtoothScaleXMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleX += (result * 0.01);
  }
}

class SawtoothScaleYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleY += (result * 0.01);
  }
}

class SawtoothSkewXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.skewX += (result);
  }
}

class SawtoothSkewYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.skewY += (result);
  }
}

class SawtoothSpeedMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 400;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    return (Math.abs(curPos) % multSubmod.value / 2.0 * currentValue / 100) + 1;
  }
}
