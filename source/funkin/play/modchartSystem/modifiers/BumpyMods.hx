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
    altCurposSubmod = createSubMod("altcurpos", 1.0, ["use_unscaled", "alt_curpos", "type"]);
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
    final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * sin(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function cosBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    curPos += getOffset();
    final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * cos(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0
    curPos += getOffset();
    final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * tan(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * mult.value) * (Strumline.STRUMLINE_SIZE / 2.0);
  }
}

class CosBumpyXMod extends BumpyModBase
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

class CosBumpyYMod extends BumpyModBase
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

class CosBumpyZMod extends BumpyModBase
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

class CosBumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
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

class CosBumpyAngleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      data.angleY += strumResult[data.direction];
    }
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
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      data.angleX += strumResult[data.direction];
    }
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
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    var s:Float = cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += s;
    data.scaleY += s;
    data.scaleZ += s;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class CosBumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class CosBumpyScaleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class CosBumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewX += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      data.skewX += strumResult[data.direction];
    }
  }
}

class CosBumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += cosBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
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
      data.skewY += strumResult[data.direction];
    }
  }
}

class BumpyXMod extends BumpyModBase
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

class BumpyYMod extends BumpyModBase
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

class BumpyZMod extends BumpyModBase
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
    final bumpyx_Mult:Float = mult.value;
    curPos += getOffset();
    final scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    final modWouldBe:Float = currentValue * 0.025 * sin(
      curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * bumpyx_Mult
    ) * (Strumline.STRUMLINE_SIZE / 2.0);
    return (modWouldBe + 1);
  }
}

class BumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpyAngleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpyAngleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    final daBumpyMath:Float = bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += daBumpyMath;
    data.scaleY += daBumpyMath;
    data.scaleZ += daBumpyMath;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpyScaleYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewX += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class BumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += bumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class TanBumpyXMod extends BumpyModBase
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

class TanBumpyYMod extends BumpyModBase
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

class TanBumpyZMod extends BumpyModBase
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

class TanBumpyAngleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class TanBumpyScaleMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    final daTanBumpy:Float = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
    data.scaleX += daTanBumpy;
    data.scaleY += daTanBumpy;
    data.scaleZ += daTanBumpy;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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

class TanBumpyScaleXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass) return;
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0;
    }
    else
    {
      strumResult[data.direction] = tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
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
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos) * 0.01;
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
      data.scaleY += strumResult[data.direction];
    }
  }
}

class TanBumpySkewXMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
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

class TanBumpySkewYMod extends BumpyModBase
{
  public function new(name:String)
  {
    super(name);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass || currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += tanBumpyMath(useUnscaledCurpos ? data.curPos_unscaled : data.curPos);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || data.inOrientPass)
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
