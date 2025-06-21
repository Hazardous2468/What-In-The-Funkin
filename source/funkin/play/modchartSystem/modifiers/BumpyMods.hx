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
  public function new(name:String)
  {
    super(name, 0);
    createSubMod("mult", 1.0);
  }

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * sin(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * getSubVal("mult")) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * cos(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * getSubVal("mult")) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * tan(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * getSubVal("mult")) * (Strumline.STRUMLINE_SIZE / 2.0);
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
    data.x -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.x += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.x += cosBumpyMath(data.curPos);
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
    data.y -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.y += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += cosBumpyMath(data.curPos);
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
    data.z -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.z += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.z += cosBumpyMath(data.curPos);
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
    data.angleZ -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.angleZ += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleZ += cosBumpyMath(data.curPos);
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
    data.angleY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
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
    data.angleX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
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
    data.scaleX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0) * 0.01;
    data.scaleY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0) * 0.01;
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
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
    data.scaleY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0) * 0.01;
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
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
    data.scaleX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0) * 0.01;
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
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
    data.skewX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
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
    data.skewY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
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
    data.x += bumpyMath(data.curPos);
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
    data.y += bumpyMath(data.curPos);
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
    data.z += bumpyMath(data.curPos);
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
    var bumpyx_Mult:Float = getSubVal("mult");

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
    data.angleZ += bumpyMath(data.curPos);
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
}

class BumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += bumpyMath(data.curPos) * 0.01;
    data.scaleY += bumpyMath(data.curPos) * 0.01;
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
}

class TanBumpyXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x += tanBumpyMath(data.curPos);
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
    data.y += tanBumpyMath(data.curPos);
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
    data.z += tanBumpyMath(data.curPos);
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
    data.angleZ += tanBumpyMath(data.curPos);
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
    data.scaleX += tanBumpyMath(data.curPos);
    data.scaleY += tanBumpyMath(data.curPos);
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
}
