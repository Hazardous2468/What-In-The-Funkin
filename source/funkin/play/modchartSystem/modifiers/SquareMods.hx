package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to square!

class SquareModBase extends Modifier
{
  var multSubmod:ModifierSubValue;
  var offsetX:ModifierSubValue;
  var offsetY:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    offsetX = createSubMod("offset_x", 0.0, ["offsetx", "xoffset", "x_offset"]);
    offsetY = createSubMod("offset_y", 0.0, ["offsety", "yoffset", "y_offset", "offset"]);
    multSubmod = createSubMod("mult", 1.0, ["period", "size"]);
  }

  function squareMath(curPos:Float):Float
  {
    final mult:Float = multSubmod.value / (ModConstants.strumSize * 2);
    final timeOffset:Float = offsetY.value * (Preferences.downscroll ? -1 : 1);
    var xVal:Float = sin((curPos + timeOffset) * Math.PI * mult);
    xVal = Math.floor(xVal) + 0.5 + offsetX.value;
    return xVal;
  }
}

class SquareXMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= squareMath(data.whichStrumNote?.strumDistance ?? 0) * currentValue * ModConstants.strumSize;
    data.x += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }
}

class SquareYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= squareMath(data.whichStrumNote?.strumDistance ?? 0) * currentValue * ModConstants.strumSize;
    data.y += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }
}

class SquareZMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= squareMath(data.whichStrumNote?.strumDistance ?? 0) * currentValue * ModConstants.strumSize;
    data.z += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z = squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }
}

class SquareAngleMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ = squareMath(data.curPos) * currentValue;
  }
}

class SquareScaleMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = squareMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = squareMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }
}

class SquareSkewXMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX = squareMath(data.curPos) * currentValue;
  }
}

class SquareSkewYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY = squareMath(data.curPos) * currentValue;
  }
}

class SquareSpeedMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 401;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    return (squareMath(curPos) * currentValue * 0.005) + 1;
  }
}
