package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to drunk! Includes Tan variant!

class DrunkModBase extends Modifier
{
  var speed:ModifierSubValue;
  var mult:ModifierSubValue;
  var desync:ModifierSubValue;
  var time_add:ModifierSubValue;
  var sine:ModifierSubValue;
  var timertype:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    speed = createSubMod("speed", 1.0, ["frequency"]);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    desync = createSubMod("desync", 0.2, ["spacing"]);
    time_add = createSubMod("time_add", 0.0, ["offset", "timeadd", "time_offset", "timeoffset"]);
    sine = createSubMod("sine", 0.0, ["usesine", "sin"]);
    timertype = createSubMod("timertype", 0.0, ["timetype"]);
  }

  function tanDrunkMath(noteDir:Int, curPos:Float):Float
  {
    var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
    time *= speed.value;
    time += time_add.value;

    final returnValue:Float = currentValue * (tan((time) + (noteDir * desync.value) +
      (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 1.75)) * (ModConstants.strumSize * 0.5);

    return returnValue;
  }

  function drunkMath(noteDir:Int, curPos:Float):Float
  {
    var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
    time *= speed.value;
    time += time_add.value;

    var returnValue:Float = 0.0;

    if (sine.value >= 0.5) // if above 50%, use sine instead of cos.
    {
      returnValue = currentValue * (sin((time) + (noteDir * desync.value) +
        (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 2)) * (ModConstants.strumSize * 0.5);
    }
    else
    {
      returnValue = currentValue * (cos((time) + (noteDir * desync.value) +
        (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 1.75)) * (ModConstants.strumSize * 0.5);
    }

    return returnValue;
  }
}

class DrunkXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.x += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += drunkMath(data.direction, data.curPos);
  }
}

class DrunkYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.y += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += drunkMath(data.direction, data.curPos);
  }
}

class DrunkZMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.z += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += drunkMath(data.direction, data.curPos);
  }
}

class DrunkAngleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleZ -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleZ += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += drunkMath(data.direction, data.curPos);
  }
}

class DrunkAngleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleY -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleY += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleY += drunkMath(data.direction, data.curPos);
  }
}

class DrunkAngleXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleX -= drunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleX += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleX += drunkMath(data.direction, data.curPos);
  }
}

class DrunkScaleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final s:Float = drunkMath(data.direction, data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleZ += s;
    data.scaleY += s;
  }
}

class DrunkScaleXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class DrunkScaleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class DrunkSkewXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewX += drunkMath(data.direction, data.curPos);
  }
}

class DrunkSkewYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.skewY += drunkMath(data.direction, data.curPos);
  }
}

class DrunkSpeedMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 397;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    final modWouldBe:Float = drunkMath(lane, curPos);
    return (modWouldBe + 1);
  }
}

class TanDrunkXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= tanDrunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.x += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tanDrunkMath(data.direction, data.curPos);
  }
}

class TanDrunkYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= tanDrunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.y += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += tanDrunkMath(data.direction, data.curPos);
  }
}

class TanDrunkZMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= tanDrunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.z += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += tanDrunkMath(data.direction, data.curPos);
  }
}

class TanDrunkAngleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.angleZ -= tanDrunkMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleZ += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tanDrunkMath(data.direction, data.curPos);
  }
}

class TanDrunkScaleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final s:Float = tanDrunkMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }
}
