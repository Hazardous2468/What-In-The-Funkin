package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import funkin.play.notes.StrumlineNote;
import flixel.math.FlxMath;

// Contains all the mods related to stealth and alpha
// ...

class UseOldStealthHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = false;
    holdsMod = false;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(data.direction);
    whichStrum.strumExtraModData.useOldStealthGlowStyle = currentValue >= 0.5;
  }
}

class StealthGlowRedMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = -3;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.stealthGlowRed = currentValue;
  }
}

class StealthGlowGreenMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = -4;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.stealthGlowGreen = currentValue;
  }
}

class StealthGlowBlueMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 1);
    modPriority = -5;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    strumMath(data, strumLine);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.stealthGlowBlue = currentValue;
  }
}

// Fades the strums out stealth style
class DarkMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    strumsMod = true;
    unknown = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    // will only start fading the arrow at 50%
    data.alpha -= FlxMath.bound((currentValue - 0.5) * 2, 0, 1);
  }
}

// Fades the strums out REAL stealth style
class StrumStealthMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 120;
    strumsMod = true;
    unknown = false;
    createSubMod("no_alpha", 0.0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var stealthGlow:Float = currentValue * 2; // so it reaches max at 0.5
    data.stealth += FlxMath.bound(stealthGlow, 0, 1); // clamp

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = (currentValue - 0.5) * 2;
    subtractAlpha = FlxMath.bound(subtractAlpha, 0, 1); // clamp
    data.alpha -= subtractAlpha;
  }
}

// Notes fade to white and then fade out of existence
class StealthMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 120;
    createSubMod("noglow", 0.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (!(data.noteType == "receptor" || data.noteType == "path"))
    {
      var curPos2:Float = data.curPos_unscaled;
      curPos2 *= Preferences.downscroll ? -1 : 1;
      var pastReceptors:Float = 1;
      // if ((Preferences.downscroll && curPos2 > 0) || (!Preferences.downscroll && curPos2 < 0))
      if (curPos2 < 0)
      {
        pastReceptors = getSubVal("stealthpastreceptors");
      }

      if (getSubVal("noglow") >= 1.0) // If 1.0 -> just control alpha
      {
        data.alpha -= FlxMath.bound(currentValue * pastReceptors, 0, 1); // clamp
      }
      else if (getSubVal("noglow") >= 0.5) // if 0.5 -> same logic, just no stealthglow applied
      {
        var subtractAlpha:Float = (currentValue - 0.5) * 2;
        subtractAlpha = FlxMath.bound(subtractAlpha * pastReceptors, 0, 1); // clamp
        data.alpha -= subtractAlpha;
      }
      else // Else, acts like how it would in NotITG with 0.5 modValue being full stealth glow, 0.75 being half opacity, and 1 being fully invisible.
      {
        var stealthGlow:Float = currentValue * 2; // so it reaches max at 0.5
        data.stealth += FlxMath.bound(stealthGlow * pastReceptors, 0, 1); // clamp

        // extra math so alpha doesn't start fading until 0.5
        var subtractAlpha:Float = (currentValue - 0.5) * 2;
        subtractAlpha = FlxMath.bound(subtractAlpha * pastReceptors, 0, 1); // clamp
        data.alpha -= subtractAlpha;
      }
    }
  }
}

class SuddenMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 119;
    createSubMod("noglow", 0.0);
    createSubMod("start", 500.0);
    createSubMod("end", 300.0);
    createSubMod("offset", 0.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(data.direction);
    whichStrum.strumExtraModData.suddenModAmount = currentValue;
    whichStrum.strumExtraModData.suddenStart = getSubVal("start") + getSubVal("offset");
    whichStrum.strumExtraModData.suddenEnd = getSubVal("end") + getSubVal("offset");
    whichStrum.strumExtraModData.sudden_noGlow = getSubVal("noglow");
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var useOldStealthGlowStyle:Bool = data.whichStrumNote.strumExtraModData.useOldStealthGlowStyle;
    if (isArrowPath || data.noteType == "receptor" || (isHoldNote && !useOldStealthGlowStyle)) return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;
    // Don't do anything if we're past receptors! Maybe disable this if we want stealth past receptors?
    // if (curPos2 < 0) return;

    var a:Float = FlxMath.remapToRange(curPos2, getSubVal("start") + getSubVal("offset"), getSubVal("end") + getSubVal("offset"), 1, 0);

    // var a = FlxMath.remapToRange(curPos * -1, 500, 300, 0, 1); // scale

    a = FlxMath.bound(a, 0, 1); // clamp

    if (getSubVal("noglow") >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }

    a *= currentValue;

    if (getSubVal("noglow") < 1) // if below 0, then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - getSubVal("noglow")); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class HiddenMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 118;
    createSubMod("noglow", 0.0);
    createSubMod("start", 500.0);
    createSubMod("end", 300.0);
    createSubMod("offset", 0.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(data.direction);
    whichStrum.strumExtraModData.hiddenModAmount = currentValue;
    whichStrum.strumExtraModData.hiddenStart = getSubVal("start") + getSubVal("offset");
    whichStrum.strumExtraModData.hiddenEnd = getSubVal("end") + getSubVal("offset");
    whichStrum.strumExtraModData.hidden_noGlow = getSubVal("noglow");
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var useOldStealthGlowStyle:Bool = data.whichStrumNote.strumExtraModData.useOldStealthGlowStyle;
    if (isArrowPath || data.noteType == "receptor" || (isHoldNote && !useOldStealthGlowStyle)) return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;

    // Don't do anything if we're past receptors! Maybe disable this if we want stealth past receptors?
    if (getSubVal("stealthpastreceptors") <= 0)
    {
      if (curPos2 < 0) return;
    }

    var a:Float = FlxMath.remapToRange(curPos2, getSubVal("start") + getSubVal("offset"), getSubVal("end") + getSubVal("offset"), 0, 1);
    a = FlxMath.bound(a, 0, 1); // clamp

    if (getSubVal("noglow") >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }
    a *= currentValue;

    if (getSubVal("noglow") < 1) // if below 1 -> then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - getSubVal("noglow")); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class VanishMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 117;
    createSubMod("noglow", 0.0);
    createSubMod("start", 475.0);
    createSubMod("size", 195.0);
    createSubMod("end", 125.0);
    createSubMod("offset", 0.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(data.direction);
    whichStrum.strumExtraModData.vanishModAmount = currentValue;

    var sizeThingy:Float = getSubVal("size") / 2;
    var midPoint:Float = getSubVal("start") + getSubVal("end");
    midPoint /= 2;

    whichStrum.strumExtraModData.vanish_HiddenStart = getSubVal("start") + getSubVal("offset");
    whichStrum.strumExtraModData.vanish_HiddenEnd = midPoint + sizeThingy + getSubVal("offset");

    whichStrum.strumExtraModData.vanish_SuddenStart = midPoint - sizeThingy + getSubVal("offset");
    whichStrum.strumExtraModData.vanish_SuddenEnd = getSubVal("end") + getSubVal("offset");

    whichStrum.strumExtraModData.vanish_noGlow = getSubVal("noglow");
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var useOldStealthGlowStyle:Bool = data.whichStrumNote.strumExtraModData.useOldStealthGlowStyle;
    if (isArrowPath || data.noteType == "receptor" || (isHoldNote && !useOldStealthGlowStyle)) return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;

    var midPoint:Float = getSubVal("start") + getSubVal("end");
    midPoint /= 2;

    var sizeThingy:Float = getSubVal("size") / 2;

    var a:Float = FlxMath.remapToRange(curPos2, getSubVal("start") + getSubVal("offset"), midPoint + sizeThingy + getSubVal("offset"), 0, 1);

    a = FlxMath.bound(a, 0, 1); // clamp

    var b:Float = FlxMath.remapToRange(curPos2, midPoint - sizeThingy + getSubVal("offset"), getSubVal("end") + getSubVal("offset"), 0, 1);

    b = FlxMath.bound(b, 0, 1); // clamp
    var result:Float = a - b;

    if (getSubVal("noglow") >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= result * currentValue;
      return;
    }

    result *= currentValue;

    if (getSubVal("noglow") < 1) // if below 1, then we apply stealth glow.
    {
      var stealthGlow:Float = result * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - getSubVal("noglow")); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((result - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class BlinkMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 116;
    createSubMod("noglow", 0.0);
    createSubMod("offset", 0.0);
    createSubMod("speed", 1.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;

    var a:Float = sin((beatTime + getSubVal("offset")) * getSubVal("speed") * Math.PI) * 2;
    // f = Quantize(f, 0.3333 f);
    // var a:Float = FlxMath.remapToRange(f, 0, 1, -1, 0);
    a = FlxMath.bound(a, 0, 1); // clamp

    if (getSubVal("noglow") >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }
    a *= currentValue;

    if (getSubVal("noglow") < 1) // if below 0.5 -> then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - getSubVal("noglow")); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

// Notes fade to white and then fade out of existence
class StealthHoldsMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 120;
    createSubMod("noglow", 0.0);
    createSubMod("stealthpastreceptors", 1.0);
    unknown = false;
    notesMod = false;
    holdsMod = true;
    strumsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (!isArrowPath && isHoldNote)
    {
      var curPos2:Float = data.curPos_unscaled;
      curPos2 *= Preferences.downscroll ? -1 : 1;
      var pastReceptors:Float = 1;
      // if ((Preferences.downscroll && curPos2 > 0) || (!Preferences.downscroll && curPos2 < 0))
      if (curPos2 < 0)
      {
        pastReceptors = getSubVal("stealthpastreceptors");
      }

      if (getSubVal("noglow") >= 1.0) // If 1.0 -> just control alpha
      {
        data.alpha -= FlxMath.bound(currentValue * pastReceptors, 0, 1); // clamp
      }
      else if (getSubVal("noglow") >= 0.5) // if 0.5 -> same logic, just no stealthglow applied
      {
        var subtractAlpha:Float = (currentValue - 0.5) * 2;
        subtractAlpha = FlxMath.bound(subtractAlpha * pastReceptors, 0, 1); // clamp
        data.alpha -= subtractAlpha;
      }
      else // Else, acts like how it would in NotITG with 0.5 modValue being full stealth glow, 0.75 being half opacity, and 1 being fully invisible.
      {
        var stealthGlow:Float = currentValue * 2; // so it reaches max at 0.5
        data.stealth += FlxMath.bound(stealthGlow * pastReceptors, 0, 1); // clamp

        // extra math so alpha doesn't start fading until 0.5
        var subtractAlpha:Float = (currentValue - 0.5) * 2;
        subtractAlpha = FlxMath.bound(subtractAlpha * pastReceptors, 0, 1); // clamp
        data.alpha -= subtractAlpha;
      }
    }
  }
}

// Also include alpha mods!
class AlphaModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.alpha -= currentValue;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (!(data.noteType == "receptor" || data.noteType == "path"))
    {
      data.alpha -= currentValue;
    }
  }
}

class AlphaNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || isHoldNote || data.noteType == "receptor") return;
    data.alpha -= currentValue;
  }
}

class AlphaHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || !isHoldNote || data.noteType == "receptor") return;
    data.alpha -= currentValue;
  }
}

class AlphaStrumModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.alpha -= currentValue;
  }
}

class AlphaNoteSplashModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.alphaSplashMod = currentValue;
    // strumLine.alphaSplashMod[lane] = currentValue;
  }
}

class AlphaHoldCoverModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.alphaHoldCoverMod = currentValue;
    // strumLine.alphaHoldCoverMod[lane] = currentValue;
  }
}
