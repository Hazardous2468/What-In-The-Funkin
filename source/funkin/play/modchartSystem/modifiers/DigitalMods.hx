package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related bumpy mods
// :p
class DigitalModBase extends Modifier
{
  var mult:ModifierSubValue;
  var steps:ModifierSubValue;
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    steps = createSubMod("steps", 4.0);
    // offset?
  }

  function digitalMath(curPos:Float):Float
  {
    var s:Float = steps.value / 2;

    var funny:Float = sin(curPos * Math.PI * mult.value / 250) * s;
    // trace("1: " + funny);
    funny = Math.floor(funny);
    // funny = Math.round(funny); //Why does this not work? no idea :(
    // trace("2: " + funny);
    // funny = funny;
    funny /= s;
    // trace("3: " + funny);
    return funny * currentValue;
  }
}

class DigitalXMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }
}

class DigitalYMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }
}

class DigitalZMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }
}

class DigitalAngleMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += digitalMath(data.curPos);
  }
}

class DigitalAngleXMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += digitalMath(data.curPos);
  }
}

class DigitalAngleYMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += digitalMath(data.curPos);
  }
}

class DigitalScaleMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = digitalMath(data.curPos) * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }
}

class DigitalSkewXMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += digitalMath(data.curPos);
  }
}

class DigitalSkewYMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += digitalMath(data.curPos);
  }
}

class DigitalSpeedMod extends DigitalModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 401;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var modWouldBe:Float = digitalMath(curPos);
    return (modWouldBe + 1);
  }
}
