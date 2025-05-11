package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxMath;
import funkin.util.Constants;
import flixel.FlxG;

// Contains all the mods related to speed!
// Controls how fast the note approaches the receptor
class SpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = 667;
    unknown = false;
    speedMod = true;

    this.baseValue = 1;
    this.currentValue = 1;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    return currentValue;
  }
}

// Invert scroll direction!
class ReverseMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 122;
    unknown = false;
    speedMod = true;
    strumsMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    return (1 - (currentValue * 2));
  }

  var dif:Null<Float> = null;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (targetLane == -1)
    {
      data.whichStrumNote.strumExtraModData.reverseMod = currentValue;
    }
    else
    {
      data.whichStrumNote.strumExtraModData.reverseModLane = currentValue;
    }

    if (currentValue == 0) return; // skip math if mod is 0

    // Compute this only once!
    if (dif == null)
    {
      var baseY:Float = strumLine.noteStyle.getInitialStrumlineOffsets()[1]
        + (Preferences.downscroll ? FlxG.height
          - (PlayState.heightOffset)
          - Constants.STRUMLINE_Y_OFFSET
          - (strumLine.noteStyle.getStrumlineOffsetForInitialCreation() ? strumLine.noteStyle.getStrumlineOffsets()[1] : 0.0) : Constants.STRUMLINE_Y_OFFSET);

      var targetY:Float = strumLine.noteStyle.getInitialStrumlineOffsets()[1]
        + (Preferences.downscroll ? Constants.STRUMLINE_Y_OFFSET : FlxG.height
          - (PlayState.heightOffset)
          - Constants.STRUMLINE_Y_OFFSET
          - (strumLine.noteStyle.getStrumlineOffsetForInitialCreation() ? strumLine.noteStyle.getStrumlineOffsets()[1] : 0.0));

      dif = targetY - baseY;
    }

    data.y += dif * currentValue;
  }
}

// Notes slow down as they approach the receptors
class SlowDownMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var retu_val:Float = 1 - currentValue + (((Math.abs(curPos) / 100) * currentValue));
    retu_val *= 0.05; // slow it down to be less insane lmfao
    return retu_val;
  }
}

// Notes slow down as they approach the receptors
class BrakeMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var returnVal:Float = 1.0;

    var curPos_Part1:Float = curPos * (Preferences.downscroll ? -1 : 1); // Make it act the same for upscroll and downscroll
    var curPos_Part2:Float = curPos_Part1 * 0.001 * 0.31; // Slow the curPos right the fuck down to stop the notes from zooming so hard
    curPos_Part2 = FlxMath.bound(curPos_Part2, 0, 2); // clamp value
    if (curPos_Part1 <= 0) curPos_Part2 = 1.0; // Once past receptors, speed acts like normal...
    returnVal *= curPos_Part2; // Apply brake to speed
    returnVal = FlxMath.lerp(1.0, returnVal, currentValue); // Mod logic.

    return returnVal;
  }
}

// Notes speed up as they approach the receptors
class BoostMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    // IT'S THE SAME AS BOOST, BUT THE CURVALUE IS REVERSED LMAO
    var returnVal:Float = 1.0;
    var curPos_Part1:Float = curPos * (Preferences.downscroll ? -1 : 1); // Make it act the same for upscroll and downscroll
    var curPos_Part2:Float = curPos_Part1 * 0.001 * 0.4; // Slow the curPos right the fuck down to stop the notes from zooming so hard
    curPos_Part2 = FlxMath.bound(curPos_Part2, 0, 2); // clamp value
    if (curPos_Part1 <= 0) curPos_Part2 = 1.0; // Once past receptors, speed acts like normal...
    returnVal *= curPos_Part2; // Apply brake to speed
    returnVal = FlxMath.lerp(1.0, returnVal, currentValue * -1); // Mod logic.
    return returnVal;
  }
}

// notes slow down and speed up before reaching receptor
class WaveMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    unknown = false;
    speedMod = true;
    createSubMod("mult", 1);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var returnVal:Float = 1.0;

    // same magic numbers found by just messing around with values to get it as close as possible to NotITG

    var curPos_Part1:Float = curPos * (Preferences.downscroll ? -1 : 1); // Make it act the same for upscroll and downscroll
    var curPos_Part2:Float = curPos_Part1; // Slow the curPos right the fuck down to stop the notes from zooming so hard
    returnVal += currentValue * 0.22 * FlxMath.fastSin(curPos_Part2 / 38.0 * getSubVal("mult") * 0.2);

    return returnVal;
  }
}
