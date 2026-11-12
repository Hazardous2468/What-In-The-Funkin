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
  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name, 0);
    speed = createSubMod("speed", 1.0, ["frequency"]);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    desync = createSubMod("desync", 0.2, ["spacing"]);
    time_add = createSubMod("time_add", 0.0, ["offset", "timeadd", "time_offset", "timeoffset"]);
    sine = createSubMod("sine", 0.0, ["usesine", "sin"]);
    timertype = createSubMod("timertype", 0.0, ["timetype", "timer"]);
  }

  function tanDrunkMath(noteDir:Int, curPos:Float):Float
  {
    var time:Float = (timertype.value >= 0.5 ? beatTime : songTime * 0.001);
    time *= speed.value;
    time += time_add.value;

    final returnValue:Float = currentValue * (tan(
      (time) + (noteDir * desync.value) + (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 1.75
    )) * (ModConstants.strumSize * 0.5);

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
      returnValue = currentValue * (sin(
        (time) + (noteDir * desync.value) + (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 2
      )) * (ModConstants.strumSize * 0.5);
    }
    else
    {
      returnValue = currentValue * (cos(
        (time) + (noteDir * desync.value) + (curPos * 0.45) * (10.0 / FlxG.height) * mult.value * 1.75
      )) * (ModConstants.strumSize * 0.5);
    }

    return returnValue;
  }
}

class DrunkXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "Drunk";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= strumResult[data.direction]; // undo the strum  movement.
    data.x += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.x += strumResult[data.direction];
    }
  }
}

class DrunkYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "DrunkY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= strumResult[data.direction]; // undo the strum  movement.
    data.y += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.y += strumResult[data.direction];
    }
  }
}

class DrunkZMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "DrunkZ";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= strumResult[data.direction]; // undo the strum  movement.
    data.z += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class DrunkAngleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "DrunkAngle";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction]; // undo the strum  movement.
    data.angleZ += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class DrunkAngleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "DrunkAngleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleY += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class DrunkAngleXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "DrunkAngleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleX += drunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = drunkMath(data.direction, data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class DrunkScaleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "DrunkScale";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass) return; // skip math if mod is 0
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
    displayName = "DrunkScaleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass) return; // skip math if mod is 0
    data.scaleX += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class DrunkScaleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "DrunkScaleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass) return; // skip math if mod is 0
    data.scaleY += drunkMath(data.direction, data.curPos) * 0.01;
  }
}

class DrunkSkewXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "DrunkSkewX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass) return; // skip math if mod is 0
    data.skewX += drunkMath(data.direction, data.curPos);
  }
}

class DrunkSkewYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "DrunkSkewY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass) return; // skip math if mod is 0
    data.skewY += drunkMath(data.direction, data.curPos);
  }
}

class DrunkSpeedMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 397;
    displayName = "DrunkSpeed";
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
    invertForDad = true;
    displayName = "TanDrunk";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.x -= strumResult[data.direction]; // undo the strum  movement.
    data.x += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.x += strumResult[data.direction];
    }
  }
}

class TanDrunkYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.y -= strumResult[data.direction]; // undo the strum  movement.
    data.y += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.y += strumResult[data.direction];
    }
  }
}

class TanDrunkZMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkZ";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return; // skip math if mod is 0
    data.z -= strumResult[data.direction]; // undo the strum  movement.
    data.z += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class TanDrunkAngleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "TanDrunkAngle";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction]; // undo the strum  movement.
    data.angleZ += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class TanDrunkAngleXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "TanDrunkAngleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleX += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class TanDrunkAngleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
    displayName = "TanDrunkAngleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.angleY += tanDrunkMath(data.direction, data.curPos); // re apply but now with notePos
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class TanDrunkScaleMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkScale";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    final s:Float = tanDrunkMath(data.direction, data.curPos);
    data.scaleX += s * 0.01;
    data.scaleZ += s * 0.01;
    data.scaleY += s * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      final s:Float = tanDrunkMath(data.direction, data.curPos) * 0.01;
      strumResult[data.direction] = s;
      data.scaleX += s;
      data.scaleZ += s;
      data.scaleY += s;
    }
  }
}

class TanDrunkScaleYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkScaleY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.scaleY += tanDrunkMath(data.direction, data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class TanDrunkScaleXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkScaleX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.scaleX += tanDrunkMath(data.direction, data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class TanDrunkSkewXMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkSkewX";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.skewX += tanDrunkMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class TanDrunkSkewYMod extends DrunkModBase
{
  public function new(name:String)
  {
    super(name);
    displayName = "TanDrunkSkewY";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return; // skip math if mod is 0
    data.skewY += tanDrunkMath(data.direction, data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanDrunkMath(data.direction, data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}
