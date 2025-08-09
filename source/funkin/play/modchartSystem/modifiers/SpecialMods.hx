package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;

// Contains all mods which are unique or have debug purposes!

class SinClip extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    baseValue = 1;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.sinClip = currentValue;
  }
}

class CosClip extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    baseValue = 1;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.cosClip = currentValue;
  }
}

class Cosecant extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    modPriority = 500;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.useCosecant = currentValue >= 0.5;
  }
}

class TanClip extends Modifier
{
  public function new(name:String)
  {
    // Can't use inf otherwise eases break.
    super(name, /*Math.POSITIVE_INFINITY*/ 10000);
    unknown = false;
    specialMod = true;
    modPriority = 500;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.tanClip = currentValue;
  }
}

class SinOffset extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.sinOffset = currentValue;
  }
}

class CosOffset extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.cosOffset = currentValue;
  }
}

class TanOffset extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.tanOffset = currentValue;
  }
}

class CosecantOffset extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    modPriority = 500;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.cosecantOffset = currentValue;
  }
}

// If enabled, *all* sprites will be sorted by their z value! Can lead to holds and arrowpath being infront of receptors / notes!
class ZSortMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    // IMPORTANT NOTE -> ONLY WORKS FOR BOYFRIEND!
    if (strumLine != PlayState.instance.playerStrumline) return;
    if (currentValue >= 0.5)
    {
      PlayState.instance.noteRenderMode = true;
      strumLine.zSortMode = true; // Doesn't really matter what it's set too here, right?
    }
    else if (currentValue < 0.0)
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = false;
    }
    else
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = true;
    }
  }
}

// If enabled,.. errr... 3D?
class ThreeDProjection extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.whichStrumNote.strumExtraModData.threeD = currentValue >= 0.5;
  }
}

class MathCutOffMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    notPercentage = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.mathCutOff = currentValue;
    // strumLine.mods.mathCutOff[lane] = currentValue;
  }
}

class NoteSplashCopyStrumScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = 400;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.splashCopyStrumScale = currentValue >= 0.5;
  }
}

class HoldCoverCopyStrumScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = 400;
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.holdCoverCopyStrumScale = currentValue >= 0.5;
  }
}

class DisableHoldMathShortCutMod extends Modifier
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
    whichStrum.strumExtraModData.noHoldMathShortcut = currentValue;
  }
}

class DrawDistanceBackMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.drawdistanceBack = currentValue;
  }
}

class DrawDistanceMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.drawdistanceForward = currentValue;
  }
}

class InvertModValues extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.invertValues = currentValue < 0.5 ? false : true;
  }
}
