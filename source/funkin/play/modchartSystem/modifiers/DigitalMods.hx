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
  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    steps = createSubMod("steps", 4.0);
    offset = createSubMod("offset", 0.0);
  }

  function digitalMath(curPos:Float):Float
  {
    curPos += offset.value;
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
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
      data.x += strumResult[data.direction];
    }
  }
}

class DigitalYMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
      data.y += strumResult[data.direction];
    }
  }
}

class DigitalZMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * (Strumline.STRUMLINE_SIZE / 2.0);
      data.z += strumResult[data.direction];
    }
  }
}

class DigitalAngleMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction];
    data.angleZ += digitalMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class DigitalAngleXMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += digitalMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class DigitalAngleYMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += digitalMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class DigitalScaleMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = digitalMath(data.curPos) * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class DigitalScaleXMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += digitalMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class DigitalScaleYMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += digitalMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class DigitalSkewXMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += digitalMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class DigitalSkewYMod extends DigitalModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += digitalMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = digitalMath(data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class DigitalSpeedMod extends DigitalModBase
{
  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var modWouldBe:Float = digitalMath(curPos);
    return (modWouldBe + 1);
  }
}
