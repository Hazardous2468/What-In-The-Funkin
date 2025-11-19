package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class AttenuateModBase extends Modifier
{
  var offset:ModifierSubValue;
  var strumResult:Array<Float> = [0, 0, 0, 0];

  public function new(name:String)
  {
    super(name);
    offset = createSubMod("offset", 0.0);
  }

  function daMath(data:NoteData):Float
  {
    if (currentValue == 0) return 0;

    // Botched together based on eye from NotITG

    final nd = data.direction % Strumline.KEY_COUNT;
    final newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p += offset.value;
    p = (p * p) * 0.1;

    final curVal:Float = currentValue * 0.0015;

    var result:Float = 0;
    result += newPos * curVal * p;
    result += curVal * p * 0.5;
    return result;
  }
}

class AttenuateXMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= strumResult[data.direction];
    data.x += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.x += strumResult[data.direction];
  }
}

class AttenuateYMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.y += strumResult[data.direction];
  }
}

class AttenuateZMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= strumResult[data.direction];
    data.z += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.z += strumResult[data.direction];
  }
}

class AttenuateAngleMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ -= strumResult[data.direction];
    data.angleZ += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.angleZ += strumResult[data.direction];
  }
}

class AttenuateAngleXMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.angleX += strumResult[data.direction];
  }
}

class AttenuateAngleYMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.angleY += strumResult[data.direction];
  }
}

class AttenuateSkewXMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.skewX += strumResult[data.direction];
  }
}

class AttenuateSkewYMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += daMath(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data);
    data.skewY += strumResult[data.direction];
  }
}

class AttenuateScaleMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    final daResult:Float = daMath(data) * 0.01;
    data.scaleX += daResult;
    data.scaleY += daResult;
    data.scaleZ += daResult;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data) * 0.01;
    data.scaleX += strumResult[data.direction];
    data.scaleY += strumResult[data.direction];
    data.scaleZ += strumResult[data.direction];
  }
}

class AttenuateScaleXMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += daMath(data) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data) * 0.01;
    data.scaleX += strumResult[data.direction];
  }
}

class AttenuateScaleYMod extends AttenuateModBase
{
  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += daMath(data) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = daMath(data) * 0.01;
    data.scaleY += strumResult[data.direction];
  }
}
