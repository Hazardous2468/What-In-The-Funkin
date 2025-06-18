package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all mods which are unique or have debug purposes!
class DebugXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -8;
    unknown = false;
    specialMod = true;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.debugTxtOffsetX = currentValue;
  }
}

class DebugYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -9;
    unknown = false;
    notPercentage = true;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.debugTxtOffsetY = currentValue;
  }
}

class DebugAlphaMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -8;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.txtActiveMods.alpha = 1 - currentValue;
  }
}

class DebugTxtExtraShow extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -14;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.debugHideUtil = currentValue > 0.5 ? false : true;
  }
}

class DebugTxtZeroValueShow extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -13;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.hideZeroValueMods = currentValue > 0.5 ? false : true;
  }
}

class DebugTxtLaneShow extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -12;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.debugHideLane = currentValue > 0.5 ? false : true;
  }
}

class DebugTxtAllShow extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -10;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.debugShowALL = currentValue > 0.5 ? true : false;
  }
}

class DebugTxtSubShow extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -11;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.hideSubMods = currentValue > 0.5 ? false : true;
  }
}
