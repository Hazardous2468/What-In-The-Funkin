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

  var offset(get, never):Float;

  function get_offset():Float
  {
    return offsetSubmod.value * (Preferences.downscroll ? -1 : 1);
  }

  public function new(name:String)
  {
    super(name);
    multSubmod = createSubMod("mult", 1.0, ["period", "size"]);
    offsetSubmod = createSubMod("offset", 0.0);
  }

  var strumResult:Array<Float> = [0, 0, 0, 0];

  var offsetSubmod:ModifierSubValue;
  var multSubmod:ModifierSubValue;
}

class SawtoothXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.x += strumResult[data.direction];
    }
  }
}

class SawtoothYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.y += strumResult[data.direction];
    }
  }
}

class SawtoothZMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.z += strumResult[data.direction];
    }
  }
}

class SawtoothAngleMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction];
    data.angleZ += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class SawtoothAngleXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.angleX += strumResult[data.direction];
    }
  }
}

class SawtoothAngleYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.angleY += strumResult[data.direction];
    }
  }
}

class SawtoothScaleMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var result:Float = ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
    data.scaleX += result;
    data.scaleY += result;
    data.scaleZ += result;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class SawtoothScaleXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class SawtoothScaleYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class SawtoothSkewXMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.skewX += ModConstants.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.skewX += strumResult[data.direction];
    }
  }
}

class SawtoothSkewYMod extends SawtoothModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    var result:Float = ModConstants.mod(data.curPos + offset, mult) * currentValue * -1;
    data.skewY += (result);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = ModConstants.mod(data.curPos + offset, mult) * currentValue;
      data.skewY += strumResult[data.direction];
    }
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
    return (Math.abs(curPos + offset) % multSubmod.value / 2.0 * currentValue / 100) + 1;
  }
}
