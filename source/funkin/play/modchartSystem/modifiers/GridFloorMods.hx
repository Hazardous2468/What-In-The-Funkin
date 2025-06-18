package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

class GridModBase extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -666;
    notPercentage = true;
  }

  function toGrid(pos:Float):Float
  {
    var returnValue:Float = pos;
    // var s:Float = getSubVal("size");
    var s:Float = currentValue;
    if (s != 0)
    {
      returnValue = Math.floor(pos / s) * s;
    }
    return returnValue;
  }
}

class GridXYZModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
    data.y = toGrid(data.y);
    data.z = toGrid(data.z);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
    data.y = toGrid(data.y);
    data.z = toGrid(data.z);
  }
}

class GridXModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
  }
}

class GridYModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y = toGrid(data.y);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y = toGrid(data.y);
  }
}

class GridZModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z = toGrid(data.z);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z = toGrid(data.z);
  }
}

/*
  class GridSpeedModifier extends GridModBase
  {
  public function new(name:String)
  {
    super(name);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var modWouldBe:Float = toGrid(curPos);
    return (modWouldBe + 1);
  }
  }
 */
class GridAngleModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ = toGrid(data.angleZ);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ = toGrid(data.angleZ);
  }
}

class GridStrumXYZModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = modPriority - 3;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
    data.y = toGrid(data.y);
    data.z = toGrid(data.z);
  }
}

class GridStrumXModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = modPriority - 3;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x = toGrid(data.x);
  }
}

class GridStrumYModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = modPriority - 3;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y = toGrid(data.y);
  }
}

class GridStrumZModifier extends GridModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = modPriority - 3;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z = toGrid(data.z);
  }
}
