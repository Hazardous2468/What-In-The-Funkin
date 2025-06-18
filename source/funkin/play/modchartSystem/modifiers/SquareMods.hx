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
  public function new(name:String)
  {
    super(name, 0);
    createSubMod("xoffset", 0.0);
    createSubMod("yoffset", 0.0);
    createSubMod("mult", 1.0);
  }

  function squareMath(curPos:Float):Float
  {
    var mult:Float = getSubVal("mult") / (ModConstants.strumSize * 2);
    var timeOffset:Float = getSubVal("yoffset");
    var xOffset:Float = getSubVal("xoffset");
    var xVal:Float = sin((curPos + timeOffset) * Math.PI * mult);
    xVal = Math.floor(xVal) + 0.5 + xOffset;
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
    var r:Float = squareMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = squareMath(data.curPos) * currentValue * 0.01;
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
