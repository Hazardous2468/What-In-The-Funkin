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
    speed = createSubMod("speed", 3.0, ["mult", "period"]);
    offset = createSubMod("offset", 0.0);
  }

  function tornadoMath(lane:Int, curPos:Float):Float
  {
    var swagWidth:Float = ModConstants.strumSize;

    var playerColumn:Float = lane % Strumline.KEY_COUNT;
    var columnPhaseShift = playerColumn * Math.PI / 3;
    var phaseShift = (curPos / 135) * speed.value * 0.2;
    var returnReceptorToZeroOffsetX = (-cos(-columnPhaseShift) + 1) / 2 * swagWidth * 3;
    var offsetX = (-cos((phaseShift - columnPhaseShift)) + 1) / 2 * swagWidth * 3 - returnReceptorToZeroOffsetX;

    return offsetX;
  }

  function tanTornadoMath(lane:Int, curPos:Float):Float
  {
    var swagWidth:Float = ModConstants.strumSize;

    var playerColumn:Float = lane % Strumline.KEY_COUNT;
    var columnPhaseShift = playerColumn * Math.PI / 3;
    var phaseShift = (curPos / 135) * speed.value * 0.2;
    var returnReceptorToZeroOffsetX = (-tan(-columnPhaseShift) + 1) / 2 * swagWidth * 3;
    var offsetX = (-tan((phaseShift - columnPhaseShift)) + 1) / 2 * swagWidth * 3 - returnReceptorToZeroOffsetX;

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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tornadoMath(data.direction, data.curPos) * currentValue;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += tornadoMath(data.direction, data.curPos) * currentValue;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += tornadoMath(data.direction, data.curPos) * currentValue;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tornadoMath(data.direction, data.curPos) * currentValue;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r * 0.01;
    data.scaleY += r * 0.01;
    data.scaleZ += r * 0.01;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r * 0.01;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleY += r * 0.01;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.skewX += r;
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
    strumsMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tornadoMath(data.direction, data.curPos) * currentValue;
    data.skewY += r;
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
    data.x -= tanTornadoMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.x += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += tanTornadoMath(data.direction, data.curPos) * currentValue;
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
    data.y -= tanTornadoMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.y += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.y += tanTornadoMath(data.direction, data.curPos) * currentValue;
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
    data.z -= tanTornadoMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.z += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.z += tanTornadoMath(data.direction, data.curPos) * currentValue;
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
    data.angleZ -= tanTornadoMath(data.direction, data.whichStrumNote?.strumDistance ?? 0); // undo the strum  movement.
    data.angleZ += tanTornadoMath(data.direction, data.curPos) * currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.angleZ += tanTornadoMath(data.direction, data.curPos) * currentValue;
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
    var r:Float = tanTornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r;
    data.scaleY += r;
    data.scaleZ += r;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var r:Float = tanTornadoMath(data.direction, data.curPos) * currentValue;
    data.scaleX += r * 0.01;
    data.scaleY += r * 0.01;
    data.scaleZ += r * 0.01;
  }
}
