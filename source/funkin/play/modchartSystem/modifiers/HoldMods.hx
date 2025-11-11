package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.notes.StrumlineNote;

// Contains all mods that modify holds!
class Old3DHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.old3Dholds = (currentValue > 0.5 ? true : false);
  }
}

class HoldTypeMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.holdType = currentValue;
  }
}

class HoldGrainMod extends Modifier
{
  public function new(name:String)
  {
    super(name, ModConstants.defaultHoldGrain);
    unknown = false;
    holdsMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.holdGrain = currentValue;
  }
}

class LongHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.longHolds += currentValue;
  }
}

class StraightHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.straightHolds += currentValue;
  }
}
