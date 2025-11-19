package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// A special modifier that makes the scale of the note be clamped (mainly used to prevent negative scales). Use the submods to control the logic
class AntiNegativeScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -500; // apply VERY late as it overwrites the scale values
    type = createSubMod("positive", 0.0, ["makepositive", "make_positive", "rebound", "type", "abs", "absolute"]);
  }

  var type:ModifierSubValue;

  function clamp(daValue:Float):Float
  {
    var returnValue:Float = daValue;
    if (type.value < 0)
    {
      if (daValue < 0) returnValue = 0;
    }
    else if (type.value >= 1.0)
    {
      returnValue = Math.abs(daValue);
    }
    else
    {
      if (daValue < 0) returnValue = 0;
      returnValue = FlxMath.lerp(returnValue, Math.abs(daValue), type.value);
    }

    return FlxMath.lerp(daValue, returnValue, currentValue); // % blend
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;
    data.scaleX = clamp(data.scaleX);
    data.scaleY = clamp(data.scaleY);
    data.scaleZ = clamp(data.scaleZ);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = clamp(data.scaleX);
    data.scaleY = clamp(data.scaleY);
    data.scaleZ = clamp(data.scaleZ);
  }
}

// WTF?!
class BangarangMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -50;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;

    var yOffset:Float = 0;

    final speed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;

    final curpos:Float = data.curPos;

    final fYOffset = -curpos / speed;
    final fEffectHeight = FlxG.height;
    final fScale = FlxMath.remapToRange(fYOffset, 0, fEffectHeight, 0, 1); // scale
    final fNewYOffset = fYOffset * fScale;
    var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
    fBrakeYAdjust = FlxMath.bound(fBrakeYAdjust, -400, 400); // clamp

    yOffset -= fBrakeYAdjust * speed;
    data.y += curpos + yOffset;
  }
}
