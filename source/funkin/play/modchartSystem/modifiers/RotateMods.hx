package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import lime.math.Vector2;

// Contains all mods which control strumline rotation!
// rotate on x axis
class RotateXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 21;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180));

    // grab the current x
    var beforeShit_y:Float = data.y;
    var beforeShit_z:Float = data.z;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var strumY:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;
    var strumZ:Float = whichStrumNote.z;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        strumY += strumLine.getNoteYOffset();
      }
    }
    else
    {
      strumY = data.strumPosWasHere.y;
      strumZ = data.strumPosWasHere.z;
    }

    // figure out difference
    var lolx:Float = beforeShit_y - strumY;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot; // 0
    lolz_2 *= xrot;

    lolx *= yrot; // 1
    lolz *= yrot;

    data.y = strumY + lolx + lolx_2;
    data.z = strumZ + lolz - lolz_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = 0;
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.z, data.y), currentValue);
    data.y = thing.y;
    data.z = thing.x;
  }
}

// rotate on y axis
class RotateYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 22;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_z:Float = data.z;

    // grab strum x

    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);

    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumZ:Float = whichStrumNote.z;
    if (data.noteType == "receptor")
    {
      strumX = data.strumPosWasHere.x;
      strumZ = data.strumPosWasHere.z;
    }
    else
    {
      strumX += isHoldNote ? strumLine.mods.getHoldOffsetX(isArrowPath) : strumLine.getNoteXOffset();
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot;
    lolz_2 *= xrot;

    lolx *= yrot;
    lolz *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.z = strumZ + lolz + lolz_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0

    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    rotateModPivotPoint.y = data.z;
    rotateModPivotPoint.y += getSubVal("offset_y");

    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.z), currentValue);
    data.x = thing.x;
    data.z = thing.y;
  }
}

// rotate on y axis
class RotateZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 23;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    // var xrot = currentValue ;// *(Math.PI / 180);
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_y:Float = data.y;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumY:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        strumX += strumLine.mods.getHoldOffsetX(isArrowPath);

        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        // strumX += data.getNoteXOffset();
        // strumX += data.getNoteXOffset();
        strumX += strumLine.getNoteXOffset();
        strumY += strumLine.getNoteYOffset();
      }
    }
    else
    {
      strumX = data.strumPosWasHere.x;
      strumY = data.strumPosWasHere.y;
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var loly:Float = beforeShit_y - strumY;

    // if (lane == 0) trace("xdif " + lolx);

    var lolx_2:Float = loly;
    var loly_2:Float = lolx;

    lolx_2 *= xrot;
    loly_2 *= xrot;

    lolx *= yrot;
    loly *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.y = strumY + loly + loly_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = strumLine.y;
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");

    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.y), currentValue);
    data.x = thing.x;
    data.y = thing.y;
  }
}

// receptors rotate on x axis
class StrumRotateXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 21 + 6;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = 0;
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.z, data.y), currentValue);
    data.y = thing.y;
    data.z = thing.x;
  }
}

// receptors rotate on y axis
class StrumRotateYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 22 + 6;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0

    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    rotateModPivotPoint.y = data.z;
    rotateModPivotPoint.y += getSubVal("offset_y");
    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.z), currentValue);
    data.x = thing.x;
    data.z = thing.y;
  }
}

// receptors rotate on y axis
class StrumRotateZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 23 + 6;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = strumLine.y;
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");
    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.y), currentValue);
    data.x = thing.x;
    data.y = thing.y;
  }
}

class NotesRotateXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 21 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180));

    // grab the current x
    var beforeShit_y:Float = data.y;
    var beforeShit_z:Float = data.z;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var yyyy:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;
    var strumZ:Float = whichStrumNote.z;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        if (Preferences.downscroll)
        {
          yyyy += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          yyyy += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        yyyy += strumLine.getNoteYOffset();
      }
    }
    else
    {
      yyyy = data.strumPosWasHere.y;
      strumZ = data.strumPosWasHere.z;
    }

    // figure out difference
    var lolx:Float = beforeShit_y - yyyy;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot;
    lolz_2 *= xrot;

    lolx *= yrot;
    lolz *= yrot;

    data.y = yyyy + lolx + lolx_2;
    data.z = strumZ + lolz - lolz_2;
  }
}

// rotate on y axis
class NotesRotateYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 22 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_z:Float = data.z;

    // grab strum x

    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);

    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumZ:Float = whichStrumNote.z;
    if (data.noteType == "receptor")
    {
      strumX = data.strumPosWasHere.x;
      strumZ = data.strumPosWasHere.z;
    }
    else
    {
      strumX += isHoldNote ? strumLine.mods.getHoldOffsetX(isArrowPath) : strumLine.getNoteXOffset();
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot;
    lolz_2 *= xrot;

    lolx *= yrot;
    lolz *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.z = strumZ + lolz + lolz_2;
  }
}

// rotate on y axis
class NotesRotateZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 23 + 6;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    // var xrot = currentValue ;// *(Math.PI / 180);
    var xrot:Float = (FlxMath.fastSin(currentValue * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(currentValue * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_y:Float = data.y;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumY:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        strumX += strumLine.mods.getHoldOffsetX(isArrowPath);

        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        strumX += strumLine.getNoteXOffset();
        strumY += strumLine.getNoteYOffset();
      }
    }
    else
    {
      strumX = data.strumPosWasHere.x;
      strumY = data.strumPosWasHere.y;
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var loly:Float = beforeShit_y - strumY;

    // if (lane == 0) trace("xdif " + lolx);

    var lolx_2:Float = loly;
    var loly_2:Float = lolx;

    lolx_2 *= xrot;
    loly_2 *= xrot;

    lolx *= yrot;
    loly *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.y = strumY + loly + loly_2;
  }
}

