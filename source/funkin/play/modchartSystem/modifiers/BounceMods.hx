package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related bounce mods (it's like bumpy but always positive values)
// :p
class BounceModBase extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    createSubMod("mult", 1.0);
  }

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    var speed:Float = getSubVal("mult");
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(sin(curPos * 0.005 * (speed * 2)));
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    var speed:Float = getSubVal("mult");
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(cos(curPos * 0.005 * (speed * 2)));
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    var speed:Float = getSubVal("mult");
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(tan(curPos * 0.005 * (speed * 2)));
  }
}

class CosBounceXMod extends BounceModBase
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

class CosBounceYMod extends BounceModBase
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

class CosBounceZMod extends BounceModBase
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

class CosBounceAngleMod extends BounceModBase
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

class CosBounceAngleXMod extends BounceModBase
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

class CosBounceAngleYMod extends BounceModBase
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

class CosBounceScaleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.scaleY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += cosBumpyMath(data.curPos);
    data.scaleY += cosBumpyMath(data.curPos);
  }
}

class CosBounceScaleXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleX += cosBumpyMath(data.curPos);
  }
}

class CosBounceScaleYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY -= cosBumpyMath(data.whichStrumNote?.strumDistance ?? 0);
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.scaleY += cosBumpyMath(data.curPos);
  }
}

class CosBounceSkewXMod extends BounceModBase
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

class CosBounceSkewYMod extends BounceModBase
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

class BounceXMod extends BounceModBase
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

class BounceYMod extends BounceModBase
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

class BounceZMod extends BounceModBase
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

class BounceSpeedMod extends BounceModBase
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

class BounceAngleMod extends BounceModBase
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

class BounceAngleXMod extends BounceModBase
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

class BounceAngleYMod extends BounceModBase
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

class BounceScaleMod extends BounceModBase
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

class BounceScaleXMod extends BounceModBase
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

class BounceScaleYMod extends BounceModBase
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

class BounceSkewXMod extends BounceModBase
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

class BounceSkewYMod extends BounceModBase
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

class TanBounceXMod extends BounceModBase
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

class TanBounceYMod extends BounceModBase
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

class TanBounceZMod extends BounceModBase
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

class TanBounceAngleMod extends BounceModBase
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

class TanBounceScaleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += tanBumpyMath(data.curPos) * 0.01;
    data.scaleY += tanBumpyMath(data.curPos) * 0.01;
  }
}

class TanBounceSkewXMod extends BounceModBase
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

class TanBounceSkewYMod extends BounceModBase
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
