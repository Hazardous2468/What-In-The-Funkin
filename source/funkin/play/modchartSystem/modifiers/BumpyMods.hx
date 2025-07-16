package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related bumpy mods
// :p
class BumpyModBase extends Modifier
{
  var mult:ModifierSubValue;
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0);
  }

  function getOffset():Float
  {
    return offset.value * (Preferences.downscroll ? -1 : 1);
  }

  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    curPos += getOffset();
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * sin(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    curPos += getOffset();
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * cos(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    curPos += getOffset();
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * tan(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }
}

class CosBumpyXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= strumResult[data.direction];
    data.x += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.x += strumResult[data.direction];
  }
}

class CosBumpyYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.y += strumResult[data.direction];
  }
}

class CosBumpyZMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= strumResult[data.direction];
    data.z += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.z += strumResult[data.direction];
  }
}

class CosBumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ -= strumResult[data.direction];
    data.angleZ += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.angleZ += strumResult[data.direction];
  }
}

class CosBumpyAngleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleY += cosBumpyMath(data.curPos);
  }
}

class CosBumpyAngleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleX += cosBumpyMath(data.curPos);
  }
}

class CosBumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var r:Float = cosBumpyMath(data.curPos) * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
    data.scaleY += strumResult[data.direction];
    data.scaleZ += strumResult[data.direction];
  }
}

class CosBumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
  }
}

class CosBumpyScaleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }
}

class CosBumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += cosBumpyMath(data.curPos);
  }
}

class CosBumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += cosBumpyMath(data.curPos);
  }
}

class BumpyXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= strumResult[data.direction];
    data.x += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.x += strumResult[data.direction];
    }
  }
}

class BumpyYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.y += strumResult[data.direction];
    }
  }
}

class BumpyZMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= strumResult[data.direction];
    data.z += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class BumpySpeedMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 397;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var bumpyx_Mult:Float = mult.value;
    curPos += getOffset();
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    var modWouldBe:Float = currentValue * 0.025 * sin(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * bumpyx_Mult) * (Strumline.STRUMLINE_SIZE / 2.0);
    return (modWouldBe + 1);
  }
}

class BumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ -= strumResult[data.direction];
    data.angleZ += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class BumpyAngleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class BumpyAngleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.angleY += strumResult[data.direction];
    }
  }
}

class BumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var daBumpyMath:Float = bumpyMath(data.curPos) * 0.01;
    data.scaleX += daBumpyMath;
    data.scaleY += daBumpyMath;
    data.scaleZ += daBumpyMath;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class BumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += bumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class BumpyScaleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += bumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class BumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class BumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class TanBumpyXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= strumResult[data.direction];
    data.x += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.x += strumResult[data.direction];
    }
  }
}

class TanBumpyYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= strumResult[data.direction];
    data.y += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.y += strumResult[data.direction];
    }
  }
}

class TanBumpyZMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= strumResult[data.direction];
    data.z += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class TanBumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class TanBumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var daTanBumpy:Float = tanBumpyMath(data.curPos) * 0.01;
    data.scaleX += daTanBumpy;
    data.scaleY += daTanBumpy;
    data.scaleZ += daTanBumpy;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class TanBumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += tanBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class TanBumpyScaleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += tanBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class TanBumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class TanBumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (getOffset() == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}
