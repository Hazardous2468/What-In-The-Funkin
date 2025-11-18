package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related tornado
// :p
class TornadoModBase extends Modifier
{
  var speed:ModifierSubValue;
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    speed = createSubMod("speed", 3.0, ["mult", "period", "size"]);
    offset = createSubMod("offset", 0.0);
  }

  // An array which represents each arrow direction. Used to undo the strum movement for the notes for the offset submod to function
  var strumResult:Array<Float> = [0, 0, 0, 0];

  function tornadoMath(lane:Int, curPos:Float):Float
  {
    final swagWidth:Float = ModConstants.strumSize;
    curPos += offset.value * (Preferences.downscroll ? -1 : 1);
    final playerColumn:Float = lane % Strumline.KEY_COUNT;
    final columnPhaseShift = playerColumn * Math.PI / 3;
    final phaseShift = (curPos / 135) * speed.value * 0.2;
    final returnReceptorToZeroOffsetX = (-cos(-columnPhaseShift) + 1) / 2 * swagWidth * 3;
    final offsetX = (-cos((phaseShift - columnPhaseShift)) + 1) / 2 * swagWidth * 3 - returnReceptorToZeroOffsetX;

    return offsetX;
  }

  function tanTornadoMath(lane:Int, curPos:Float):Float
  {
    final swagWidth:Float = ModConstants.strumSize;
    curPos += offset.value * (Preferences.downscroll ? -1 : 1);
    final playerColumn:Float = lane % Strumline.KEY_COUNT;
    final columnPhaseShift = playerColumn * Math.PI / 3;
    final phaseShift = (curPos / 135) * speed.value * 0.2;
    final returnReceptorToZeroOffsetX = (-tan(-columnPhaseShift) + 1) / 2 * swagWidth * 3;
    final offsetX = (-tan((phaseShift - columnPhaseShift)) + 1) / 2 * swagWidth * 3 - returnReceptorToZeroOffsetX;

    return offsetX;
  }
}

class TornadoXMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction];
    data.x += tornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.x += strumResult[data.direction];
    }
  }
}

class TornadoYMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += tornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.y += strumResult[data.direction];
    }
  }
}

class TornadoZMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += tornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.z += strumResult[data.direction];
    }
  }
}

class TornadoAngleMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = false;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class TornadoScaleMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tornadoMath(data.direction, data.curPos) * currentValue * 0.01;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
      data.scaleY += strumResult[data.direction];
      data.scaleZ += strumResult[data.direction];
    }
  }
}

class TornadoScaleXMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue * 0.01;
      data.scaleX += strumResult[data.direction];
    }
  }
}

class TornadoScaleYMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleY += r * 0.01;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue * 0.01;
      data.scaleY += strumResult[data.direction];
    }
  }
}

class TornadoSkewXMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.skewX += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.skewX += strumResult[data.direction];
    }
  }
}

class TornadoSkewYMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.skewY += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || offset.value == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tornadoMath(data.direction, data.curPos) * currentValue;
      data.skewY += strumResult[data.direction];
    }
  }
}

class TanTornadoXMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x -= strumResult[data.direction]; // undo the strum  movement.
    data.x += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tanTornadoMath(data.direction, data.curPos) * currentValue;
      data.x += strumResult[data.direction];
    }
  }
}

class TanTornadoYMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y -= strumResult[data.direction];
    data.y += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tanTornadoMath(data.direction, data.curPos) * currentValue;
      data.y += strumResult[data.direction];
    }
  }
}

class TanTornadoZMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z -= strumResult[data.direction];
    data.z += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tanTornadoMath(data.direction, data.curPos) * currentValue;
      data.z += strumResult[data.direction];
    }
  }
}

class TanTornadoAngleMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = false;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ -= strumResult[data.direction];
    data.angleZ += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0)
    {
      strumResult[data.direction] = 0.0;
    }
    else
    {
      strumResult[data.direction] = tanTornadoMath(data.direction, data.curPos) * currentValue;
      data.angleZ += strumResult[data.direction];
    }
  }
}

class TanTornadoScaleMod extends TornadoModBase
{
  public function new(name:String)
  {
    super(name);
    unknown = false;

    specialMod = false;
    pathMod = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tanTornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final r:Float = tanTornadoMath(data.direction, data.curPos) * currentValue;
    strumResult[data.direction] = r;
    data.scaleX += r * 0.01;
    data.scaleY += r * 0.01;
    data.scaleZ += r * 0.01;
  }
}
