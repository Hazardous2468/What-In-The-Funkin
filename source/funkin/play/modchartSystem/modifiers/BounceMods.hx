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
  var altCurposSubmod:ModifierSubValue;
  var useUnscaledCurpos(get, never):Bool;

  function get_useUnscaledCurpos():Bool
  {
    return altCurposSubmod.value >= 0.5;
  }

  public function new(name:String)
  {
    super(name, 0);
    mult = createSubMod("mult", 1.0, ["period", "size"]);
    offset = createSubMod("offset", 0.0);
    altCurposSubmod = createSubMod("altcurpos", 0.0, ["use_unscaled", "alt_curpos", "type"]);
  }

  function getOffset():Float
  {
    return offset.value * (Preferences.downscroll ? -1 : 1);
  }

  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    final speed:Float = mult.value;
    // final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(sin(curPos * 0.005 * (speed * 2)));
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    final speed:Float = mult.value;
    // final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(cos(curPos * 0.005 * (speed * 2)));
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    curPos += getOffset();
    final speed:Float = mult.value;
    // final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(tan(curPos * 0.005 * (speed * 2)));
  }
}

class CosBounceXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.x -= strumResult[data.direction];
    data.x += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.x += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.y -= strumResult[data.direction];
    data.y += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.y += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.z -= strumResult[data.direction];
    data.z += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class CosBounceAngleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class CosBounceAngleYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleY += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    final s:Float = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleY += s;
    data.scaleZ += s;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class CosBounceSkewXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class CosBounceSkewYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class BounceXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.x -= strumResult[data.direction];
    data.x += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.x += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.y -= strumResult[data.direction];
    data.y += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.y += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.z -= strumResult[data.direction];
    data.z += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.z += strumResult[data.direction];
    }
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
    final bumpyx_Mult:Float = mult.value;
    final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    final modWouldBe:Float = currentValue * 0.025 * sin(
      curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * bumpyx_Mult
    ) * (Strumline.STRUMLINE_SIZE / 2.0);
    return (modWouldBe + 1);
  }
}

class BounceAngleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class BounceAngleYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleY += strumResult[data.direction];
    }
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
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    final s:Float = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleY += s;
    data.scaleZ += s;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.scaleY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class BounceSkewXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class BounceSkewYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}

class TanBounceXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.x -= strumResult[data.direction];
    data.x += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.x += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.y -= strumResult[data.direction];
    data.y += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.y += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.z -= strumResult[data.direction];
    data.z += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.z += strumResult[data.direction];
    }
  }
}

class TanBounceAngleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleZ += strumResult[data.direction];
    }
  }
}

class TanBounceAngleXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleX += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleX += strumResult[data.direction];
    }
  }
}

class TanBounceAngleYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.angleY += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.angleY += strumResult[data.direction];
    }
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
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    final s:Float = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleY += s;
    data.scaleZ += s;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class TanBounceSkewXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewX += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewX += strumResult[data.direction];
    }
  }
}

class TanBounceSkewYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor" || data.inOrientPass) return;
    data.skewY += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass || currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
      data.skewY += strumResult[data.direction];
    }
  }
}
