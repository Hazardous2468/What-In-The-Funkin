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
  public var specialMathFunc:Void->Void;

  private var noteMathBroke:Bool = false;
  private var strumMathBroke:Bool = false;
  private var speedMathBroke:Bool = false;
  private var specialMathBroke:Bool = false;

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

    return newShit;
  }

  public function new(name:String, baseVal:Float = 0)
  {
    super(name, baseVal);

    // Add it to all mod arrays by default!
    unknown = false;
    strumsMod = true;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
    specialMod = true;
    speedMod = true;

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
        specialMathFunc();
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
  public var value:Float = 0.0;
  public var baseValue:Float = 0.0;

  public function new(value:Float)
  {
    // super("submod");
    this.value = value;
    baseValue = value;
  }
}

class Modifier
{
  // Variable used for testing if a mod already exists or some shit.
  public var fuck:Bool = false;

  var beatTime(get, never):Float;

  function get_beatTime():Float
  {
    return Conductor.instance?.currentBeatTime ?? 0.0;
  }

  var songTime(get, never):Float;

  function get_songTime():Float
  {
    return Conductor.instance?.songPosition ?? 0.0;
  }

  // Variables for defining which array this mod should be added to for performance reasons!
  public var unknown:Bool = true; // If true, will probe the mod to try and figure out what it does
  public var specialMod:Bool = false;
  public var pathMod:Bool = false;
  public var notesMod:Bool = false;
  public var holdsMod:Bool = false;
  public var strumsMod:Bool = false;
  public var speedMod:Bool = false;

  public var tag:String = "mod";
  public var baseValue:Float = 0;

  public var currentValue(default, set):Float = 0;

  private function set_currentValue(newValue:Float)
  {
    currentValue = newValue;
    if (strumOwner != null) strumOwner.debugNeedsUpdate = true;
    return currentValue;
  }

  public var subValues:Map<String, ModifierSubValue>;

  public var targetLane:Int = -1;
  public var modPriority:Float = 100; // 100 is default. higher priority = done first

  public var modPriority_additive:Float = 0; // gets added onto the priority so the modchart creator can control mod priority midsong. Done this way to avoid overiding the original priority.

  // who owns this mod?
  public var strumOwner:Strumline = null;

  public function new(tag:String, baseValue:Float = 0)
  {
    // super(tag);
    this.tag = tag;

    this.baseValue = baseValue;
    this.currentValue = this.baseValue;

    subValues = ["dumb_setup" => new ModifierSubValue(0.0)];
    subValues.remove("dumb_setup");
  }

  public function reset():Void // for the editor
  {
    currentValue = baseValue;
    modPriority_additive = 0;
    for (subMod in subValues)
      subMod.value = subMod.baseValue;
  }

  public function getSubVal(name):Float
  {
    var sub = subValues.get(name);
    if (sub != null) return sub.value;
    else
    {
      PlayState.instance.modDebugNotif(name + " is not a valid subname!\nReturning 0.0...");
      return 0.0;
    }
  }

  public function setSubVal(name, newval):Void
  {
    if (name == "priority")
    {
      this.modPriority_additive = newval;
    }
    else
    {
      var sub = subValues.get(name);
      if (sub != null)
      {
        sub.value = newval;
        if (strumOwner != null) strumOwner.debugNeedsUpdate = true;
      }
      else
      {
        // trace(name + " is not a valid subname!");
        PlayState.instance.modDebugNotif(name + " is not a valid subname!");
      }
    }
  }

  public function setVal(newval):Void
  {
    currentValue = newval;
  }

  public function setDefaultSubVal(name, newval):Void
  {
    var sub = subValues.get(name);
    if (sub != null) sub.baseValue = newval;
    else
    {
      PlayState.instance.modDebugNotif(name + " is not a valid subname!");
      // trace(name + "not valid lol");
    }
  }

  public function setDefaultVal(newval):Void
  {
    baseValue = newval;
  }

  public function createSubMod(name:String, startVal:Float):Void
  {
    var newSubMod = new ModifierSubValue(startVal);
    newSubMod.value = startVal;
    newSubMod.baseValue = startVal;
    subValues.set(name, newSubMod);
  }

  public dynamic function speedMath(lane:Int, curPos:Float, strumLine:Strumline, isHoldNote:Bool = false):Float
  {
    return 1.0;
  }

  public dynamic function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void {}

  public dynamic function specialMath(lane:Int, strumLine:Strumline):Void {}

  public dynamic function strumMath(data:NoteData, strumLine:Strumline):Void {}
}
