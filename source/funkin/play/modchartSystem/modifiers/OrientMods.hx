package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;

// Notes angle themselves towards direction of travel
// A little bit more on the experimental side. Probably breaks when having active overlapping orient mods.
// Also, orienty is very... weird? I don't get it.

class OrientModBase extends Modifier
{
  // the position in the array table for the orient stuff...
  var index:Int = 0;

  public function new(name:String, i:Int)
  {
    super(name, 0);
    index = i;
    modPriority = -999999; // ALWAYS APPLY LAST!!
    unknown = false;
    notesMod = true;
    strumsMod = true;
    specialMod = true;
  }

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
        data.angleZ -= data.whichStrumNote.strumExtraModData.orientStrumAngle[index]; // undo the mother fucking strum rotation for orient XD
      case 1:
        data.angleX += (getOrientAngle(data) * currentValue);
      case 2:
        data.angleY += (getOrientAngle(data) * currentValue);
    }
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.orientExtraMath[4] = currentValue;
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
    data.whichStrumNote.strumExtraModData.orientStrumAngle[index] = orientAngleAmount;
  }

  function getOrientAngle(data:NoteData):Float
  {
    // Oh hey, same math for spiral hold shit lmfao
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
        b = (data.z - data.lastKnownPosition.z) * -1;
        a = (data.x - data.lastKnownPosition.x);
    }
    var calculateAngleDif:Float = Math.atan(b / a);

    if (Math.isNaN(calculateAngleDif))
    {
      calculateAngleDif = data.lastKnownOrientAngle[index]; // TODO -> Make this less likely to be a NaN in the first place lol
    }
    else
    {
      calculateAngleDif *= (180 / Math.PI);
      data.lastKnownOrientAngle[index] = calculateAngleDif;
    }

    return calculateAngleDif;
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
