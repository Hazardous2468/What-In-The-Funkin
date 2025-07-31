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
  var mult:ModifierSubValue;
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0);
  }

  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  function getOffset():Float
  {
    return offset.value * (Preferences.downscroll ? -1 : 1);
  }

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    var speed:Float = mult.value;
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(sin(curPos * 0.005 * (speed * 2)));
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    var speed:Float = mult.value;
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(cos(curPos * 0.005 * (speed * 2)));
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    var speed:Float = mult.value;
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
    data.x -= strumResult[data.direction];
    data.x += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.x += strumResult[data.direction];
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
    data.y -= strumResult[data.direction];
    data.y += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.y += strumResult[data.direction];
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
    data.z -= strumResult[data.direction];
    data.z += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.z += strumResult[data.direction];
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
    data.angleZ -= strumResult[data.direction];
    data.angleZ += cosBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos);
    data.angleZ += strumResult[data.direction];
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
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
    data.scaleY += strumResult[data.direction];
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
    data.scaleX += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
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
    data.scaleY += cosBumpyMath(data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = cosBumpyMath(data.curPos) * 0.01;
    data.scaleY += strumResult[data.direction];
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
    data.x -= strumResult[data.direction];
    data.x += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.x += strumResult[data.direction];
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
    data.y -= strumResult[data.direction];
    data.y += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.y += strumResult[data.direction];
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
    data.z -= strumResult[data.direction];
    data.z += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.z += strumResult[data.direction];
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
    var bumpyx_Mult:Float = mult.value;

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
    data.angleZ -= strumResult[data.direction];
    data.angleZ += bumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.angleZ += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.angleX += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.angleY += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
    data.scaleY += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos) * 0.01;
    data.scaleY += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.skewX += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = bumpyMath(data.curPos);
    data.skewY += strumResult[data.direction];
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
    data.x -= strumResult[data.direction];
    data.x += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.x += strumResult[data.direction];
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
    data.y -= strumResult[data.direction];
    data.y += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.y += strumResult[data.direction];
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
    data.z -= strumResult[data.direction];
    data.z += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.z += strumResult[data.direction];
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
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tanBumpyMath(data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.angleZ += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos) * 0.01;
    data.scaleX += strumResult[data.direction];
    data.scaleY += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.skewX += strumResult[data.direction];
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

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    strumResult[data.direction] = tanBumpyMath(data.curPos);
    data.skewY += strumResult[data.direction];
  }
}
