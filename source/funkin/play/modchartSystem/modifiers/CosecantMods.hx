package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to cosecant! Stolen from Edwhak lmfao
class CosecantModifierBase extends Modifier
{
  function cosecant(angle:Null<Float>):Float
  {
    return 1 / Math.sin(angle);
  }

  var speed:ModifierSubValue;
  var mult:ModifierSubValue;
  var desync:ModifierSubValue;
  var time_add:ModifierSubValue;
  var timertype:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);

    speed = createSubMod("speed", 1.0, ["frequency"]);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    desync = createSubMod("desync", 0.2, ["spacing"]);
    time_add = createSubMod("time_add", 0.0, ["offset", "timeadd", "time_offset", "timeoffset"]);
    timertype = createSubMod("timertype", 0.0);
  }

  function drunkMath(lane:Int, curPos:Float):Float
  {
    var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
    time *= speed.value;
    time += time_add.value;

    var returnValue:Float = 0.0;

    returnValue += currentValue * (cosecant(((time) + ((lane) * desync.value) +
      (curPos * mult.value * (0.225)) * 10 / FlxG.height))) * ModConstants.strumSize * (0.5);

    return returnValue;
  }
}

class CosecantXMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.x += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += drunkMath(data.direction, data.curPos);
  }
}

class CosecantYMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.y += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += drunkMath(data.direction, data.curPos);
  }
}

class CosecantZMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.z += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += drunkMath(data.direction, data.curPos);
  }
}

class CosecantAngleMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleZ += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += drunkMath(data.direction, data.curPos);
  }
}

class CosecantScaleMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0) * 0.01; // undo the strum  movement.
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01; // re apply but now with notePos
    data.scaleY -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0) * 0.01;
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01;
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class CosecantScaleXMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0) * 0.01; // undo the strum  movement.
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01; // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class CosecantScaleYMod extends CosecantModifierBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0) * 0.01; // undo the strum  movement.
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01; // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01;
  }
}
