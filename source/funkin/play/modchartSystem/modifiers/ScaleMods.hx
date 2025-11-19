package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.modifiers.RotateMods; // for scaleFrom modifier

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
    final tinyVal:Float = currentValue * 0.5;

    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, tinyVal);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, tinyVal);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote = false):Float
  {
    return 1 - currentValue / 2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    final tinyVal:Float = currentValue * 0.5;

    final scalePointX:Float = (1.5 * Strumline.NOTE_SPACING) + strumLine.x;
    data.x = FlxMath.lerp(data.x, scalePointX, tinyVal);

    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, tinyVal);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, tinyVal);
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

// Has the additional functionality of allowing you to move the scale point around (works the same as rotate mods!)
class ZoomModifier extends RotateModBase
{
  var doX:Bool = true;
  var doY:Bool = true;

  // If set to 0.5 or higher, will use scale2 instead. Otherwise use normal scale.
  var typeSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name);
    // Apply AFTER pixel move mods to avoid breaking
    modPriority = -9999;
    modPriority -= 10;
    this.baseValue = 1;
    this.currentValue = 1;
    notPercentage = false;
    typeSubmod = createSubMod("type", 1.0, ["variant", "mode", "scale2"]);
  }

  var strumResultX:Array<Float> = [0, 0, 0, 0];
  var strumResultY:Array<Float> = [0, 0, 0, 0];

  function getScalePivot_X(data:NoteData, strumLine:Strumline):Float
  {
    var r:Float = 0;
    if (data.noteType == "hold" || data.noteType == "path")
    {
      r += strumRotateFunc_GetPivotX(data, data.whichStrumNote.weBelongTo);
      r += strumLine.mods.getHoldOffsetX(data.noteType == "path");
      r -= data.whichStrumNote.strumExtraModData.noteStyleOffsetX;
    }
    else
    {
      r += strumRotateFunc_GetPivotX(data, data.whichStrumNote.weBelongTo);
    }
    return r;
  }

  function getScalePivot_Y(data:NoteData, strumLine:Strumline):Float
  {
    var r:Float = 0;
    if (data.noteType == "hold" || data.noteType == "path")
    {
      r += strumRotateFunc_GetPivotY(data, data.whichStrumNote.weBelongTo);
      if (Preferences.downscroll)
      {
        r += (Strumline.STRUMLINE_SIZE / 2);
      }
      else
      {
        r += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
      }
      r -= data.whichStrumNote.strumExtraModData.noteStyleOffsetY;
    }
    else
    {
      r += strumRotateFunc_GetPivotY(data, data.whichStrumNote.weBelongTo);
    }
    return r;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 1) return;
    final curVal:Float = (1 - this.currentValue);
    if (doX)
    {
      data.x += strumResultX[data.direction];
      data.x = FlxMath.lerp(data.x, getScalePivot_X(data, strumLine), curVal);
      if (typeSubmod.value >= 0.5) data.scaleX2 *= currentValue;
      else
        data.scaleX *= currentValue;
    }
    if (doY)
    {
      data.y += strumResultY[data.direction];
      data.y = FlxMath.lerp(data.y, getScalePivot_Y(data, strumLine), curVal);
      if (typeSubmod.value >= 0.5) data.scaleY2 *= currentValue;
      else
        data.scaleY *= currentValue;
    }
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 1) return;
    final curVal:Float = (1 - this.currentValue);
    if (doX)
    {
      final memoryX:Float = data.x;
      data.x = FlxMath.lerp(data.x, getScalePivot_X(data, strumLine), curVal);
      strumResultX[data.direction] = memoryX - data.x;

      if (typeSubmod.value >= 0.5) data.scaleX2 *= currentValue;
      else
        data.scaleX *= currentValue;
    }
    if (doY)
    {
      final memoryY:Float = data.y;
      data.y = FlxMath.lerp(data.y, getScalePivot_Y(data, strumLine), curVal);
      strumResultY[data.direction] = memoryY - data.y;

      if (typeSubmod.value >= 0.5) data.scaleY2 *= currentValue;
      else
        data.scaleY *= currentValue;
    }
  }
}

class ZoomXModifier extends ZoomModifier
{
  public function new(name:String)
  {
    super(name);
    this.doY = false;
  }
}

class ZoomYModifier extends ZoomModifier
{
  public function new(name:String)
  {
    super(name);
    this.doX = false;
  }
}
