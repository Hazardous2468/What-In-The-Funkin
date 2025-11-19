package funkin.play.modchartSystem;

import flixel.FlxG;
// funkin stuff
import funkin.play.PlayState;
import funkin.Conductor;
import funkin.play.song.Song;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.Paths;
import flixel.util.FlxColor;
// Math and utils
import StringTools;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import funkin.util.SortUtil;
import flixel.util.FlxSort;
// tween
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
// mod system
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.ModTimeEvent;
import funkin.play.modchartSystem.ModHandler;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.modding.events.ScriptEvent;
import funkin.play.modchartSystem.HazardEase;
import funkin.play.notes.StrumlineNote;
// for testing
import funkin.audio.FunkinSound;

class ModEventHandler
{
  public var modResetFuncs:Array<Void->Void> = [];

  public var modEvents:Array<ModTimeEvent> = [];
  public var tweenManager:FlxTweenManager;
  public var customEases:Map<String, Null<Float->Float>> = new Map<String, Null<Float->Float>>();

  public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

  // If set to true, then MOST mods will be divided by 100% when being added into the timeline. This is so you can treat it like NotITG lmao. Currently not implemented.
  public var percentageMods:Bool = false;

  // If set to true, then some mods will be inverted for opponent. Defaults to false. Hasn't been tested / used in a long time. Could potentially be deprecated.
  public var invertForOpponent:Bool = false;

  public function new()
  {
    modEvents = new Array();
    tweenManager = new FlxTweenManager();
  }

  // Call this to add events to the events array (so stuff can happen lol)
  public function setupEvents():Void
  {
    addModsFromEventList();
  }

