package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
// funkin stuff
import funkin.play.PlayState;
import funkin.Conductor;
import funkin.play.song.Song;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
// Math and utils
import StringTools;
import flixel.math.FlxMath;
import lime.math.Vector2;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModConstants;
import lime.math.Vector4;
import funkin.play.modchartSystem.NoteData;
import flixel.util.FlxColor;

class CustomModifier extends Modifier
{
  // public var speedMathFunc:NoteData->Float;
  public var speedMathFunc = (curPos:Float, lane:Int) -> (1.0 : Float);
  public var noteMathFunc:NoteData->Void;
  public var strumMathFunc:NoteData->Void;
  public var specialMathFunc:Int->Void;

  private var noteMathBroke:Bool = false;
  private var strumMathBroke:Bool = false;
  private var speedMathBroke:Bool = false;
  private var specialMathBroke:Bool = false;

  // Create and return a new copy of this CustomModifier

  public function clone():CustomModifier
  {
    var newShit:CustomModifier = new CustomModifier(tag, baseValue);

    newShit.speedMathFunc = this.speedMathFunc;
    newShit.noteMathFunc = this.noteMathFunc;
    newShit.strumMathFunc = this.strumMathFunc;
    newShit.specialMathFunc = this.specialMathFunc;

    newShit.modPriority = this.modPriority;
    newShit.targetLane = this.targetLane;

    newShit.unknown = this.unknown;
    newShit.strumsMod = this.strumsMod;
    newShit.notesMod = this.notesMod;
    newShit.holdsMod = this.holdsMod;
    newShit.pathMod = this.pathMod;
    newShit.specialMod = this.specialMod;
    newShit.speedMod = this.speedMod;

    newShit.notPercentage = this.notPercentage;

    return newShit;
  }

  public function new(name:String, baseVal:Float = 0)
  {
    super(name, baseVal);

    // Add it to all mod arrays by default!
    /*
      unknown = false;
      strumsMod = true;
      notesMod = true;
      holdsMod = true;
      pathMod = true;
      specialMod = true;
      speedMod = true;
     */

    notPercentage = true; // default to not using %

    noteMathBroke = false;
    strumMathBroke = false;
    specialMathBroke = false;
    speedMathBroke = false;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (strumMathFunc != null && !strumMathBroke)
    {
      try
      {
        strumMathFunc(data);
      }
      catch (e:Dynamic)
      {
        PlayState.instance.modDebugNotif(tag + " strum math error - " + e, FlxColor.RED);
        strumMathBroke = true;
      }
    }
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (noteMathFunc != null && !noteMathBroke)
    {
      try
      {
        noteMathFunc(data);
      }
      catch (e:Dynamic)
      {
        PlayState.instance.modDebugNotif(tag + " note math error - " + e, FlxColor.RED);
        noteMathBroke = true;
      }
    }
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (speedMathBroke || speedMathFunc == null) return 1;

    var r:Float = 1;
    try
    {
      r = speedMathFunc(curPos, lane);
    }
    catch (e:Dynamic)
    {
      PlayState.instance.modDebugNotif(tag + " speed math error - " + e, FlxColor.RED);
      speedMathBroke = true;
    }
    return r;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    if (specialMathFunc != null && !specialMathBroke)
    {
      try
      {
        specialMathFunc(lane);
      }
      catch (e:Dynamic)
      {
        PlayState.instance.modDebugNotif(tag + " special math error - " + e, FlxColor.RED);
        specialMathBroke = true;
      }
    }
  }
}

// A lot of math came from here:
// https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/Modifier.hx

class ModifierSubValue
{
  /**
   * The current value of this subMod.
   */
  public var value(default, set):Float = 0.0;

  function set_value(v:Float):Float
  {
    value = v;
    if (parentMod?.strumOwner != null) parentMod.strumOwner.debugNeedsUpdate = true;
    return value;
  }

  /**
   * The base value of this subMod. Will reset to this value when reset() is called on it's parent!
   */
  public var baseValue:Float = 0.0;

