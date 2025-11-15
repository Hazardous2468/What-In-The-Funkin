package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

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

// Move in pixels as opposed to arrow size. Also applied AFTER most over mods like rotation.
class MoveXMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    modPriority = -9999;
    notPercentage = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.x += currentValue;
    data.whichStrumNote.strumExtraModData.playfieldX += currentValue;
  }
}

class MoveYMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += currentValue;
    data.whichStrumNote.strumExtraModData.playfieldY += currentValue;
  }
}

class MoveYDMod_true extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
    notPercentage = true;
    modPriority = -9999;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.y += currentValue * (Preferences.downscroll ? -1 : 1);
    data.whichStrumNote.strumExtraModData.playfieldY += currentValue * (Preferences.downscroll ? -1 : 1);
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
    notPercentage = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.z += currentValue;
    data.whichStrumNote.strumExtraModData.playfieldZ += currentValue;
  }
}

class CenteredXMod extends Modifier
{
  var caluclated:Bool = false;
  var distanceToMove:Float = 0;
  var shouldAlwaysReCalculate:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = -199;
    unknown = false;
    strumsMod = true;
    shouldAlwaysReCalculate = createSubMod("always_calculate", 0.0, ["alwayscalculate", "always_recalculate", "alwaysrecalculate", "recalculate"]);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (!caluclated || shouldAlwaysReCalculate.value > 0.5)
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
    data.whichStrumNote.strumExtraModData.playfieldX += distanceToMove * currentValue;
  }
}

class CenteredMod extends Modifier
{
  var distanceToMove:Float = 0;
  var heightOffset:Float = 162; // SAME AS PLAYSTATE PLEASE!!

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 200;
    unknown = false;
    strumsMod = true;
  }

  var dif:Null<Float> = null;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // multiply by the reverse amount for this movement
    var reverseModAmount:Float = data.getReverse(); // 0 to 1
    var reverseMult:Float = FlxMath.remapToRange(reverseModAmount, 0, 1, 1, -1);

    // Compute this only once!
    if (dif == null)
    {
      var baseY:Float = PlayState.getStrumlineY(strumLine, false);
      var targetY:Float = PlayState.getStrumlineY(strumLine, true);
      dif = targetY - baseY;
    }

    data.y += dif * (currentValue * 0.5) * reverseMult;
  }
}

class AlwaysCenterMod extends Modifier
{
  var caluclated:Bool = false;
  var distanceToMove:Float = 0;

  var shouldAlwaysReCalculate:ModifierSubValue;
  var useOldMath:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 51;
    useOldMath = createSubMod("oldmath", 0.0, ["method", "old", "legacy"]);
    shouldAlwaysReCalculate = createSubMod("always_calculate", 0.0, ["alwayscalculate", "always_recalculate", "alwaysrecalculate", "recalculate"]);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    if (useOldMath.value > 0.5)
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
      if (!caluclated || shouldAlwaysReCalculate.value > 0.5)
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
    var screenCenter:Float = (FlxG.height / 2) - (ModConstants.strumSize / 2) - Strumline.INITIAL_OFFSET;
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

    everyBeat = createSubMod("beat", 1.0, ["every", "frequency"]);
    offset = createSubMod("offset", 0.0, ["time_add", "timeadd", "time_offset", "timeoffset"]);
    reverseAffect = createSubMod("reverse_affected", 1.0, ["reverse", "reversable", "reverseaffect", "reverseaffected", "reverse_affect"]);
  }

  var everyBeat:ModifierSubValue;
  var offset:ModifierSubValue;
  var reverseAffect:ModifierSubValue;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // var time:Float = (beatTime + offset.value) % everyBeat.value;

    var time:Float = ModConstants.mod((beatTime + offset.value), everyBeat.value);

    var val:Float = time * Conductor.instance.beatLengthMs;

    var reverseModAmount:Float = data.getReverse();
    var reverseMult:Float = FlxMath.remapToRange(reverseModAmount, 0, 1, 1, -1);
    reverseMult = FlxMath.lerp(1, reverseMult, reverseAffect.value);

    var scrollSpeed = PlayState.instance.currentChart.scrollSpeed;
    data.y += Constants.PIXELS_PER_MS * scrollSpeed * (Preferences.downscroll ? -1 : 1) * val * currentValue * reverseMult;
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
    notPercentage = true;
    reverseAffect = createSubMod("reverse_affect", 1.0, ["reverse", "reverseaffect"]);
  }

  var reverseAffect:ModifierSubValue;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // multiply by the reverse amount for this movement
    var reverseModAmount:Float = data.getReverse();
    var reverseMult:Float = FlxMath.remapToRange(reverseModAmount, 0, 1, 1, -1);
    reverseMult = FlxMath.lerp(1, reverseMult, reverseAffect.value);

    var scrollSpeed = PlayState.instance.currentChart.scrollSpeed;
    data.y += Constants.PIXELS_PER_MS * scrollSpeed * (Preferences.downscroll ? -1 : 1) * currentValue * reverseMult;
  }
}

class Drive2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 0;
    unknown = false;
    notPercentage = true;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    var scrollSpeed:Float = PlayState.instance.currentChart.scrollSpeed;
    var funny:Float = scrollSpeed * -1 * currentValue;

    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.strumPos = funny;
  }
}
