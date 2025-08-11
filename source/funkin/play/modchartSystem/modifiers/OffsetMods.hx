package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to offset!

class PerspectiveCenterOffsetXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 9999;
    notPercentage = true;
    unknown = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
  }

  function applyThing(data:NoteData):Void
  {
    data.perspectiveOffset.x = currentValue;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    applyThing(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    applyThing(data);
  }
}

class PerspectiveCenterOffsetYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 9999;
    notPercentage = true;
    unknown = false;
    pathMod = true;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
  }

  function applyThing(data:NoteData):Void
  {
    data.perspectiveOffset.y = currentValue;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    applyThing(data);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    applyThing(data);
  }
}

class NoteOffsetXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x += currentValue;
  }
}

class NoteOffsetYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y += currentValue;
  }
}

class NoteOffsetZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z += currentValue;
  }
}

class HoldOffsetXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isHoldNote) data.x += currentValue;
  }
}

class HoldOffsetYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isHoldNote) data.y += currentValue;
  }
}

class HoldOffsetZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isHoldNote) data.z += currentValue;
  }
}

class StrumOffsetXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x -= currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.x += currentValue;
  }
}

class StrumOffsetYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y -= currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += currentValue;
  }
}

class StrumOffsetZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z -= currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.z += currentValue;
  }
}

class ArrowPathOffsetXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath) data.x += currentValue;
  }
}

class ArrowPathOffsetYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath) data.y += currentValue;
  }
}

class ArrowPathOffsetZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -670;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath) data.z += currentValue;
  }
}

class MeshSkewOffsetX extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_SkewX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_SkewX += currentValue;
  }
}

class MeshSkewOffsetY extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    notPercentage = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_SkewY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_SkewY += currentValue;
  }
}

class MeshSkewOffsetZ extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_SkewZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_SkewZ += currentValue;
  }
}

class MeshPivotOffsetX extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    notPercentage = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_PivotX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_PivotX += currentValue;
  }
}

class MeshPivotOffsetY extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    notPercentage = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_PivotY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_PivotY += currentValue;
  }
}

class MeshPivotOffsetZ extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    notPercentage = true;
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = false;
    speedMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.meshOffsets_PivotZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.meshOffsets_PivotZ += currentValue;
  }
}