  /**
   * The modifier this subMod belong to.
   */
  public var parentMod:Modifier;

  public function new(value:Float)
  {
    this.value = value;
    baseValue = value;
  }
}

class Modifier
{
  var beatTime(get, never):Float;

  function get_beatTime():Float
  {
    #if FEATURE_WITF_USE_TIME_DELTA
    return ModConstants.getBeatPositionWithDelta();
    #else
    return Conductor.instance?.currentBeatTime ?? 0.0;
    #end
  }

  var songTime(get, never):Float;

  function get_songTime():Float
  {
    return ModConstants.getSongPosition();
    // return Conductor.instance?.songPosition ?? 0.0;
  }

  function sin(r:Float):Float
  {
    return strumOwner?.mods?.sin(r) ?? FlxMath.fastSin(r);
  }

  function cos(r:Float):Float
  {
    return strumOwner?.mods?.cos(r) ?? FlxMath.fastCos(r);
  }

  function tan(r:Float):Float
  {
    return strumOwner?.mods?.tan(r) ?? ModConstants.fastTan(r);
  }

  // Variables for defining which array this mod should be added to for performance reasons!

  /**
   * If true, then the mod will get probed to try and identify what it does in order to place it into the correct modifier array.
   */
  public var unknown:Bool = true;

  /**
   * If true, this modifier will be placed into the 'special' modifiers array.
   */
  public var specialMod:Bool = false;

  /**
   * If true, this modifier will be placed into the 'arrowpaths' modifiers array.
   */
  public var pathMod:Bool = false;

  /**
   * If true, this modifier will be placed into the 'notes' modifiers array.
   */
  public var notesMod:Bool = false;

  /**
   * If true, this modifier will be placed into the 'holds' modifiers array.
   */
  public var holdsMod:Bool = false;

  /**
   * If true, this modifier will be placed into the 'strums' modifiers array.
   */
  public var strumsMod:Bool = false;

  /**
   * If true, this modifier will be placed into the 'speed' modifiers array.
   */
  public var speedMod:Bool = false;

  /**
   * If true, then the mod value for this modifier will be multiplied by -1 for the opponent IF invert mode is on for the modchart.
   */
  public var invertForDad:Bool = false;

  /**
   * If true, this modifier will be hidden from the modifier list by default to make it cleaner.
   * Use 'debugShowExtra' modifier to make these modifiers appear.
   */
  public var utility:Bool = false;

  /**
   * If true, will display it's values always as raw values (never as %).
   * Remember this only affects how it DISPLAYS it's values!
   */
  public var notPercentage:Bool = false;

  /**
   * The UNIQUE tag for this modifier.
   * Used to identify it from the modifier array when tweens want to target a modifier and such.
   */
  public var tag:String = "mod";

  /**
   * The base / starting value of this modifier.
   * 'currentValue' will reset back to this value when a reset is triggered.
   */
  public var baseValue:Float = 0;

  /**
   * The current value for this modifier.
   */
  public var currentValue(default, set):Float = 0;

  private function set_currentValue(newValue:Float)
  {
    currentValue = newValue;
    if (strumOwner != null) strumOwner.debugNeedsUpdate = true;
    return currentValue;
  }

  /**
   * A map containing all the submodifiers for this modifier.
   */
  public var subValues:Map<String, ModifierSubValue> = new Map<String, ModifierSubValue>();

  /**
   * For converting an alias to the submods real name
   */
  public var subValuesAliasMap:Map<String, String> = new Map<String, String>();

  /**
   * The lane this modifier will target.
   * For example, 0 will target the left lane, 2 will target the up lane.
   * -1 will target all lanes and is the default.
   */
  public var targetLane:Int = -1;

  /**
   * A map containing all the submodifiers for this modifier.
   * 100 is default. higher priority = done first.
   * Should never really be changed mid-song.
   */
  public var modPriority:Float = 100;

  /**
   * A value that gets added onto the 'modPriority' value so the modchart creator can control mod priority midsong.
   * Done this way to avoid overriding the original priority (for resets to work and what not).
   * Primarily changed by trying to access a modifier's 'priority' submod.
   */
  public var modPriority_additive:Float = 0;

