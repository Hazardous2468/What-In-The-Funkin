package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related sawtooth
// :p
class SawtoothXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.x += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.y += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.z += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.angleZ += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.angleX += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothAngleYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    data.angleY += ModConstants.mod(data.curPos, mult) * currentValue;
  }
}

class SawtoothScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleX += (result * 0.01);
    data.scaleY += (result * 0.01);
    data.scaleZ += (result * 0.01);
  }
}

class SawtoothScaleXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleX += (result * 0.01);
  }
}

class SawtoothScaleYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.scaleY += (result * 0.01);
  }
}

class SawtoothSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.skewX += (result);
  }
}

class SawtoothSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    createSubMod("mult", 1);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var mult:Float = ModConstants.strumSize * getSubVal("mult");
    var result:Float = ModConstants.mod(data.curPos, mult) * currentValue * -1;
    data.skewY += (result);
  }
}

class SawtoothSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = 400;
    createSubMod("mult", 250);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    return (Math.abs(curPos) % getSubVal("mult") / 2.0 * currentValue / 100) + 1;
  }
}
