package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxAngle;

// Contains all the mods related to skewing!

class PlayFieldSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  var strumSkew:Float = 0;

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    if (data.whichStrumNote?.strumExtraModData?.threeD ?? false)
    {
      data.skewX_playfield += currentValue;
      return;
    }

    var skewCenterPoint:Float = data.whichStrumNote.strumExtraModData.playfieldY;

    var offsetY:Float = ModConstants.strumSize / 2;
    if (data.noteType == "hold" || data.noteType == "path")
    {
      offsetY = 0;
    }
    var skewMagicX:Float = (data.y + offsetY) - skewCenterPoint;
    data.x += skewMagicX * ModConstants.fastTan(currentValue * FlxAngle.TO_RAD);
    data.x -= strumSkew;
    data.skewX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    if (data.whichStrumNote?.strumExtraModData?.threeD ?? false)
    {
      data.skewX_playfield += currentValue;
      return;
    }

    var skewCenterPoint:Float = data.whichStrumNote.strumExtraModData.playfieldY;

    var offsetY:Float = ModConstants.strumSize / 2;
    var skewMagicX:Float = (data.y + offsetY) - skewCenterPoint;
    strumSkew = skewMagicX * ModConstants.fastTan(currentValue * FlxAngle.TO_RAD);
    data.x += strumSkew;
    data.skewX += currentValue;
  }
}

class PlayFieldSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewY_playfield += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY_playfield += currentValue;
  }
}

class PlayFieldSkewZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewZ_playfield += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ_playfield += currentValue;
  }
}

class NotesSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += currentValue;
  }
}

class NotesSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += currentValue;
  }
}

class NotesSkewZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ += currentValue;
  }
}

class HoldsSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
    pathMod = true;
    notPercentage = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += currentValue;
  }
}

class StrumSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += currentValue;
  }
}

class StrumSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += currentValue;
  }
}

class StrumSkewZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ += currentValue;
  }
}
