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
    typeSubmod = createSubMod("type", 1.0, ["style", "variant"]);
  }

  var typeSubmod:ModifierSubValue;

  function getCurVal():Float
  {
    if (typeSubmod.value < 0.5 && currentValue > 0.0)
    {
      // PingPong between 0 -> 1 -> 0 -> 1...
      // Can not be negative, otherwise use regular behaviour.
      var curValEdit:Float = currentValue % 1;
      if (currentValue % 2 > 1)
      {
        curValEdit = 1 - currentValue % 1;
      }
      return curValEdit;
    }
    else
    {
      // uncapped regular reverse values.
      return currentValue;
    }
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    return (1 - (getCurVal() * 2));
  }

  var dif:Null<Float> = null;

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var curVal:Float = getCurVal();
    if (targetLane == -1)
    {
      data.whichStrumNote.strumExtraModData.reverseMod = curVal;
    }
    else
    {
      data.whichStrumNote.strumExtraModData.reverseModLane = curVal;
    }

    if (curVal == 0) return; // skip math if mod is 0

    // Compute this only once!
    if (dif == null)
    {
      var baseY:Float = PlayState.getStrumlineY(strumLine, false);
      var targetY:Float = PlayState.getStrumlineY(strumLine, true);
      dif = targetY - baseY;
    }

    data.y += dif * curVal;
  }
}

// Notes slow down as they approach the receptors
class SlowDownMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
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
    super(name, 0);
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
  var startSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    speedMod = true;
    startSubmod = createSubMod("start", 900, ["begin", "trigger", "threshold"]);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var speed:Float = 1.0; // return value
    var start:Float = this.startSubmod.value;
    var finalTargetSpeed:Float = 1.0;
    var div:Float = start * 2;
    var curPosEdit:Float = curPos * (Preferences.downscroll ? -1 : 1);

    if (curPosEdit <= 0) speed = 1; // past receptors
    else if (curPosEdit >= start) // before effect start
    {
      speed /= curPosEdit / start;

      // for smooth transition:
      currentValue = Math.abs(currentValue);
      if (currentValue > 1) currentValue = 1;
      speed = FlxMath.lerp(1, speed, currentValue * 0.75);
    }
    else // approaching receptors
    {
      var lol:Float = (curPosEdit) / div;
      lol += lol;
      speed /= curPosEdit / start;
      speed = FlxMath.lerp(finalTargetSpeed * currentValue, speed, lol);
    }

    return speed;
  }
}

class OldBoostMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    // IT'S THE SAME AS BRAKE, BUT THE CURVALUE IS REVERSED LMAO
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

// notes slow down and speed up before reaching receptor. Fixed version where the effect doesn't intensify the further notes are.
class WaveMod extends Modifier
{
  var multSubmod:ModifierSubValue;
  var offsetSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    speedMod = true;
    multSubmod = createSubMod("mult", 1, ["period", "size"]);
    offsetSubmod = createSubMod("offset", 0);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var curValue:Float = this.currentValue * 0.58;
    curValue += this.offsetSubmod.value;
    var curPos_Edit:Float = curPos * (Preferences.downscroll ? -1 : 1); // Make it act the same for upscroll and downscroll
    curPos_Edit *= 0.00875; // Slow the curPos right the fuck down to stop the notes from zooming so hard
    curPos_Edit *= this.multSubmod.value;
    var test:Float = curPos_Edit;
    if (test < 1) test = 1;
    return 1 + (this.sin(curPos_Edit) / test * curValue);
  }
}

// notes slow down and speed up before reaching receptor
class OldWaveMod extends Modifier
{
  var multSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    speedMod = true;

    multSubmod = createSubMod("mult", 1.0, ["period", "size"]);
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var returnVal:Float = 1.0;
    // some magic numbers found by just messing around with values to get it as close as possible to NotITG
    var curPos_Part1:Float = curPos * (Preferences.downscroll ? -1 : 1); // Make it act the same for upscroll and downscroll
    var curPos_Part2:Float = curPos_Part1; // Slow the curPos right the fuck down to stop the notes from zooming so hard
    returnVal += currentValue * 0.22 * sin(curPos_Part2 / 38.0 * multSubmod.value * 0.2);
    return returnVal;
  }
}
