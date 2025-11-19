package funkin.play.modchartSystem.modifiers;

import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.FlxG;
import funkin.play.notes.Strumline;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to column swapping!
// LDUR becomes RUDL
class FlipMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    final nd = data.direction % Strumline.KEY_COUNT;
    final newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT, -Strumline.KEY_COUNT);
    data.x += ModConstants.strumSize * newPos * currentValue;
    data.x -= ModConstants.strumSize * currentValue;
  }
}

// LDUR becomes DLRU
class InvertMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    data.x += ModConstants.strumSize * (data.direction % 2 == 0 ? 1 : -1) * currentValue;
  }
}

// LDUR becomes LUDR
class VideoGamesMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is dumb, change this later to not use if statement!
    if (data.direction == 1)
    {
      data.x += ModConstants.strumSize * currentValue;
    }
    else if (data.direction == 2)
    {
      data.x -= ModConstants.strumSize * currentValue;
    }
  }
}

class BlackSphereInvertMod extends Modifier
{
  var variant:ModifierSubValue;
  var speedaffect:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    notPercentage = true;
    variant = createSubMod("variant", 0.0);
    speedaffect = createSubMod("speedaffect", 1.0);
    modPriority = 130;
    unknown = false;
    strumsMod = true;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote:Bool = false):Float
  {
    currentValue = currentValue % 360;
    if (currentValue == 0) return 1; // skip math if mod is 0
    // current value is in degrees!

    var retu_val:Float = 1;
    final speedAffectM:Float = speedaffect.value;
    var yValue:Float = FlxMath.fastSin(currentValue * Math.PI / 180);

    // multiply by the reverse amount for this movement
    final whichStrummy = strumLine.getByIndex(lane);
    final reverseModAmount:Float = whichStrummy.noteModData.getReverse();

    var reverseMult:Float = FlxMath.remapToRange(reverseModAmount, 0, 1, 1, -1);

    if (variant.value >= 1.0)
    {
      if (lane % 4 == 1 || lane % 4 == 2) yValue *= -1;
    }
    else
    {
      if (lane % 2 == 1) yValue *= -1;
    }

    if (!Preferences.downscroll) yValue *= -1;

    retu_val += yValue * 0.125 * speedAffectM * reverseMult;

    return retu_val;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // current value is in degrees!

    final lane:Int = data.direction;

    var invertValue:Float = 0;
    var yValue:Float = 0;

    invertValue = 50 - 50 * FlxMath.fastCos(currentValue * Math.PI / 180);
    invertValue /= 100;

    yValue = 0.5 * FlxMath.fastSin(currentValue * Math.PI / 180);

    if (variant.value >= 1.0)
    {
      if (lane % 4 == 1 || lane % 4 == 2) yValue *= -1;
    }
    else
    {
      if (lane % 2 == 1) yValue *= -1;
    }

    data.x += ModConstants.strumSize * (lane % 2 == 0 ? 1 : -1) * invertValue;
    data.y += ModConstants.strumSize * yValue;
  }
}

class BlackSphereFlipMod extends Modifier
{
  var variant:ModifierSubValue;
  var speedaffect:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    variant = createSubMod("variant", 0.0);
    speedaffect = createSubMod("speedaffect", 1.0);
    modPriority = 130;
    notPercentage = true;

    unknown = false;
    strumsMod = true;
    speedMod = true;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote:Bool = false):Float
  {
    currentValue = currentValue % 360;
    if (currentValue == 0) return 1; // skip math if mod is 0
    // current value is in degrees!

    var retu_val:Float = 1;
    final speedAffectM:Float = speedaffect.value;
    var yValue:Float = FlxMath.fastSin(currentValue * Math.PI / 180);
    if (variant.value >= 1.0)
    {
      if (lane % 4 == 1 || lane % 4 == 2) yValue *= -1;
    }
    else
    {
      if (lane % 2 == 1) yValue *= -1;
    }

    // multiply by the reverse amount for this movement
    final whichStrummy = strumLine.getByIndex(lane);
    final reverseModAmount:Float = whichStrummy.noteModData.getReverse();
    var reverseMult:Float = FlxMath.remapToRange(reverseModAmount, 0, 1, 1, -1);

    if (!Preferences.downscroll) yValue *= -1;
    retu_val += yValue * 0.125 * speedAffectM * reverseMult;

    return retu_val;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue % 360 == 0) return; // skip math if mod is 0
    // current value is in degrees!
    final lane:Int = data.direction;
    var invertValue:Float = 0;
    var yValue:Float = 0;

    invertValue = 50 - 50 * FlxMath.fastCos(currentValue * Math.PI / 180);
    invertValue /= 100;

    yValue = 0.5 * FlxMath.fastSin(currentValue * Math.PI / 180);

    if (variant.value >= 1.0)
    {
      if (lane % 4 == 1 || lane % 4 == 2) yValue *= -1;
    }
    else
    {
      if (lane % 2 == 1) yValue *= -1;
    }

    final nd = lane % 4;
    final newPos = FlxMath.remapToRange(nd, 0, 4, 4, -4);
    data.x += ModConstants.strumSize * newPos * invertValue;
    data.x -= ModConstants.strumSize * invertValue;

    // y movement, doesn't use reverse for now! -UPDATE, NOW CHANGES SPEED AS WELL
    data.y += ModConstants.strumSize * yValue;
  }
}
