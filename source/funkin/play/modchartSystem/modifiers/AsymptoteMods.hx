package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class AsymptoteModBase extends Modifier
{
  // If above 0.0, will have an effect similar to attenuate. Othewise disable the effect
  var doLaneOffset:ModifierSubValue;

  // The size / magnitude of the effect
  var magnitude:ModifierSubValue;

  // Offset the entire effect by this amount in MS
  var offset:ModifierSubValue;

  // Which curPos to use?
  var altCurposSubmod:ModifierSubValue;

  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name);
    offset = createSubMod("offset", 0.0);
    doLaneOffset = createSubMod("lane", 1.0, [
      "laneoffset",
      "direction",
      "directionoffset",
      "dodirection",
      "dodirectionoffset",
      "dolaneoffset",
      "dolane"
    ]);
    magnitude = createSubMod("magnitude", 1.0, ["speed", "mult", "period", "size"]);
    altCurposSubmod = createSubMod("altcurpos", 0.0, ["use_unscaled", "alt_curpos", "type"]);
  }

  // Warning, too many zeros and we end up crashing while trying to do the math!
  final smallestVal:Float = 0.0000001;

  function daMath(data:NoteData):Float
  {
    if (this.currentValue == 0) return 0;
    // Botched together based on eye from NotITG
    var pos:Float = useUnscaledCurpos ? data.curPos_unscaled : data.curPos;
    pos += offset.value * 10;
    pos *= 0.0005;
    if (pos == 0) pos = smallestVal; // prevent divide by 0

    final newPos = doLaneOffset.value >= 0.5 ? data.direction - (Strumline.KEY_COUNT - 1) / 2 : 1;

    var result:Float = this.currentValue * (1.0 + magnitude.value / pos) * -newPos;
    if (Math.isNaN(result) || !Math.isFinite(result)) result = 0;

    return result;
  }
}

class AsymptoteXMod extends AsymptoteModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= strumResult[data.direction];
    data.x += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(data);
      data.x += strumResult[data.direction];
    }
  }
}

class AsymptoteYMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(data);
      data.y += strumResult[data.direction];
    }
  }
}

class AsymptoteZMod extends AsymptoteModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= strumResult[data.direction];
    data.z += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(data);
      data.z += strumResult[data.direction];
    }
  }
}

class AsymptoteAngleXMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleX += daMath(data);
  }
}

class AsymptoteAngleYMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleY += daMath(data);
  }
}

class AsymptoteAngleZMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ -= strumResult[data.direction];
    data.angleZ += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = daMath(data);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class AsymptoteScaleMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    final r = daMath(data);
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }
}

class AsymptoteScaleXMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += daMath(data);
  }
}

class AsymptoteScaleYMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleY += daMath(data);
  }
}

class AsymptoteSkewYMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    doLaneOffset.baseValue = doLaneOffset.baseValue = 0;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += daMath(data);
  }
}

class AsymptoteSkewXMod extends AsymptoteModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = false;
    strumsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += daMath(data);
  }
}
