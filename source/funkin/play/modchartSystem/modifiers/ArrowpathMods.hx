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
    pathMod = true;
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
    pathMod = true;
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
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.holdGrain = currentValue;
  }
}
