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
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.x -= strumResult[data.direction];
    data.x += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.x += strumResult[data.direction];
    }
  }
}

class SawtoothYMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.y -= strumResult[data.direction];
    data.y += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.y += strumResult[data.direction];
    }
  }
}

class SawtoothZMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.z -= strumResult[data.direction];
    data.z += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.z += strumResult[data.direction];
    }
  }
}

class SawtoothAngleMod extends SawtoothModBase
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
    data.angleZ += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class SawtoothAngleXMod extends SawtoothModBase
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
    data.angleX += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.angleX += strumResult[data.direction];
    }
  }
}

class SawtoothAngleYMod extends SawtoothModBase
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
    data.angleY += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.angleY += strumResult[data.direction];
    }
  }
}

class SawtoothScaleMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    final result:Float = FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
    data.scaleX += result;
    data.scaleY += result;
    data.scaleZ += result;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class SawtoothScaleXMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleX += FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class SawtoothScaleYMod extends SawtoothModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleY += FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue * -1 * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class SawtoothSkewXMod extends SawtoothModBase
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
    data.skewX += FlxMath.mod(data.curPos + offset, mult) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
      data.skewX += strumResult[data.direction];
    }
  }
}

class SawtoothSkewYMod extends SawtoothModBase
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
    var result:Float = FlxMath.mod(data.curPos + offset, mult) * currentValue * -1;
    data.skewY += (result);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = FlxMath.mod(data.curPos + offset, mult) * currentValue;
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
