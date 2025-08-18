package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.ModConstants;
import lime.math.Vector2;

// Contains all mods which control strumline rotation!
class RotateModBase extends Modifier
{
  var offsetX:ModifierSubValue;
  var offsetY:ModifierSubValue;
  var offsetZ:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 21;
    offsetX = createSubMod("offset_x", 0.0, ["offsetx", "xoffset", "x_offset"]);
    offsetY = createSubMod("offset_y", 0.0, ["offsety", "yoffset", "y_offset"]);
    offsetZ = createSubMod("offset_z", 0.0, ["offsetz", "zoffset", "z_offset"]);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  var pivotPoint:Vector2 = new Vector2(0, 0);
  var point:Vector2 = new Vector2(0, 0);

  function noteRotateFunc_GetPivotX(data:NoteData, strumLine:Strumline):Float
  {
    var r:Float = data.whichStrumNote.x;
    if (data.noteType == "receptor")
    {
      r = data.strumPosWasHere.x;
    }
    else if (data.noteType == "hold" || data.noteType == "path")
    {
      r += strumLine.mods.getHoldOffsetX(data.noteType == "path");
      r -= data.whichStrumNote.strumExtraModData.noteStyleOffsetX;
    }
    else
    {
      r += data.whichStrumNote.weBelongTo.getNoteXOffset();
      r -= data.whichStrumNote.strumExtraModData.noteStyleOffsetX;
    }
    return r;
  }

  function noteRotateFunc_GetPivotY(data:NoteData, strumLine:Strumline):Float
  {
    var r:Float = data.whichStrumNote.y;
    if (data.noteType == "receptor")
    {
      r = data.strumPosWasHere.y;
    }
    else if (data.noteType == "hold" || data.noteType == "path")
    {
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
      r += data.whichStrumNote.weBelongTo.getNoteYOffset();
      r -= data.whichStrumNote.strumExtraModData.noteStyleOffsetY;
    }
    return r;
  }

  function noteRotateFunc_GetPivotZ(data:NoteData, strumLine:Strumline):Float
  {
    return (data.noteType == "receptor" ? data.strumPosWasHere.z : data.whichStrumNote.z);
  }

  function noteRotateFunc(data:NoteData, strumLine:Strumline, variant:String, angle:Null<Float> = null):Void
  {
    if (angle == null) angle = this.currentValue;
    if (angle % 360 == 0) return;
    switch (variant)
    {
      case "z":
        pivotPoint.x = noteRotateFunc_GetPivotX(data, strumLine);
        pivotPoint.y = noteRotateFunc_GetPivotY(data, strumLine);
        point.x = data.x;
        point.y = data.y;
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.x = output.x;
        data.y = output.y;
      case "y":
        pivotPoint.x = noteRotateFunc_GetPivotX(data, strumLine);
        pivotPoint.y = noteRotateFunc_GetPivotZ(data, strumLine);
        point.x = data.x;
        point.y = data.z;
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.x = output.x;
        data.z = output.y;
      case "x":
        pivotPoint.x = noteRotateFunc_GetPivotZ(data, strumLine);
        pivotPoint.y = noteRotateFunc_GetPivotY(data, strumLine);
        point.x = data.z;
        point.y = data.y;
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.z = output.x;
        data.y = output.y;
    }
  }

  function strumRotateFunc_GetPivotX(data:NoteData, strumLine:Strumline):Float
  {
    if (strumLine == null)
    {
      strumLine = data.whichStrumNote.weBelongTo;
    }
    var r:Float = 0;
    r += strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    r += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;
    r += this.offsetX.value;
    return r;
  };

  function strumRotateFunc_GetPivotY(data:NoteData, strumLine:Strumline):Float
  {
    return (FlxG.height / 2) - (data.whichStrumNote.height / 2) + this.offsetY.value;
  };

  function strumRotateFunc_GetPivotZ(data:NoteData, strumLine:Strumline):Float
  {
    return 0.0 + this.offsetZ.value;
  };

