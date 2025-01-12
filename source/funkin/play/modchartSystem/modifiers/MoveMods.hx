package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to manual movement!
// move based on arrowsize like NotITG (so 1.0 movex means move right by 1 arrowsize)
class MoveXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.x += ModConstants.strumSize * currentValue;
  }
}

class MoveYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += ModConstants.strumSize * currentValue;
  }
}

class MoveYDMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += ModConstants.strumSize * currentValue * (Preferences.downscroll ? -1 : 1);
  }
}

class MoveZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.z += ModConstants.strumSize * currentValue;
  }
}

class MoveXMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.x += currentValue;
  }
}

class MoveYMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += currentValue;
  }
}

class MoveYDMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += currentValue * (Preferences.downscroll ? -1 : 1);
  }
}

class MoveZMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.z += currentValue;
  }
}

class CenteredXMod extends Modifier
{
  var caluclated:Bool = false;
  var distanceToMove:Float = 0;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = -199;
    // modPriority = -999999; // Apply this mod last so it doesn't fuck with mods like the rotate mods lmfao

    unknown = false;
    strumsMod = true;
    createSubMod("always_calculate", 0.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (!caluclated || getSubVal("always_calculate") > 0.5)
    {
      var beforeCenter:Float = strumLine.x;
      strumLine.screenCenter(X);
      var afterCenter:Float = strumLine.x;
      strumLine.x = beforeCenter;

      distanceToMove = afterCenter - beforeCenter;
      caluclated = true;
    }

    // preculated distance so a value of 100% will center both the player and strum
    data.x += distanceToMove * currentValue;
  }
}

class CenteredMod extends Modifier
{
  var caluclated:Bool = false;
  var distanceToMove:Float = 0;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 51;
    createSubMod("oldmath", 0.0);
    createSubMod("always_calculate", 0.0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    if (getSubVal("oldmath") > 0.5)
    {
      var valchange:Float = currentValue * 0.5;
      var height:Float = 112.0;
      height -= 2.4; // magic number ~
      if (Preferences.downscroll)
      {
        data.y -= valchange * ((FlxG.height - height) - (Constants.STRUMLINE_Y_OFFSET * 4));
      }
      else
      {
        data.y += valchange * ((FlxG.height - height) - (Constants.STRUMLINE_Y_OFFSET * 4));
      }
    }
    else
    {
      if (!caluclated || getSubVal("always_calculate") > 0.5)
      {
        var screenCenter:Float = (FlxG.height / 2) - (ModConstants.strumSize / 2);
        var differenceBetween:Float = data.y - screenCenter;
        distanceToMove = differenceBetween;
        caluclated = true;
      }
      data.y -= currentValue * distanceToMove;
    }
  }
}

class CenteredNotesMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 50;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var screenCenter:Float = (FlxG.height / 2) - (ModConstants.strumSize / 2) + strumLine.getNoteYOffset();
    var differenceBetween:Float = data.y - screenCenter;
    data.y -= currentValue * differenceBetween;
  }
}

// Ported from MT (literally made this just for meta mods lmfao)
class JumpMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 97;
    unknown = false;
    strumsMod = true;

    createSubMod("beat", 1.0);
    createSubMod("offset", 0.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    var time:Float = (beatTime + getSubVal("offset")) % getSubVal("beat");
    var val:Float = time * Conductor.instance.beatLengthMs;

    var scrollSpeed = PlayState.instance.currentChart.scrollSpeed;
    data.y += Constants.PIXELS_PER_MS * scrollSpeed * (Preferences.downscroll ? -1 : 1) * val * currentValue;
  }
}

class DriveMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 97;
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var scrollSpeed = PlayState.instance.currentChart.scrollSpeed;
    data.y += Constants.PIXELS_PER_MS * scrollSpeed * (Preferences.downscroll ? -1 : 1) * currentValue;
  }
}

class Drive2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 0;
    unknown = false;
    // strumsMod = true;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    var scrollSpeed:Float = PlayState.instance.currentChart.scrollSpeed;
    var funny:Float = Constants.PIXELS_PER_MS * scrollSpeed * -1 * currentValue;

    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.strumPos = funny;

    // strumLine.mods.strumPos[lane] = funny;
  }
}

class StrumXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    return; // doesn't do anything as of now.
  }
}

class StrumYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    return; // doesn't do anything as of now.
  }
}

class StrumZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    return; // doesn't do anything as of now.
  }
}
