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
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.old3Dholds = (currentValue > 0.5 ? true : false);
  }
}

class SpiralHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    // strumLine.mods.spiralHolds[lane] = (currentValue > 0.5 ? true : false);
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.spiralHolds = (currentValue > 0.5 ? true : false);
  }
}

class HoldGrainMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 82);
    unknown = false;
    specialMod = true;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.holdGrain = currentValue;

    // strumLine.mods.holdGrain_Lane[lane] = currentValue;
  }
}

class LongHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.longHolds = currentValue;
    // strumLine.mods.longHolds[lane] = currentValue;
  }
}

class StraightHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.straightHolds = currentValue;
    // strumLine.mods.straightHolds[lane] = currentValue;
  }
}