// experimental rotate based on curDistance.
class RotatingXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 21;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    createSubMod("affect_strum", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curVal:Float = currentValue * data.curPos / 180;
    // this is dumb lmfao
    var xrot:Float = (FlxMath.fastSin(curVal * Math.PI / 180));
    var yrot:Float = (FlxMath.fastCos(curVal * Math.PI / 180));

    // grab the current x
    var beforeShit_y:Float = data.y;
    var beforeShit_z:Float = data.z;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var strumY:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;
    var strumZ:Float = whichStrumNote.z;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        strumY += strumLine.getNoteYOffset();
      }
    }
    else
    {
      strumY = data.strumPosWasHere.y;
      strumZ = data.strumPosWasHere.z;
    }

    // figure out difference
    var lolx:Float = beforeShit_y - strumY;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot; // 0
    lolz_2 *= xrot;

    lolx *= yrot; // 1
    lolz *= yrot;

    data.y = strumY + lolx + lolx_2;
    data.z = strumZ + lolz - lolz_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || getSubVal("affect_strum") == 0) return; // skip math if mod is 0
    var curVal:Float = currentValue * data.curPos / 180;
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = 0;
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.z, data.y), curVal);
    data.y = thing.y;
    data.z = thing.x;
  }
}

// rotate on y axis
class RotatingYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 22;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    createSubMod("affect_strum", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    // this is dumb lmfao
    var curVal:Float = currentValue * data.curPos / 180;
    var xrot:Float = (FlxMath.fastSin(curVal * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(curVal * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_z:Float = data.z;

    // grab strum x

    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);

    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumZ:Float = whichStrumNote.z;
    if (data.noteType == "receptor")
    {
      strumX = data.strumPosWasHere.x;
      strumZ = data.strumPosWasHere.z;
    }
    else
    {
      strumX += isHoldNote ? strumLine.mods.getHoldOffsetX(isArrowPath) : strumLine.getNoteXOffset();
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var lolz:Float = beforeShit_z - strumZ;

    var lolx_2:Float = lolz;
    var lolz_2:Float = lolx;

    lolx_2 *= xrot;
    lolz_2 *= xrot;

    lolx *= yrot;
    lolz *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.z = strumZ + lolz + lolz_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || getSubVal("affect_strum") == 0) return; // skip math if mod is 0
    var curVal:Float = currentValue * data.curPos / 180;
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    rotateModPivotPoint.y = data.z;
    rotateModPivotPoint.y += getSubVal("offset_y");

    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.z), curVal);
    data.x = thing.x;
    data.z = thing.y;
  }
}

// rotate on y axis
class RotatingZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 23;
    createSubMod("offset_x", 0.0);
    createSubMod("offset_y", 0.0);
    createSubMod("affect_strum", 0.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curVal:Float = currentValue * data.curPos / 180;
    // this is dumb lmfao
    // var xrot = currentValue ;// *(Math.PI / 180);
    var xrot:Float = (FlxMath.fastSin(curVal * Math.PI / 180.0));
    var yrot:Float = (FlxMath.fastCos(curVal * Math.PI / 180.0));

    // grab the current x
    var beforeShit_x:Float = data.x;
    var beforeShit_y:Float = data.y;

    // grab strum x
    var whichStrumNote = strumLine.getByIndex(data.direction % Strumline.KEY_COUNT);
    var strumX:Float = whichStrumNote.x - whichStrumNote.strumExtraModData.noteStyleOffsetX;
    var strumY:Float = whichStrumNote.y - whichStrumNote.strumExtraModData.noteStyleOffsetY;

    if (data.noteType != "receptor")
    {
      if (isHoldNote)
      {
        strumX += strumLine.mods.getHoldOffsetX(isArrowPath);

        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        // strumX += data.getNoteXOffset();
        // strumX += data.getNoteXOffset();
        strumX += strumLine.getNoteXOffset();
        strumY += strumLine.getNoteYOffset();
      }
    }
    else
    {
      strumX = data.strumPosWasHere.x;
      strumY = data.strumPosWasHere.y;
    }

    // figure out difference
    var lolx:Float = beforeShit_x - strumX;
    var loly:Float = beforeShit_y - strumY;

    // if (lane == 0) trace("xdif " + lolx);

    var lolx_2:Float = loly;
    var loly_2:Float = lolx;

    lolx_2 *= xrot;
    loly_2 *= xrot;

    lolx *= yrot;
    loly *= yrot;

    data.x = strumX + lolx - lolx_2;
    data.y = strumY + loly + loly_2;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0 || getSubVal("affect_strum") == 0) return; // skip math if mod is 0
    var curVal:Float = currentValue * data.curPos / 180;
    var rotateModPivotPoint:Vector2 = new Vector2(0, 0);
    rotateModPivotPoint.x = strumLine.x + Strumline.INITIAL_OFFSET + (Strumline.NOTE_SPACING * 1.5);
    rotateModPivotPoint.x += getSubVal("offset_x");
    // rotateModPivotPoint.y = strumLine.y;
    // rotateModPivotPoint.y = (FlxG.height / 2) - (ModConstants.strumSize / 2);
    rotateModPivotPoint.y = (FlxG.height / 2) - (data.whichStrumNote.height / 2);
    rotateModPivotPoint.y += getSubVal("offset_y");

    rotateModPivotPoint.x += strumLine.getByIndex(data.direction % Strumline.KEY_COUNT).strumExtraModData.noteStyleOffsetX;

    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(data.x, data.y), curVal);
    data.x = thing.x;
    data.y = thing.y;
  }
}
