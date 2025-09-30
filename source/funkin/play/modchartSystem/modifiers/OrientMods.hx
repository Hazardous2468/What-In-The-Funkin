package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

// Notes angle themselves towards direction of travel
// Do note that these mods require additional calcs to be performed (that are usually skipped for performance).
// Also, orienty is very... weird? I don't get it.

class OrientModBase extends Modifier
{
  // If true, will automatically flip the angle values for when the reverse mod is active.
  var reverseFix:Bool = true;

  /*
   * If true, forces holds to be affected by this modifier.
   * If false, holds won't be affected by this modifier.
   * If null, then only gets enabled for OrientY.
   */
  var affectHolds:Null<Bool> = false;

  /*
   * the position in the array table for the orient stuff...
   * 0 = z
   * 1 = x
   * 2 = y
   * +3 for orient 2.
   */
  var index:Int = 0;

  /*
   * if enabled (above 0.5), will use the old orient math logic (will only work between -180 to 180 degrees instead of full 360 degree support)
   * if below 0.0, orientY will act the same as orientZ (easier to use / understand imo, though "intended" behaviour can be reverted via this submod)
   */
  var useAltMathSubmod:ModifierSubValue;

  public function new(name:String, i:Int)
  {
    super(name, 0);
    index = i;

    if (affectHolds == null)
    {
      affectHolds = i % 3 == 2; // To skip this modifier math for holds except for orientY
    }

    modPriority = -999999; // ALWAYS APPLY LAST!!
    unknown = false;
    notesMod = true;
    strumsMod = true;
    specialMod = true;
    holdsMod = affectHolds;
    pathMod = false;

    useAltMathSubmod = createSubMod("alt", (i % 3 == 2 ? -1.0 : 0.0), ["type", "old", "other", "variant", "varient"]);
  }

  var strumResult:Array<Float> = [0, 0, 0, 0];

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (index >= 3)
    {
      data.orient2[index - 3] = currentValue;
    }
    if (currentValue == 0 || isArrowPath || data.noteType == "receptor") return;

    switch (index % 3)
    {
      case 0:
        data.angleZ += (getOrientAngle(data) * currentValue);
        data.angleZ -= strumResult[data.direction];
      case 1:
        data.angleX += (getOrientAngle(data) * currentValue);
      case 2:
        data.angleY += (getOrientAngle(data) * currentValue);
    }
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.orientExtraMath[index] = currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    var orientAngleAmount:Float = (getOrientAngle(data) * currentValue);
    switch (index % 3)
    {
      case 0:
        data.angleZ += orientAngleAmount;
      case 1:
        data.angleX += orientAngleAmount;
      case 2:
        data.angleY += orientAngleAmount;
    }
    strumResult[data.direction] = orientAngleAmount;
    data.whichStrumNote.strumExtraModData.orientStrumAngle[index] = orientAngleAmount;
  }

  // Returns the angle between the current position and lastKnownPosition in degrees.
  function getOrientAngle(data:NoteData):Float
  {
    var a:Float = 0.0; // height
    var b:Float = 0.0; // length
    switch (index % 3)
    {
      case 0: // z axis
        a = (data.y - data.lastKnownPosition.y) * -1;
        b = (data.x - data.lastKnownPosition.x);
      case 1: // x axis
        a = (data.y - data.lastKnownPosition.y) * -1;
        b = (data.z - data.lastKnownPosition.z);
      case 2: // y axis
        if (useAltMathSubmod.value >= 0.0)
        {
          b = (data.z - data.lastKnownPosition.z) * -1;
          a = (data.x - data.lastKnownPosition.x);
        }
        else
        {
          a = (data.y - data.lastKnownPosition.y) * -1;
          b = (data.x - data.lastKnownPosition.x);
        }
    }

    if (useAltMathSubmod.value >= 0.5) // Old math. Only allows 180 degrees
    {
      var calculateAngleDif:Float = Math.atan(b / a);

      if (Math.isNaN(calculateAngleDif))
      {
        calculateAngleDif = data.lastKnownOrientAngle[index]; // TODO -> Make this less likely to be a NaN in the first place lol
      }
      else
      {
        calculateAngleDif *= FlxAngle.TO_DEG;
        data.lastKnownOrientAngle[index] = calculateAngleDif;
      }
      return calculateAngleDif;
    }
    else // allows for 360 degrees
    {
      if (Preferences.downscroll)
      {
        a *= -1;
        b *= -1;
      }

      // Fixes for differences between notes and receptors.
      if (data.noteType != "receptor" && index >= 3)
      {
        a *= -1;
        b *= -1;
      }

      // Make it look nicer when reversed.
      if (reverseFix)
      {
        var reverseModAmount:Float = data.getReverse(); // 0 to 1
        if (reverseModAmount > 0.5)
        {
          a *= -1;
          b *= -1;
        }
      }

      var calculateAngleDif:Float = FlxAngle.degreesFromOrigin(a, b);
      data.lastKnownOrientAngle[index] = calculateAngleDif;
      return calculateAngleDif;
    }
  }
}

class OrientMod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 0);
  }
}

class OrientXMod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 1);
  }
}

class OrientYMod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 2);
  }
}

// Same as Orient but instead notes will sample based on mod math instead of last known position.
class Orient2Mod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 3);
  }
}

class OrientX2Mod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 4);
  }
}

class OrientY2Mod extends OrientModBase
{
  public function new(name:String)
  {
    super(name, 5);
  }
}
