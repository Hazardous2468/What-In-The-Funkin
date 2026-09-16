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
  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

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
    invertForDad = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * ModConstants.strumSize;
      data.x += strumResult[data.direction];
    }
  }
}

class SquareYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * ModConstants.strumSize;
      data.y += strumResult[data.direction];
    }
  }
}

class SquareZMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += squareMath(data.curPos) * currentValue * ModConstants.strumSize;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * ModConstants.strumSize;
      data.z += strumResult[data.direction];
    }
  }
}

class SquareAngleMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class SquareAngleXMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleX += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue;
      data.angleX += strumResult[data.direction];
    }
  }
}

class SquareAngleYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleY += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue;
      data.angleY += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    final r:Float = squareMath(data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class SquareScaleXMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleX += squareMath(data.curPos) * currentValue * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class SquareScaleYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleY += squareMath(data.curPos) * currentValue * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class SquareSkewXMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewX += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue;
      data.skewX += strumResult[data.direction];
    }
  }
}

class SquareSkewYMod extends SquareModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewY += squareMath(data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = squareMath(data.curPos) * currentValue;
      data.skewY += strumResult[data.direction];
    }
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
