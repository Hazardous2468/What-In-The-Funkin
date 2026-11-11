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
    displayName = "OffsetPerspectiveCenterX";
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
    displayName = "OffsetPerspectiveCenterY";
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
    displayName = "OffsetNotesX";
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
    displayName = "OffsetNotesY";
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
    displayName = "OffsetNotesZ";
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
    displayName = "OffsetHoldsX";
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
    displayName = "OffsetHoldsY";
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
    displayName = "OffsetHoldsZ";
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
    displayName = "OffsetStrumsX";
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
    displayName = "OffsetStrumsY";
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
    displayName = "OffsetStrumsZ";
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
    displayName = "OffsetPathX";
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
    displayName = "OffsetPathY";
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
    displayName = "OffsetPathZ";
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
    displayName = "MeshSkewOffsetX";
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
    displayName = "MeshSkewOffsetY";
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
    displayName = "MeshSkewOffsetZ";
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
    displayName = "MeshPivotOffsetX";
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
    displayName = "MeshPivotOffsetY";
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
    displayName = "MeshPivotOffsetZ";
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
