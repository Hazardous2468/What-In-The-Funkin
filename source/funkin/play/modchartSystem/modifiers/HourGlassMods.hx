package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related hourglass mods
// Custom mod made by me (Hazard24)!
class HourGlassModBase extends Modifier
{
  // The point where the notes start moving
  var start:ModifierSubValue;

  // The point where the notes finish moving
  var end:ModifierSubValue;

  // Offsets the start and end points by this amount
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    start = createSubMod("start", 420.0);
    end = createSubMod("end", 135.0);
    offset = createSubMod("offset", 0.0);
  }

  // Basically just a copy of Sudden math with an extra step (b and c)
  function hourGlassMath(data:NoteData):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0

    final pos:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    // var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);

    // Copy of Sudden math
    var a:Float = FlxMath.remapToRange(pos, start.value + offset.value, end.value + offset.value, 1, 0);
    a = FlxMath.bound(a, 0, 1); // clamp

    final b:Float = 1 - a;
    final c:Float = (FlxMath.fastCos(b * Math.PI) / 2) + 0.5;

    return c;
  }
}

class HourGlassX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.x += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.y += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassZ extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.z += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassAngleX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.angleX += c * (currentValue * -1);
  }
}

class HourGlassAngleZ extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.angleZ += c * (currentValue * -1);
  }
}

class HourGlassAngleY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.angleY += c * (currentValue * -1);
  }
}

class HourGlassSkewX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.skewX += c * (currentValue * -2);
  }
}

class HourGlassSkewY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.skewY += c * (currentValue * -2);
  }
}

class HourGlassScaleX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += hourGlassMath(data) * currentValue;
  }
}

class HourGlassScaleY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += hourGlassMath(data) * currentValue;
  }
}

class HourGlassScale extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final c:Float = hourGlassMath(data);
    data.scaleX += c * currentValue;
    data.scaleY += c * currentValue;
    data.scaleZ += c * currentValue;
  }
}
