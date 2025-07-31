package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxMath;

// Contains all the mods related to scale!
class ScaleModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
  }
}

class ScaleYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY += currentValue;
  }
}

class ScaleZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ += currentValue;
  }
}

class ScaleStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
  }
}

class ScaleYStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY += currentValue;
  }
}

class ScaleNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
  }
}

class ScaleYNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += currentValue;
  }
}

class ScaleHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    if (isHoldNote)
    {
      data.scaleX += currentValue;
      data.scaleY += currentValue;
      data.scaleZ += currentValue;
    }
  }
}

class ZoomModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority -= 10; // apply AFTER tiny
    this.baseValue = 1;
    this.currentValue = 1;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 1 || data.noteType == "receptor") return;

    data.scaleX *= currentValue;
    data.scaleY *= currentValue;
    data.scaleZ *= currentValue;

    data.x = data.x = FlxMath.lerp(data.x, data.whichStrumNote?.strumExtraModData?.playfieldX ?? FlxG.width / 2, 1 - currentValue);
    data.y = data.y = FlxMath.lerp(data.y, data.whichStrumNote?.strumExtraModData?.playfieldY ?? FlxG.height / 2, 1 - currentValue);
    data.x -= strumMathX;
    data.y -= strumMathY;
    // data.z = data.z = FlxMath.lerp(data.x, data.whichStrumNote.strumExtraModData.playfieldZ, v);
  }

  var strumMathX:Float = 0;
  var strumMathY:Float = 0;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 1) return;
    data.scaleX *= currentValue;
    data.scaleY *= currentValue;
    data.scaleZ *= currentValue;
    strumMathX = data.x;
    strumMathY = data.y;
    data.x = data.x = FlxMath.lerp(data.x, data.whichStrumNote?.strumExtraModData?.playfieldX ?? FlxG.width / 2, 1 - currentValue);
    data.y = data.y = FlxMath.lerp(data.y, data.whichStrumNote?.strumExtraModData?.playfieldY ?? FlxG.height / 2, 1 - currentValue);
    strumMathX = data.x - strumMathX;
    strumMathY = data.y - strumMathY;
  }
}

// Not perfect but close enough
class MiniModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority -= 5; // apply a bit later(after column stuff)
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    var tinyVal:Float = currentValue * 0.5;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, tinyVal);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, tinyVal);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, tinyVal);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote = false):Float
  {
    return 1 - currentValue / 2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    var tinyVal:Float = currentValue * 0.5;

    var scalePointX:Float = (1.5 * Strumline.NOTE_SPACING) + strumLine.x;
    data.x = FlxMath.lerp(data.x, scalePointX, tinyVal);

    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, tinyVal);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, tinyVal);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, tinyVal);
  }
}

// Contains all the mods related to scale!
class TinyModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 1; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}

class TinyXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
  }
}

class TinyYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
  }
}

class TinyZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}

class TinyHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    if (isHoldNote)
    {
      data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
      data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
      data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
    }
  }
}

class TinyStrumModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}

class TinyStrumXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
  }
}

class TinyStrumYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
  }
}

class TinyStrumZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}

class TinyNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}

class TinyNotesXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue / 2);
  }
}

class TinyNotesYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue / 2);
  }
}

class TinyNotesZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue / 2);
  }
}
