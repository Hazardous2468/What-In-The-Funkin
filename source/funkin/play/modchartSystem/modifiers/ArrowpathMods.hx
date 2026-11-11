package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;
import funkin.play.notes.StrumlineNote;

// Contains all mods that control arrowpaths!

class ArrowpathMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    pathMod = true;
    specialMod = true;
    displayName = "Arrowpath";
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    final whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.arrowPathAlpha = currentValue;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath) data.alpha += currentValue;
  }
}

class SpiralPathsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    utility = true;
    pathMod = true;
    displayName = "SpiralPaths";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.holdType = currentValue;
  }
}

class NotITG_ArrowPathMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
    utility = true;
    displayName = "LinePath";
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.notitgStyledPath = currentValue > 0.5 ? true : false;
  }
}

class ArrowpathWidthMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    utility = true;
    pathMod = true;
    displayName = "PathWidth";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (!isArrowPath) return;
    final scaleX:Float = currentValue * 0.25; // make it 0.25 smaller then a regular hold
    data.scaleX = scaleX;
    data.scaleY = scaleX; // ?
    data.scaleZ = scaleX;
  }
}

class ArrowpathRedMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    pathMod = true;
    utility = true;
    displayName = "PathRed";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath)
    {
      data.red = currentValue;
    }
  }
}

class ArrowpathGreenMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    pathMod = true;
    displayName = "PathGreen";
    utility = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath)
    {
      data.green = currentValue;
    }
  }
}

class ArrowpathBlueMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    pathMod = true;
    displayName = "PathBlue";
    utility = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath)
    {
      data.blue = currentValue;
    }
  }
}

class ArrowpathBackLengthMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 400);
    unknown = false;
    specialMod = true;
    notPercentage = true;
    utility = true;
    displayName = "PathBackLength";
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    final whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.arrowpathBackwardsLength = currentValue;
  }
}

class ArrowpathFrontLengthMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1500);
    unknown = false;
    specialMod = true;
    notPercentage = true;
    utility = true;
    displayName = "PathLength";
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    final whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.arrowpathLength = currentValue;
  }
}

class ArrowpathStraightHoldMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    pathMod = true;
    displayName = "StraightPaths";
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.straightHolds += currentValue;
  }
}

class ArrowpathGrainMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 95);
    unknown = false;
    notPercentage = true;
    pathMod = true;
    displayName = "PathGrain";
    utility = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.holdGrain = currentValue;
  }
}