  function strumRotateFunc(data:NoteData, strumLine:Strumline, variant:String, angle:Null<Float> = null):Void
  {
    if (angle == null) angle = this.currentValue;
    if (angle % 360 == 0) return;
    switch (variant)
    {
      case "z":
        pivotPoint.x = strumRotateFunc_GetPivotX(data, strumLine);
        pivotPoint.y = strumRotateFunc_GetPivotY(data, strumLine);
        point.setTo(data.x, data.y);
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.x = output.x;
        data.y = output.y;
      case "y":
        pivotPoint.x = strumRotateFunc_GetPivotX(data, strumLine);
        pivotPoint.y = strumRotateFunc_GetPivotZ(data, strumLine);
        point.setTo(data.x, data.z);
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.x = output.x;
        data.z = output.y;
      case "x":
        pivotPoint.x = strumRotateFunc_GetPivotZ(data, strumLine);
        pivotPoint.y = strumRotateFunc_GetPivotY(data, strumLine);
        point.setTo(data.z, data.y);
        var output:Vector2 = ModConstants.rotateAround(pivotPoint, point, angle);
        data.z = output.x;
        data.y = output.y;
    }
  }
}

class RotateXModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 21;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "x");
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "x");
  }
}

class RotateYModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 22;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "y");
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "y");
  }
}

class RotateZModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 23;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "z");
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "z");
  }
}

class StrumRotateXModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 21 + 6;
    unknown = false;
    notesMod = false;
    holdsMod = false;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "x");
  }
}

class StrumRotateYModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 22 + 6;
    unknown = false;
    notesMod = false;
    holdsMod = false;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "y");
  }
}

class StrumRotateZModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 23 + 6;
    unknown = false;
    notesMod = false;
    holdsMod = false;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumRotateFunc(data, strumLine, "z");
  }
}

class NotesRotateXModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 21 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "x");
  }
}

class NotesRotateYModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 22 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "y");
  }
}

class NotesRotateZModifier extends RotateModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 23 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    noteRotateFunc(data, strumLine, "z");
  }
}

class RotatingXModifier extends RotateModBase
{
  var affectsStrums:ModifierSubValue;

  public function new(name:String)
  {
    super(name);
    modPriority = 21 + 9;
    affectsStrums = createSubMod("affect_strum", 0.0, [
      "affects_strum",
      "affects_strums",
      "affect_strums",
      "affectstrum",
      "affectstrums",
      "affectsstrum",
      "affectsstrums",
      "strums",
      "strum",
      "receptors",
      "receptor"
    ]);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var curVal:Float = currentValue * data.curPos / 180;
    noteRotateFunc(data, strumLine, "x", curVal);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (this.currentValue % 360 == 0 || affectsStrums.value == 0) return;
    var curVal:Float = currentValue * data.curPos / 180;
    strumRotateFunc(data, strumLine, "x", curVal);
  }
}

class RotatingYModifier extends RotateModBase
{
  var affectsStrums:ModifierSubValue;

  public function new(name:String)
  {
    super(name);
    modPriority = 22 + 9;
    affectsStrums = createSubMod("affect_strum", 0.0, [
      "affects_strum",
      "affects_strums",
      "affect_strums",
      "affectstrum",
      "affectstrums",
      "affectsstrum",
      "affectsstrums",
      "strums",
      "strum",
      "receptors",
      "receptor"
    ]);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var curVal:Float = currentValue * data.curPos / 180;
    noteRotateFunc(data, strumLine, "y", curVal);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (this.currentValue % 360 == 0 || affectsStrums.value == 0) return;
    var curVal:Float = currentValue * data.curPos / 180;
    strumRotateFunc(data, strumLine, "y", curVal);
  }
}

class RotatingZModifier extends RotateModBase
{
  var affectsStrums:ModifierSubValue;

  public function new(name:String)
  {
    super(name);
    modPriority = 23 + 9;
    affectsStrums = createSubMod("affect_strum", 0.0, [
      "affects_strum",
      "affects_strums",
      "affect_strums",
      "affectstrum",
      "affectstrums",
      "affectsstrum",
      "affectsstrums",
      "strums",
      "strum",
      "receptors",
      "receptor"
    ]);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var curVal:Float = currentValue * data.curPos / 180;
    noteRotateFunc(data, strumLine, "z", curVal);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (this.currentValue % 360 == 0 || affectsStrums.value == 0) return;
    var curVal:Float = currentValue * data.curPos / 180;
    strumRotateFunc(data, strumLine, "z", curVal);
  }
}
