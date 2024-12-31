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
// import flixel.tweens.FlxTweenManager;
import flixel.tweens.FlxEase;
// mod lol
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.ModTimeEvent;
import funkin.play.modchartSystem.ModHandler;
// import funkin.play.modchartSystem.Modifier;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.modding.events.ScriptEvent;
import funkin.play.modchartSystem.HazardEase;
import funkin.play.notes.StrumlineNote;
// for testing
import funkin.audio.FunkinSound;

class ModEventHandler
{
  // public var modResetFuncs:Map<String, Void> = new Map<String, Void>();
  public var modResetFuncs:Array<Void->Void> = [];

  public var modEvents:Array<ModTimeEvent> = [];
  public var tweenManager:FlxTweenManager;

  public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

  // how many custom playfields are there? TODO: Make this split between player and opponent controlled?
  public var customPlayfields:Int = 0;
  public var customPlayfieldsOLD:Bool = false;

  // If set to true, then MOST mods will be divided by 100% when being added into the timeline. This is so you can treat it like NotITG lmao
  public var percentageMods:Bool = false;

  // If set to true, then some mods will be inverted for opponent. Defaults to false.
  public var invertForOpponent:Bool = false;

  public function new()
  {
    // modchartTweens = ["testtween" => null];
    // modchartTweens.remove("testtween");
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
    for (key in modchartTweens.keys())
    {
      modchartTweens.get(key).cancel();
      modchartTweens.remove(key);
    }
    // for (key in modResetFuncs.keys())
    // {
    //   modResetFuncs.remove(key);
    // }
    modResetFuncs = new Array();

    for (modEvent in modEvents)
    {
      modEvent.hasTriggered = false;
    }
    tweenManager.clear();
    bullshitCounter = 0;

    modEvents = new Array();

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;
      strum.mods.resetModValues();
      strum.mods.clearMods();
      strum.mods.addMod('speedmod', 1, 1);
    }
  }

  var songTime:Float = 0;
  var timeBetweenBeats:Float = 0;
  var timeBetweenBeats_ms:Float = 0;
  var beatTime:Float = 0;
  var lastReportedSongTime:Float = 0.0;

  var backInTimeLeniency:Float = 250; // in Miliseconds. Done because V-Slice sometimes often tries to go backwards in time? (???)

  // Note that when paused, it will ignore this!

  public function update(elapsed:Float):Void
  {
    songTime = Conductor.instance.songPosition;
    timeBetweenBeats = Conductor.instance.beatLengthMs / 1000;
    timeBetweenBeats_ms = Conductor.instance.beatLengthMs;
    beatTime = Conductor.instance.currentBeatTime;
    // beatTime = (songTime / 1000) * (Conductor.instance.bpm / 60);

    // we went, BACK IN TIME?!
    if (songTime + ((PlayState.instance?.isGamePaused ?? false) ? 0 : backInTimeLeniency) < lastReportedSongTime)
    {
      resetMods(); // Just reset everything and let the event handler put everything back.
      // trace("BACK IN TIME");
    }

    var timeBetweenLastReport:Float = (songTime - lastReportedSongTime) / 1000; // Because the elapsed from flxg or the playstate doesn't account for lagspikes? okay, sure.
    // trace("customElapsed: " + timeBetweenLastReport);
    tweenManager.update(timeBetweenLastReport); // should be automatically paused when you pause in game

    // tweenManager.update(elapsed); // should be automatically paused when you pause in game
    handleEvents();

    lastReportedSongTime = songTime;
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
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
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
      var timeEventTest = modEvents[i];

      if (timeEventTest.style == "func" || timeEventTest.style == "func_tween" || timeEventTest.style == "reset" || timeEventTest.style == "perframe") continue;

      // check if sub first to avoid adding a subvalue as a mod!
      if (ModConstants.isTagSub(timeEventTest.modName)) continue;

      if (!timeEventTest.target.modifiers.exists(timeEventTest.modName))
      {
        timeEventTest.target.addMod(timeEventTest.modName, 0.0, 0.0);

        var mmm:Float = ModConstants.invertValueCheck(timeEventTest.modName, timeEventTest.target.invertValues);
        timeEventTest.target.modifiers.get(timeEventTest.modName).currentValue *= mmm;
        // timeEventTest.target.modifiers.get(timeEventTest.modName).setVal(timeEventTest.target.modifiers.get(timeEventTest.modName).currentValue * mmm);
      }
    }

    var lol:Int = 1;
    for (strumLine in PlayState.instance.allStrumLines)
    {
      strumLine.mods.sortMods();

      trace("\nSTRUM-" + lol + " mods list: \n" + strumLine.mods.modifiers);
      lol++;
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

  var bullshitCounter:Int = 0;

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
      // _tag = subModArr[1];
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
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    // trace("// !Triggered a tween! \\");
    // trace("Tween tag: " + realTag);
    // trace("Mod to tween: " + _tag);
    // trace("-------------------------");

    bullshitCounter++;

    var mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
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
      var mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod != null)
      {
        var startPoint:Float = (type == "value" ? startingValue : mod.getSubVal(subModArr[1]));
        var finishPoint:Float = startPoint + ((newValue - startPoint) * easeToUse(1.0));
        var tween:FlxTween = tweenManager.num(startPoint, newValue, time,
          {
            ease: easeToUse,
            onComplete: function(twn:FlxTween) {
              modchartTweens.remove(realTag);
              mod.setSubVal(subModArr[1], finishPoint);
            }
          }, function(v) {
            mod.setSubVal(subModArr[1], v);
          });

        modchartTweens.set(realTag, tween);
        return tween;
      }
      else
      {
        return null;
      }
    }

    var mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      var startPoint:Float = (type == "value" ? startingValue : mod.currentValue);
      var finishPoint:Float = startPoint + ((newValue - startPoint) * easeToUse(1.0));
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

  // Tween a mod from one value to another.
  function tweenAddMod(target:ModHandler, modName:String, addValue:Float, time:Float, easeToUse:Null<Float->Float>):FlxTween
  {
    // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);

    var _tag:String = modName.toLowerCase();
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    bullshitCounter++;
    var mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
    addValue *= mmm;

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
      realTag += "+s" + bullshitCounter;
    }
    else
    {
      // so every add tween has it's own unique tag so they don't fight over each other.
      realTag += "+m" + bullshitCounter;
    }

    if (isSub)
    {
      var mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod != null)
      {
        var totalAdded:Float = 0;
        // var initialValue:Float = mod.getSubVal(subModArr[1]);
        var lastReportedChange:Float = 0;
        var tween:FlxTween = tweenManager.num(0, 1, time,
          {
            ease: FlxEase.linear,
            onComplete: function(twn:FlxTween) {
              modchartTweens.remove(realTag);
              // mod.setSubVal(subModArr[1], initialValue + (addValue * easeToUse(1)));
            }
          }, function(t) {
            var v:Float = addValue * easeToUse(t); // ???, cuz for some silly reason tweenValue was being set incorrectly by the tween function / manager? I don't know lmfao
            // mod.currentValue = mod.currentValue + (v - lastReportedChange);
            mod.setSubVal(subModArr[1], mod.getSubVal(subModArr[1]) + (v - lastReportedChange));
            lastReportedChange = v;
            totalAdded = v;
          });

        modchartTweens.set(realTag, tween);
        return tween;
      }
      else
      {
        return null;
      }
    }

    var mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      // var initialValue:Float = mod.currentValue;
      var lastReportedChange:Float = 0;
      var tween:FlxTween = tweenManager.num(0, 1, time,
        {
          ease: FlxEase.linear,
          onComplete: function(twn:FlxTween) {
            modchartTweens.remove(realTag);
          }
        }, function(t) {
          var v:Float = addValue * easeToUse(t); // ???, cuz for some silly reason tweenValue was being set incorrectly by the tween function / manager? I don't know lmfao
          mod.currentValue = mod.currentValue + (v - lastReportedChange);
          lastReportedChange = v;
        });

      modchartTweens.set(realTag, tween);
      return tween;
    }
    else
    {
      return null;
    }
  }

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
    bullshitCounter = 0;

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;
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

  function handleEvents():Void
  {
    for (i in 0...modEvents.length)
    {
      var modEvent:ModTimeEvent = modEvents[i];
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

        // trace("==! LATE !   Event Trigger   ! LATE !==");
        switch (modEvent.style)
        {
          case "add":
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, 0.001, modEvent.easeToUse);
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

            modEvent.target.setModVal(modEvent.modName, modToTween.currentValue + (modEvent.gotoValue * (modEvent?.easeToUse(1)))); // get mod and add to it lol

          case "func_tween":
            if (modEvent.modName != null)
            {
              modchartTweenCancel(modEvent.modName.toLowerCase());
            }
            var finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
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
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue);
            continue;
          case "value":
            // grab current mod value
            var finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
            modEvent.target.setModVal(modEvent.modName, finishPoint);

            continue;
          case "tween":
            // grab current mod value
            var mod:Modifier = figureOutMod(modEvent.target, modEvent.modName);
            if (mod != null)
            {
              var finishPoint:Float = mod.currentValue + ((modEvent.gotoValue - mod.currentValue) * modEvent.easeToUse(1.0));
              modEvent.target.setModVal(modEvent.modName, finishPoint);
            }
            else
            {
              PlayState.instance.modDebugNotif("Tween set error! \n" + modEvent.modName, 0xFFFF7300);

              modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue);
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
        // trace("==   Event Trigger   ==");
        // trace("Type : " + modEvent.style);
        switch (modEvent.style)
        {
          case "reset":
            resetMods_ForTarget(modEvent.target);
            continue;
          case "resort":
            resortMods_ForTarget(modEvent.target);
            continue;
          case "set":
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue);
            continue;
          case "tween":
            // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
            tween = tweenMod(modEvent.target, modEvent.modName, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats, modEvent.easeToUse, "tween");

          case "value":
            tween = tweenMod(modEvent.target, modEvent.modName, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats, modEvent.easeToUse, "value",
              modEvent.startValue);

          case "add":
            // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats, modEvent.easeToUse);
          case "add_old":
            // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);
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

            tween = tweenMod(modEvent.target, modEvent.modName, modToTween.currentValue + modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats,
              modEvent.easeToUse, "add");
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

            var finishPoint:Float = modEvent.startValue + ((modEvent.gotoValue - modEvent.startValue) * modEvent.easeToUse(1.0));
            tween = tweenManager.num(modEvent.startValue, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats,
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

            // trace("funky tween triggered! was tagged? - " + (tweenTagged ? modEvent.modName.toLowerCase() : "nope"));
        }
      }
      if (tween != null)
      {
        var addAmount:Float = ((songTime - ModConstants.getTimeFromBeat(modEvent.startingBeat)) * 0.001);
        // trace("Tween Funny! " + addAmount);
        @:privateAccess
        tween._secondsSinceStart += addAmount;
        @:privateAccess
        tween.update(0);
      }
    }
  }

  // Call this to reset all mod values and cancel any existing tweens for this player!
  public function resetMods_ForTarget(target:ModHandler):Void
  {
    var lookForInString:String = "player.";
    if (target.isDad) lookForInString = "opponent.";

    // For now, we just clear ALL tweens lol
    for (key in modchartTweens.keys())
    {
      // trace("checking " + key + " for " + lookForInString);
      if (StringTools.contains(key, lookForInString))
      {
        modchartTweens.get(key).cancel();
        modchartTweens.remove(key);
        // trace("stopping this tween cuz reset lol - " + key);
      }
    }
    target.resetModValues();
  }

  // Call this to reset all mod values and cancel any existing tweens for this player!
  public function resortMods_ForTarget(target:ModHandler):Void
  {
    target.resortMods();
  }

  // Use these funcs to manage events timeline!
  // Event to reset all mods to default at this beatTime!
  public function resetModEvent(target:ModHandler, startTime:Float):Void
  {
    var timeEventTest:ModTimeEvent = new ModTimeEvent();
    timeEventTest.startingBeat = startTime;
    timeEventTest.style = "reset";
    if (target == null) target = PlayState.instance.playerStrumline.mods;

    timeEventTest.target = target;
    modEvents.push(timeEventTest);
  }

  public function resortModEvent(target:ModHandler, startTime:Float):Void
  {
    var timeEventTest:ModTimeEvent = new ModTimeEvent();
    timeEventTest.startingBeat = startTime;
    timeEventTest.style = "resort";
    if (target == null) target = PlayState.instance.playerStrumline.mods;

    timeEventTest.target = target;
    modEvents.push(timeEventTest);
  }

  // Event to set a mod value at this beatTime!
  public function setModEvent(target:ModHandler, startTime:Float, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, 0, ModConstants.getEaseFromString("linear"), value, modName, "set");
  }

  // Event to trigger a tween between current mod value to value at beatTime
  public function tweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "tween");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  // Same as tween, but adds the value onto the current value instead of replacing it sorta deal
  public function addModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "add");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  // Event to trigger a function at this beatTime!
  public function funcModEvent(target:ModHandler, startTime:Float, funky:Void->Void, ?tweenName:String = null, ?persist:Bool = true):Void
  {
    addModEventToTimeline(target, startTime, 1, ModConstants.getEaseFromString("linear"), 0, tweenName, "func", persist, funky);
  }

  //  V0.7.7a -> New valueTween which acts like a func_tween but for mods!
  public function valueTweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, startValue:Float, endValue:Float,
      modName:String):Void
  {
    // default to target BF for now
    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      PlayState.instance.modDebugNotif("null target for valueTween,\ndefaulting to player.", FlxColor.ORANGE);
    }

    var timeEventTest:ModTimeEvent = new ModTimeEvent();

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

  // Event to trigger a function at this beatTime!
  public function funcTweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, startValue:Float, endValue:Float, funky,
      ?tweenName:String = null, ?persist:Bool = true):Void
  {
    // addModEventToTimeline(startTime, 0, FlxEase.linear, 0, tweenName, "func", persist, funky);

    var timeEventTest = new ModTimeEvent();
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
    // trace("funky tween added!");
  }

  public function addModEventToTimeline(?target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String, type:String,
      ?persist:Bool = true, ?funky:Void->Void = null):Void
  {
    var timeEventTest:ModTimeEvent = new ModTimeEvent();
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
      // trace("null target when trying to add mod, defaulting to player!");
    }

    timeEventTest.target = target;

    if (ease == null)
    {
      ease = FlxEase.linear;
      PlayState.instance.modDebugNotif("no ease defined.\nDefaulting to linear.", FlxColor.ORANGE);
      // trace("no ease, default to null");
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