  public function clearEvents():Void
  {
    for (key in customEases.keys())
    {
      customEases.remove(key);
    }

    for (key in modchartTweens.keys())
    {
      modchartTweens.get(key).cancel();
      modchartTweens.remove(key);
    }

    modResetFuncs = new Array();

    for (modEvent in modEvents)
    {
      modEvent.hasTriggered = false;
    }
    tweenManager.clear();
    tweenCounter = 0;

    modEvents = new Array();

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;
      strum.mods.resetModValues();
      strum.mods.clearMods();
      // strum.mods.addMod('speedmod', 1); // Every strum ALWAYS has this modifier by default.
    }
  }

  var songTime:Float = 0;
  var lastReportedSongTime:Float = 0;
  var beatTime:Float = 0;
  var lastReportedBeatTime:Float = 0;
  final backInTimeLeniency:Float = 150; // in Miliseconds. Done because V-Slice sometimes often tries to go backwards in time? (???)

  public function update(elapsed:Float):Void
  {
    songTime = Conductor.instance.songPosition;
    beatTime = Conductor.instance.currentBeatTime;

    if (songTime + ((PlayState.instance?.isGamePaused ?? false) ? 0 : backInTimeLeniency) < lastReportedSongTime)
    {
      lastReportedBeatTime = beatTime;
      resetMods(); // Just reset everything and let the event handler put everything back.
    }

    // Make sure "handleEvents()" is called after the tweenManager has been updated to prevent issues.
    tweenManager.update((beatTime - lastReportedBeatTime));
    handleEvents();

    lastReportedSongTime = songTime;
    lastReportedBeatTime = beatTime;
  }

  // Add a custom mod, make sure this is done BEFORE events are sorted!
  public function addCustomMod(playerTarget:String, mod:CustomModifier, makeCopy:Bool = false):Void
  {
    // check if the name is valid. For now, just checks if its sub lol
    if (ModConstants.isTagSub(mod.tag))
    {
      PlayState.instance.modDebugNotif(mod.tag + " is not a valid custom mod name!", FlxColor.RED);
      return;
    }

    // Add it to the mod handlers
    if (playerTarget == "both" || playerTarget == "all")
    {
      for (customStrummer in PlayState.instance.allStrumLines)
      {
        customStrummer.mods.addCustomMod(mod, makeCopy);
      }
    }
    else
    {
      final modsTarget = ModConstants.grabStrumModTarget(playerTarget);
      modsTarget.addCustomMod(mod, makeCopy);
    }
  }

  // Call this to scan and preload all mods which will be used by the song.
  function addModsFromEventList():Void
  {
    // Sorts the event in chronological order
    modEvents.sort(function(a, b) {
      if (a.startingBeat < b.startingBeat) return -1;
      else if (a.startingBeat > b.startingBeat) return 1;
      else
      {
        // if (a.startingBeat == b.startingBeat) return (a.style == "reset" && !(b.style == "reset") ? 1 : -1); // Same as mirin so reset gets priority!
        return 0;
      }
    });

    // Adding mods to the modHandlers!
    for (i in 0...modEvents.length)
    {
      final timeEventTest = modEvents[i];

      if (timeEventTest.style == "resort" || timeEventTest.style == "func" || timeEventTest.style == "func_tween" || timeEventTest.style == "reset"
        || timeEventTest.style == "perframe") continue;

      var modifierName:String = timeEventTest.modName;

      // check if sub first to avoid adding a subvalue as a mod!
      if (ModConstants.isTagSub(modifierName))
      {
        // if we are a submod, then we try and add the source modifier
        modifierName = modifierName.split('__')[0];
      }

      if (!timeEventTest.target.modifiers.exists(modifierName))
      {
        timeEventTest.target.addMod(modifierName);

        final mmm:Float = ModConstants.invertValueCheck(modifierName, timeEventTest.target.invertValues);
        timeEventTest.target.modifiers.get(modifierName).currentValue *= mmm;
      }
    }

    for (strumLine in PlayState.instance.allStrumLines)
    {
      strumLine.mods.sortMods();

      trace("\nSTRUM-" + strumLine.mods.customTweenerName + " mods list: \n" + strumLine.mods.modifiers);
    }
  }

  function modchartTweenCancel(tag:String):Void
  {
    if (modchartTweens.exists(tag))
    {
      modchartTweens.get(tag).cancel();
      modchartTweens.remove(tag);
      // trace("killing tween from tweenCancelFunc - " + tag);
    }
  }

  // Every single tween is given a unique ID! Done so additive tweens can overlap properly.
  var tweenCounter:Int = 0;

  // A function that gets a modifier name, and outputs the actual modifier.
  function figureOutMod(target:ModHandler, modName:String):Modifier
  {
    var mod:Modifier = null;

    var _tag:String = modName.toLowerCase();
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);
    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(_tag))
    {
      isSub = true;
      subModArr = _tag.split('__');
    }

    if (isSub)
    {
      mod = target.modifiers.get(subModArr[0]);
    }
    else
    {
      mod = target.modifiers.get(_tag);
    }

    return mod;
  }

  // HERE BE MAGIC
  // Tween a mod from one value to another.
  function tweenMod(target:ModHandler, modName:String, newValue:Float, time:Float, easeToUse:Null<Float->Float>, type:String = "tween",
      startingValue:Float = 0):FlxTween
  {
    // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);

    var _tag:String = modName.toLowerCase();
    cancelTweensOf(_tag, target);
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    // trace("// !Triggered a tween! \\");
    // trace("Tween tag: " + realTag);
    // trace("Mod to tween: " + _tag);
    // trace("-------------------------");

    tweenCounter++;

    final mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
    newValue *= mmm;

    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(_tag))
    {
      isSub = true;
      subModArr = _tag.split('__');
      // _tag = subModArr[1];
    }

    if (isSub)
    {
      final mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod == null)
      {
        PlayState.instance.modDebugNotif(subModArr[0] + " is not a valid mod name!", FlxColor.RED);
        return null;
      }
      else
      {
        final subModName:String = mod.subModAliasConvert(subModArr[1]);
        final isPriority:Bool = subModName == "priority";
        if (isPriority)
        {
          final startPoint:Float = (type == "value" ? startingValue : mod.modPriority_additive);
          final finishPoint:Float = startPoint + ((newValue - startPoint) * easeToUse(1.0));
          if (time == 0) // no tween required!
          {
            mod.modPriority_additive = finishPoint;
            return null;
          }
          var tween:FlxTween = tweenManager.num(startPoint, newValue, time,
            {
              ease: easeToUse,
              onComplete: function(twn:FlxTween) {
                modchartTweens.remove(realTag);
                mod.modPriority_additive = finishPoint;
              }
            }, function(v) {
              mod.modPriority_additive = v;
            });

          modchartTweens.set(realTag, tween);
          return tween;
        }
        else
        {
          var subMod:ModifierSubValue;
          if (mod.subValues.exists(subModName))
          {
            subMod = mod.subValues.get(subModName);
          }
          else
          {
            PlayState.instance.modDebugNotif(subModArr[1] + " is not a valid submod name!", FlxColor.RED);
            return null;
          }

          final startPoint:Float = (type == "value" ? startingValue : subMod.value);
          final finishPoint:Float = startPoint + ((newValue - startPoint) * easeToUse(1.0));
          if (time == 0) // no tween required!
          {
            subMod.value = finishPoint;
            return null;
          }
          var tween:FlxTween = tweenManager.num(startPoint, newValue, time,
            {
              ease: easeToUse,
              onComplete: function(twn:FlxTween) {
                modchartTweens.remove(realTag);
                subMod.value = finishPoint;
              }
            }, function(v) {
              subMod.value = v;
            });
          modchartTweens.set(realTag, tween);
          return tween;
        }
      }
    }

    final mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      final startPoint:Float = (type == "value" ? startingValue : mod.currentValue);
      final finishPoint:Float = startPoint + ((newValue - startPoint) * easeToUse(1.0));
      var tween:FlxTween = tweenManager.num(startPoint, newValue, time,
        {
          ease: easeToUse,
          onComplete: function(twn:FlxTween) {
            modchartTweens.remove(realTag);
            mod.currentValue = finishPoint;
          }
        }, function(v) {
          mod.currentValue = v;
        });

      modchartTweens.set(realTag, tween);
      return tween;
    }
    else
    {
      return null;
    }
  }

  function appendAdditiveTag(isSub:Bool = false):String
  {
    return '++' + (isSub ? "s" : "m") + tweenCounter;
  }

  // Tween a mod from one value to another.
  function tweenAddMod(target:ModHandler, modName:String, addValue:Float, time:Float, easeToUse:Null<Float->Float>):FlxTween
  {
    // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);

    var _tag:String = modName.toLowerCase();
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    tweenCounter++;
    final mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
    addValue *= mmm;

    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(_tag))
    {
      isSub = true;
      subModArr = _tag.split('__');
    }

    realTag += appendAdditiveTag(isSub);

    if (isSub)
    {
      final mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod == null)
      {
        PlayState.instance.modDebugNotif(subModArr[0] + " is not a valid mod name!", FlxColor.RED);
        return null;
      }
      else
      {
        final subModName:String = mod.subModAliasConvert(subModArr[1]);
        var isPriority:Bool = subModName == "priority";
        if (isPriority)
        {
          if (time == 0) // no tween required!
          {
            final v:Float = addValue * easeToUse(1.0);
            mod.modPriority_additive += v;
            return null;
          }
          var lastReportedChange:Float = 0;
          var tween:FlxTween = tweenManager.num(0, 1, time,
            {
              ease: FlxEase.linear,
              onComplete: function(twn:FlxTween) {
                modchartTweens.remove(realTag);
                final v:Float = addValue * easeToUse(1.0);
                mod.modPriority_additive += (v - lastReportedChange);
                lastReportedChange = v;
              }
            }, function(t) {
              final v:Float = addValue * easeToUse(t);
              mod.modPriority_additive += (v - lastReportedChange);
              lastReportedChange = v;
            });
          modchartTweens.set(realTag, tween);
          return tween;
        }
        else
        {
          var subMod:ModifierSubValue;
          if (mod.subValues.exists(subModName))
          {
            subMod = mod.subValues.get(subModName);
          }
          else
          {
            PlayState.instance.modDebugNotif(subModArr[1] + " is not a valid submod name!", FlxColor.RED);
            return null;
          }

          if (time == 0) // no tween required!
          {
            final v:Float = addValue * easeToUse(1.0);
            subMod.value += v;
            return null;
          }
          var lastReportedChange:Float = 0;
          var tween:FlxTween = tweenManager.num(0, 1, time,
            {
              ease: FlxEase.linear,
              onComplete: function(twn:FlxTween) {
                modchartTweens.remove(realTag);
                final v:Float = addValue * easeToUse(1.0);
                subMod.value += (v - lastReportedChange);
                lastReportedChange = v;
              }
            }, function(t) {
              final v:Float = addValue * easeToUse(t);
              subMod.value += (v - lastReportedChange);
              lastReportedChange = v;
            });
          modchartTweens.set(realTag, tween);
          return tween;
        }
      }
    }

    final mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      if (time == 0)
      {
        final v:Float = addValue * easeToUse(1.0);
        mod.currentValue = mod.currentValue + (v);
        return null;
      }
      else
      {
        var lastReportedChange:Float = 0;
        var tween:FlxTween = tweenManager.num(0, 1, time,
          {
            ease: FlxEase.linear,
            onComplete: function(twn:FlxTween) {
              modchartTweens.remove(realTag);
              final v:Float = addValue * easeToUse(1.0);
              mod.currentValue = mod.currentValue + (v - lastReportedChange);
              lastReportedChange = v;
            }
          }, function(t) {
            final v:Float = addValue * easeToUse(t); // ???, cuz for some silly reason tweenValue was being set incorrectly by the tween function / manager? I don't know lmfao
            mod.currentValue = mod.currentValue + (v - lastReportedChange);
            lastReportedChange = v;
          });
        modchartTweens.set(realTag, tween);
        return tween;
      }
    }
    else
    {
      return null;
    }
  } // This function will trigger all the functions that need to be called when a reset is triggered!

  public function triggerResetFuncs():Void
  {
    for (resetFunc in modResetFuncs)
    {
      try
      {
        resetFunc();
      }
      catch (e)
      {
        modResetFuncs.remove(resetFunc);
        PlayState.instance.modDebugNotif(e.toString(), FlxColor.RED);
        return;
      }
    }
  }

  // If true, then the modfile has the resort function in it. Used in the resetMods function to resort everything back to default.
  public var modChartHasResort:Bool = false;

  // Call this function to resetEvents!
  public function resetMods():Void
  {
    // trace("------------------------");
    // trace("// !MOD EVENTS RESET! \\");
    // trace("------------------------");

    for (key in modchartTweens.keys())
    {
      modchartTweens.get(key).cancel();
      modchartTweens.remove(key);
    }
    triggerResetFuncs();

    for (modEvent in modEvents)
    {
      modEvent.hasTriggered = false;
    }
    tweenManager.clear();
    tweenCounter = 0;

    // HazardModLuaTest.allTargetExlusions = [];

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;

      strum.isPlayerControlled = strum.defaultPlayerControl;

      strum.mods.resetModValues();
      if (modChartHasResort)
      {
        for (m in strum.mods.mods_all)
        {
          m.modPriority_additive = 0;
        }
        resortMods_ForTarget(strum.mods);
      }

      strum.strumlineNotes.forEach(function(note:StrumlineNote) {
        note.resetStealthGlow();
      });
    }
    PlayState.instance.dispatchEvent(new ScriptEvent(MODCHART_RESET));
  }

  // This function is responsible for triggering events!
  function handleEvents():Void
  {
    for (i in 0...modEvents.length)
    {
      final modEvent:ModTimeEvent = modEvents[i];
      if (modEvent.hasTriggered) continue;
      var tween:FlxTween = null;

      // If beat time is PAST the event!
      if (beatTime >= modEvent.startingBeat + modEvent.timeInBeats
        && !(modEvent.style == "func" && modEvent.persist)
        && modEvent.style != "reset"
        && modEvent.style != "resort")
      {
        modEvent.hasTriggered = true;
        if (!modEvent.persist) continue; // lol

        switch (modEvent.style)
        {
          case "add":
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, 0.0, modEvent.easeToUse);
          case "add_old":
            var modToTween:Modifier;
            if (modEvent.target.modifiers.exists(modEvent.modName))
            {
              modToTween = modEvent.target.modifiers.get(modEvent.modName);
            }
            else
            {
              continue; // next event please
            }
            setModVal(modEvent.target, modEvent.modName, modToTween.currentValue + (modEvent.gotoValue * (modEvent?.easeToUse(1))), false);

          case "func_tween":
            if (modEvent.modName != null)
            {
              modchartTweenCancel(modEvent.modName.toLowerCase());
            }
            final finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
            try
            {
              modEvent.tweenFunky(finishPoint);
            }
            catch (e)
            {
              PlayState.instance.modDebugNotif(e.toString(), 0xFFFF0000);
            }
            continue;

          case "set":
            setModVal(modEvent.target, modEvent.modName, modEvent.gotoValue, true);
            continue;
          case "value":
            // grab current mod value
            final finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
            setModVal(modEvent.target, modEvent.modName, finishPoint, true);

            continue;
          case "tween":
            // grab current mod value
            final mod:Modifier = figureOutMod(modEvent.target, modEvent.modName);
            if (mod != null)
            {
              final finishPoint:Float = mod.currentValue + ((modEvent.gotoValue - mod.currentValue) * modEvent.easeToUse(1.0));
              setModVal(modEvent.target, modEvent.modName, finishPoint, true);
            }
            else
            {
              PlayState.instance.modDebugNotif("Tween set error! \n" + modEvent.modName, 0xFFFF7300);
              setModVal(modEvent.target, modEvent.modName, modEvent.gotoValue, true);
            }
            continue;
          default:
            // modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue);
            PlayState.instance.modDebugNotif("Unknown event type!", 0xFFFF7300);
            continue;
        }
      }
      else if (beatTime >= modEvent.startingBeat) // Trigger the event, and set the tween to be at the proper position!
      {
        modEvent.hasTriggered = true;
        switch (modEvent.style)
        {
          case "reset":
            resetMods_ForTarget(modEvent.target);
            continue;
          case "resort":
            resortMods_ForTarget(modEvent.target);
            continue;
          case "set":
            setModVal(modEvent.target, modEvent.modName, modEvent.gotoValue, true);
            continue;
          case "tween":
            tween = tweenMod(modEvent.target, modEvent.modName, modEvent.gotoValue, modEvent.timeInBeats, modEvent.easeToUse, "tween");

          case "value":
            tween = tweenMod(modEvent.target, modEvent.modName, modEvent.gotoValue, modEvent.timeInBeats, modEvent.easeToUse, "value", modEvent.startValue);

          case "add":
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, modEvent.timeInBeats, modEvent.easeToUse);
          case "add_old":
            var modToTween;
            if (modEvent.target.modifiers.exists(modEvent.modName))
            {
              modToTween = modEvent.target.modifiers.get(modEvent.modName);
            }
            else
            {
              trace("ERROR, COULDN'T ADD TO MOD, I DIDN'T EXIST! " + modEvent.modName);
              continue;
            }

            tween = tweenMod(modEvent.target, modEvent.modName, modToTween.currentValue + modEvent.gotoValue, modEvent.timeInBeats, modEvent.easeToUse, "add");
          case "func":
            if (modEvent.modName != null) modchartTweenCancel(modEvent.modName.toLowerCase());
            try
            {
              modEvent.triggerFunction();
            }
            catch (e)
            {
              PlayState.instance.modDebugNotif(e.toString(), 0xFFFF0000);
            }

            continue;
          case "func_tween":
            var tweenTagged:Bool = false;
            if (modEvent.modName != null)
            {
              tweenTagged = true;
              modchartTweenCancel(modEvent.modName.toLowerCase());
            }

            final finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
            tween = tweenManager.num(modEvent.startValue, modEvent.gotoValue, modEvent.timeInBeats,
              {
                ease: modEvent.easeToUse,
                onComplete: function(twn:FlxTween) {
                  if (tweenTagged) modchartTweens.remove(modEvent.modName.toLowerCase());
                  modEvent.tweenFunky(finishPoint);
                }
              }, function(v) {
                try
                {
                  modEvent.tweenFunky(v);
                }
                catch (e)
                {
                  PlayState.instance.modDebugNotif(e.toString(), 0xFFFF0000);
                }
              });
            if (tweenTagged) modchartTweens.set(modEvent.modName.toLowerCase(), tween);
        }
      }
      // We add how many beats have elapsed from the starting beat to move the tween to it's proper position (for if we jump to the middle of a tween)
      if (tween != null)
      {
        @:privateAccess
        tween._secondsSinceStart += (beatTime - modEvent.startingBeat);
        @:privateAccess
        tween.update(0);
      }
    }
  }

  // Call this function to cancel every tween that matches this tag
  public function cancelTweensOf(tag:String, target:ModHandler):Void
  {
    final lookForInString:String = ModConstants.modTag(tag, target);
    // plr3.scale

    for (key in modchartTweens.keys())
    {
      // remove the additive stuff
      var key_edited:String = key;
      if (StringTools.contains(key, "++"))
      {
        key_edited = key.split('++')[0];
      }

      if (key_edited == lookForInString)
      {
        modchartTweens.get(key).cancel();
        modchartTweens.remove(key);
      }
      // if (StringTools.contains(key, lookForInString))
      // {
      //  modchartTweens.get(key).cancel();
      //  modchartTweens.remove(key);
      // }
    }
  }

  // Use this to set the Mod Value instantly. Also has the logic of cancelling all tweens of that type to avoid overlap if necessary.
  public function setModVal(target:ModHandler, tag:String, val:Float, cancelTweensOfSameMod:Bool = false):Void
  {
    if (cancelTweensOfSameMod)
    {
      cancelTweensOf(tag, target);
    }
    target.setModVal(tag, val);
  }

  // Call this to reset all mod values and cancel any existing tweens for this player!
  public function resetMods_ForTarget(target:ModHandler):Void
  {
    final lookForInString:String = ModConstants.targetTag(target);

    // For now, we just clear ALL tweens lol
    for (key in modchartTweens.keys())
    {
      // trace("checking " + key + " for " + lookForInString);
      if (StringTools.contains(key, lookForInString))
      {
        modchartTweens.get(key).cancel();
        modchartTweens.remove(key);
        // trace("stopping this tween cuz reset - " + key);
      }
    }
    target.resetModValues();
  }

  // Call this to forcefully resort all the modifiers for the target mod handler.
  public function resortMods_ForTarget(target:ModHandler):Void
  {
    target.resortMods();
  }

  //
  // Use these funcs to add events to the timeline!
  //

  /** Adds a 'reset' event to the timeline.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   */
  public function resetModEvent(target:ModHandler, startTime:Float):Void
  {
    final timeEventTest:ModTimeEvent = new ModTimeEvent();
    timeEventTest.startingBeat = startTime;
    timeEventTest.style = "reset";
    if (target == null) target = PlayState.instance.playerStrumline.mods;

    timeEventTest.target = target;
    modEvents.push(timeEventTest);
  }

  /** Adds a 'resort' event to the timeline.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   */
  public function resortModEvent(target:ModHandler, startTime:Float):Void
  {
    final timeEventTest:ModTimeEvent = new ModTimeEvent();
    timeEventTest.startingBeat = startTime;
    timeEventTest.style = "resort";
    if (target == null) target = PlayState.instance.playerStrumline.mods;

    timeEventTest.target = target;
    modEvents.push(timeEventTest);
  }

  /** Adds a 'set' event to the timeline. This event will instantly snap the modName to the input value.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param value The value the modifier will be set to.
   * @param modName The name of the modifier to target.
   */
  public function setModEvent(target:ModHandler, startTime:Float, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, 0, ModConstants.getEaseFromString("linear"), value, modName, "set");
  }

  /** Adds a 'tween' event to the timeline. This event will ease a value from it's current value to the input value using the provided ease.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param length The length of the tween in beats.
   * @param ease The ease function that will be used for the tween.
   * @param value The value the modifier will be set to.
   * @param modName The name of the modifier to target.
   */
  public function tweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "tween");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  /** Adds an 'add' event to the timeline. This event is the same as a tween event EXCEPT the input value is added to the current value.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param length The length of the tween in beats.
   * @param ease The ease function that will be used for the tween.
   * @param value The amount to add to the modifier.
   * @param modName The name of the modifier to target.
   */
  public function addModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "add");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  /** Adds an 'func' event to the timeline. This event will trigger a function at the startTime beat!
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param funky The function that will get called when this event triggers.
   * @param tweenName An optional value that if provided, will cancel any tweens that match this name.
   * @param persist An optional value that if set to false, will mean that this event will be skipped over if the conductor is 1 second past this event.
   */
  public function funcModEvent(target:ModHandler, startTime:Float, funky:Void->Void, ?tweenName:String = null, ?persist:Bool = true):Void
  {
    addModEventToTimeline(target, startTime, 1, ModConstants.getEaseFromString("linear"), 0, tweenName, "func", persist, funky);
  }

  /** Adds an 'value' event to the timeline. Same as a tween but can specify the starting value.
   * Added in v0.7.7a.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param length The duration of this tween in beats.
   * @param ease The ease function to use for this tween.
   * @param startValue The value this tween will start at.
   * @param endValue The value this tween will end at.
   * @param modName The name of the modifier to target.
   */
  public function valueTweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, startValue:Float, endValue:Float,
      modName:String):Void
  {
    // default to target BF for now
    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      PlayState.instance.modDebugNotif("null target for valueTween,\ndefaulting to player.", FlxColor.ORANGE);
    }

    final timeEventTest:ModTimeEvent = new ModTimeEvent();

    if (modName != null) timeEventTest.modName = modName.toLowerCase();
    else
    {
      PlayState.instance.modDebugNotif("No mod name for value tween?", FlxColor.ORANGE);
      timeEventTest.modName = "";
    }
    timeEventTest.target = target;
    timeEventTest.startValue = startValue;
    timeEventTest.gotoValue = endValue;
    timeEventTest.startingBeat = startTime;
    timeEventTest.timeInBeats = length;
    timeEventTest.persist = true;

    if (ease == null)
    {
      ease = FlxEase.linear;
      PlayState.instance.modDebugNotif("no ease defined.\nDefaulting to linear.", FlxColor.ORANGE);
    }
    timeEventTest.easeToUse = ease;
    timeEventTest.style = "value";
    modEvents.push(timeEventTest);
  }

  /** Adds an 'func_tween' event to the timeline.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param length The duration of this tween in beats.
   * @param ease The ease function to use for this tween.
   * @param startValue The value this tween will start at.
   * @param endValue The value this tween will end at.
   * @param funky The function that will get called every frame this tween is active.
   * @param tweenName An optional value that if provided, will be used for this tweens' ID and will also cancel any tweens that match this name.
   * @param persist An optional value that if set to false, will mean that this event will be skipped over if the conductor is 1 second past this event.
   */
  public function funcTweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, startValue:Float, endValue:Float, funky,
      ?tweenName:String = null, ?persist:Bool = true):Void
  {
    // addModEventToTimeline(startTime, 0, FlxEase.linear, 0, tweenName, "func", persist, funky);

    final timeEventTest = new ModTimeEvent();
    if (tweenName != null) timeEventTest.modName = tweenName.toLowerCase();
    else
      timeEventTest.modName = null;

    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      PlayState.instance.modDebugNotif("null target for funcTween,\ndefaulting to player.", FlxColor.ORANGE);
    }
    timeEventTest.target = target;
    timeEventTest.startingBeat = startTime;
    timeEventTest.timeInBeats = length;
    timeEventTest.startValue = startValue;
    timeEventTest.gotoValue = endValue;
    if (ease == null)
    {
      ease = FlxEase.linear;
      PlayState.instance.modDebugNotif("no ease defined.\nDefaulting to linear.", FlxColor.ORANGE);
    }
    timeEventTest.easeToUse = ease;
    timeEventTest.persist = persist;
    timeEventTest.easeToUse = ease;
    timeEventTest.style = "func_tween";
    timeEventTest.funcTween = funky;
    modEvents.push(timeEventTest);
  }

  /** Adds an event to the timeline.
   * @param target The ModHandler that will be affected by this event.
   * @param startTime The beat this event will occur on.
   * @param length The duration of this tween.
   * @param ease The ease function to use for this tween.
   * @param value The target value to tween to.
   * @param modName The modifier name to target.
   * @param type What type of event are we adding?
   * @param persist An optional value that if set to false, will mean that this event will be skipped over if the conductor is past this event.
   * @param funky An optional value which is a function that is triggered.
   */
  public function addModEventToTimeline(?target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String, type:String,
      ?persist:Bool = true, ?funky:Void->Void = null):Void
  {
    final timeEventTest:ModTimeEvent = new ModTimeEvent();
    if (modName != null) timeEventTest.modName = modName.toLowerCase();
    timeEventTest.gotoValue = value;
    timeEventTest.startingBeat = startTime;
    timeEventTest.timeInBeats = length;

    timeEventTest.persist = persist;

    // default to target BF for now
    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      PlayState.instance.modDebugNotif("null target for funcTween,\ndefaulting to player.", FlxColor.ORANGE);
    }

    timeEventTest.target = target;

    if (ease == null)
    {
      ease = FlxEase.linear;
      PlayState.instance.modDebugNotif("no ease defined.\nDefaulting to linear.", FlxColor.ORANGE);
    }
    timeEventTest.easeToUse = ease;

    if (type == null)
    {
      type = "tween";
    }
    timeEventTest.style = type;

    timeEventTest.funcToCall = funky;

    modEvents.push(timeEventTest);
  }
}
