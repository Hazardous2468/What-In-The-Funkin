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
    strumsMod = false;
    pathMod = false;
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

// Notes fade to white and then fade out
class StealthMod extends Modifier
{
  var noGlowSubmod:ModifierSubValue;
  var stealthPastSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 120;
    noGlowSubmod = createSubMod("noglow", 0.0);
    stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0);
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
        pastReceptors = stealthPastSubmod.value;
      }

      if (noGlowSubmod.value >= 1.0) // If 1.0 -> just control alpha
      {
        data.alpha -= FlxMath.bound(currentValue * pastReceptors, 0, 1); // clamp
      }
      else if (noGlowSubmod.value >= 0.5) // if 0.5 -> same logic, just no stealthglow applied
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
  var noGlowSubmod:ModifierSubValue;

  // var stealthPastSubmod:ModifierSubValue;
  // The point where the notes start fading in
  var start:ModifierSubValue;

  // The point where the notes finish fading in
  var end:ModifierSubValue;

  // Offsets the start and end points by this amount
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 119;
    noGlowSubmod = createSubMod("noglow", 0.0);
    start = createSubMod("start", 500.0);
    end = createSubMod("end", 300.0);
    offset = createSubMod("offset", 0.0);
    // stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0); // is pretty much unused for sudden
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
    whichStrum.strumExtraModData.suddenStart = start.value + offset.value;
    whichStrum.strumExtraModData.suddenEnd = end.value + offset.value;
    whichStrum.strumExtraModData.sudden_noGlow = noGlowSubmod.value;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;
    // Don't do anything if we're past receptors! Maybe disable this if we want stealth past receptors?
    // if (curPos2 < 0) return;

    var a:Float = FlxMath.remapToRange(curPos2, start.value + offset.value, end.value + offset.value, 1, 0);

    // var a = FlxMath.remapToRange(curPos * -1, 500, 300, 0, 1); // scale

    a = FlxMath.bound(a, 0, 1); // clamp

    if (noGlowSubmod.value >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }

    a *= currentValue;

    if (noGlowSubmod.value < 1) // if below 0, then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - noGlowSubmod.value); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class HiddenMod extends Modifier
{
  // Disables the stealthGlow behaviour.
  var noGlowSubmod:ModifierSubValue;

  // If greater then 0, notes will reappear when passing the strumlineNotes
  var stealthPastSubmod:ModifierSubValue;

  // The point where the notes start fading out
  var start:ModifierSubValue;

  // The point where the notes finish fading out (fully invisible)
  var end:ModifierSubValue;

  // Offsets the start and end points by this amount
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 118;
    noGlowSubmod = createSubMod("noglow", 0.0);
    start = createSubMod("start", 500.0);
    end = createSubMod("end", 300.0);
    offset = createSubMod("offset", 0.0);
    stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0);
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
    whichStrum.strumExtraModData.hiddenStart = start.value + offset.value;
    whichStrum.strumExtraModData.hiddenEnd = end.value + offset.value;
    whichStrum.strumExtraModData.hidden_noGlow = noGlowSubmod.value;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;

    // Don't do anything if we're past receptors!
    if (stealthPastSubmod.value <= 0)
    {
      if (curPos2 < 0) return;
    }

    var a:Float = FlxMath.remapToRange(curPos2, start.value + offset.value, end.value + offset.value, 0, 1);
    a = FlxMath.bound(a, 0, 1); // clamp

    if (noGlowSubmod.value >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }
    a *= currentValue;

    if (noGlowSubmod.value < 1) // if below 1 -> then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - noGlowSubmod.value); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class VanishMod extends Modifier
{
  // Disables the stealthGlow behaviour.
  var noGlowSubmod:ModifierSubValue;

  // If greater then 0, notes will reappear when passing the strumlineNotes
  var stealthPastSubmod:ModifierSubValue;

  // The point where the notes start fading out (?)
  var start:ModifierSubValue;

  // The size of the hidden region (?)
  var size:ModifierSubValue;

  // The point where the notes fade back in (?)
  var end:ModifierSubValue;

  // Offsets the entire effect region by this amount
  var offset:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 117;
    noGlowSubmod = createSubMod("noglow", 0.0);
    start = createSubMod("start", 475.0);
    size = createSubMod("size", 195.0);
    end = createSubMod("end", 125.0);
    offset = createSubMod("offset", 0.0);
    stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0);
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

    var sizeThingy:Float = size.value / 2;
    var midPoint:Float = (start.value + end.value) / 2;

    whichStrum.strumExtraModData.vanish_HiddenStart = start.value + offset.value;
    whichStrum.strumExtraModData.vanish_HiddenEnd = midPoint + sizeThingy + offset.value;

    whichStrum.strumExtraModData.vanish_SuddenStart = midPoint - sizeThingy + offset.value;
    whichStrum.strumExtraModData.vanish_SuddenEnd = end.value + offset.value;

    whichStrum.strumExtraModData.vanish_noGlow = noGlowSubmod.value;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;

    var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
    curPos2 *= Preferences.downscroll ? -1 : 1;

    // Don't do anything if we're past receptors!
    if (stealthPastSubmod.value <= 0)
    {
      if (curPos2 < 0) return;
    }

    var midPoint:Float = (start.value + end.value) / 2;
    var sizeThingy:Float = size.value / 2;

    var a:Float = FlxMath.remapToRange(curPos2, start.value + offset.value, midPoint + sizeThingy + offset.value, 0, 1);

    a = FlxMath.bound(a, 0, 1); // clamp

    var b:Float = FlxMath.remapToRange(curPos2, midPoint - sizeThingy + offset.value, end.value + offset.value, 0, 1);

    b = FlxMath.bound(b, 0, 1); // clamp
    var result:Float = a - b;

    if (noGlowSubmod.value >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= result * currentValue;
      return;
    }

    result *= currentValue;

    if (noGlowSubmod.value < 1) // if below 1, then we apply stealth glow.
    {
      var stealthGlow:Float = result * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - noGlowSubmod.value); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((result - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

class BlinkMod extends Modifier
{
  // Disables the stealthGlow behaviour.
  var noGlowSubmod:ModifierSubValue;

  // If greater then 0, notes will reappear when passing the strumlineNotes
  var stealthPastSubmod:ModifierSubValue;

  // Offsets the blink timing
  var offset:ModifierSubValue;

  // How quickly the blinking is
  var speed:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 116;

    noGlowSubmod = createSubMod("noglow", 0.0);
    stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0);
    offset = createSubMod("offset", 0.0);
    speed = createSubMod("speed", 1.0);

    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = false;
    pathMod = false;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    // Don't do anything if we're past receptors!
    if (stealthPastSubmod.value <= 0)
    {
      var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);
      curPos2 *= Preferences.downscroll ? -1 : 1;
      if (curPos2 < 0) return;
    }

    var a:Float = sin((beatTime + offset.value) * speed.value * Math.PI) * 2;

    a = FlxMath.bound(a, 0, 1); // clamp

    if (noGlowSubmod.value >= 2.0) // If 2.0 -> just control alpha
    {
      data.alpha -= a * currentValue;
      return;
    }
    a *= currentValue;

    if (noGlowSubmod.value < 1) // if below 0.5 -> then we apply stealth glow.
    {
      var stealthGlow:Float = a * 2; // so it reaches max at 0.5
      data.stealth += FlxMath.bound(stealthGlow, 0, 1) * (1.0 - noGlowSubmod.value); // clamp
    }

    // extra math so alpha doesn't start fading until 0.5
    var subtractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
    data.alpha -= subtractAlpha;
  }
}

// Notes fade to white and then fade out
class StealthHoldsMod extends Modifier
{
  // Disables the stealthGlow behaviour.
  var noGlowSubmod:ModifierSubValue;

  // If greater then 0, notes will reappear when passing the strumlineNotes
  var stealthPastSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    modPriority = 120;
    noGlowSubmod = createSubMod("noglow", 0.0);
    stealthPastSubmod = createSubMod("stealthpastreceptors", 1.0);
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
        pastReceptors = stealthPastSubmod.value;
      }

      if (noGlowSubmod.value >= 1.0) // If 1.0 -> just control alpha
      {
        data.alpha -= FlxMath.bound(currentValue * pastReceptors, 0, 1); // clamp
      }
      else if (noGlowSubmod.value >= 0.5) // if 0.5 -> same logic, just no stealthglow applied
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