  /**
   * The Strumline this modifier belongs to.
   * Is automatically set when the mod gets added.
   */
  public var strumOwner:Strumline = null;

  public function new(tag:String, baseValue:Float = 0)
  {
    // super(tag);
    this.tag = tag;

    this.baseValue = baseValue;
    this.currentValue = this.baseValue;
  }

  public function reset():Void
  {
    currentValue = baseValue;
    modPriority_additive = 0;
    for (subMod in subValues) subMod.value = subMod.baseValue;
  }

  public function getSubVal(name):Float
  {
    final sub = subValues.get(name);
    if (sub != null) return sub.value;
    else
    {
      PlayState.instance.modDebugNotif(name + " is not a valid subname!\nReturning 0.0...", FlxColor.RED);
      return 0.0;
    }
  }

  // easy helper function for setting subValues. Kind of obsolete now.

  public function setSubVal(name:String, newval:Float):Void
  {
    if (name == "priority")
    {
      this.modPriority_additive = newval;
    }
    else
    {
      final sub = subValues.get(name);
      if (sub != null)
      {
        sub.value = newval;
        if (strumOwner != null) strumOwner.debugNeedsUpdate = true;
      }
      else
      {
        PlayState.instance.modDebugNotif(name + " is not a valid subname!", FlxColor.RED);
      }
    }
  }

  public function setVal(newValue:Float):Void
  {
    currentValue = newValue;
  }

  public function setDefaultSubVal(name:String, newValue:Float):Void
  {
    if (name == "priority")
    {
      this.modPriority_additive = newValue;
      return;
    }
    final sub = subValues.get(name);
    if (sub != null)
    {
      sub.baseValue = newValue;
      if (strumOwner != null) strumOwner.debugNeedsUpdate = true;
    }
    else
    {
      PlayState.instance.modDebugNotif(name + " is not a valid subname!", FlxColor.RED);
    }
  }

  public function setDefaultVal(newValue:Float):Void
  {
    baseValue = newValue;
  }

  /**
   * Creates a new ModifierSubValue and automatically adds it to the 'subValues' map.
   * @param name      The name / tag for this subModifier.
   * @param startVal  The base / starting value for this subModifier.
   * @param aliases   An array of aliases that can be used to refer to this submodifier.
   * @return The newly created ModifierSubValue.
   */
  public function createSubMod(name:String, startVal:Float, ?aliases:Array<String>):ModifierSubValue
  {
    final newSubMod:ModifierSubValue = new ModifierSubValue(startVal);
    newSubMod.value = startVal;
    newSubMod.baseValue = startVal;
    newSubMod.parentMod = this;
    subValues.set(name, newSubMod);

    if (aliases != null)
    {
      for (alias in aliases)
      {
        if (subValuesAliasMap.exists(alias))
        {
          PlayState.instance.modDebugNotif(
            "'" + alias + "' alias for the submod '" + name + "__" + this.tag + ")' is already taken by '" + subValuesAliasMap.get(alias) + "'",
            FlxColor.ORANGE
          );
        }
        else
        {
          subValuesAliasMap.set(alias, name);
        }
      }
    }
    return newSubMod;
  }

  /**
   * Converts a submod name to it's real name.
   * @param inputName The input string to check the submod alias map with.
   * @return The submod's proper name IF the alias exists for it. Otherwise will return the input.
   */
  public function subModAliasConvert(inputName:String):String
  {
    if (subValuesAliasMap.exists(inputName))
    {
      return subValuesAliasMap.get(inputName);
    }
    else
    {
      return inputName;
    }
  }

  public dynamic function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote:Bool = false):Float
  {
    return 1.0;
  }

  public dynamic function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
  }

  public dynamic function specialMath(lane:Int, strumLine:Strumline):Void
  {
  }

  public dynamic function strumMath(data:NoteData, strumLine:Strumline):Void
  {
  }
}
