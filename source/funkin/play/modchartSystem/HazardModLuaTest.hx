package funkin.play.modchartSystem;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.ModHandler;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxGame;
import flixel.FlxObject;
// import flixel.system.FlxSound;
import flixel.FlxState;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.graphics.ZSprite;
import openfl.display.BlendMode;
import openfl.display.TriangleCulling;
import funkin.data.song.SongData.SongNoteData;

using StringTools;

class HazardModLuaTest
{
  // Any strumlines added to here will be ignored by the any uses of "all" when picking targets. Useful if you know you are never going to use opponentStrumline for example.
  var allTargetExlusions:Array<Strumline> = [];

  public var lua:State = null;
  public var scriptName:String = '';

  public var file:String = '';
  public var folder:String = '';

  public static var hscript:HScript = null;

  public function initHaxeModule()
  {
    if (hscript == null)
    {
      trace('initializing haxe interp for: $scriptName');
      hscript = new HScript(); // TO DO: Fix issue with 2 scripts not being able to use the same variable names
    }
  }

  public function new(script:String, fi:String, fo:String)
  {
    lua = LuaL.newstate();
    LuaL.openlibs(lua);
    Lua.init_callbacks(lua);
    try
    {
      var result:Dynamic = LuaL.dofile(lua, script);
      var resultStr:String = Lua.tostring(lua, result);
      if (resultStr != null && result != 0)
      {
        trace('Error on lua script! ' + resultStr);
        #if windows
        lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
        #else
        luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
        #end
        lua = null;
        return;
      }
    }
    catch (e:Dynamic)
    {
      trace(e);
      return;
    }
    scriptName = script;
    file = fi;
    folder = fo;
    trace('lua file loaded succesfully:' + script);

    set('curBpm', Conductor.instance.bpm);
    set('songPos', Conductor.instance.songPosition);

    set('measureLength', Conductor.instance.measureLengthMs);
    set('beatLength', Conductor.instance.beatLengthMs);
    set('stepLength', Conductor.instance.stepLengthMs);

    set('strumSize', ModConstants.strumSize);

    set('modchartVersion', ModConstants.MODCHART_VERSION);
    set('witfVersion', ModConstants.MODCHART_VERSION);
    set('gameVersion', Constants.VERSION);

    set('difficulty', PlayState.instance.currentChart.difficulty);
    set('songName', PlayState.instance.currentChart.songName);
    set('songVariation', PlayState.instance.currentVariation);

    set('scriptName', scriptName);

    set('screenWidth', FlxG.width);
    set('screenHeight', FlxG.height);
    set('sw', FlxG.width);
    set('sh', FlxG.height);
    set('downscroll', Preferences.downscroll);
    set('downScroll', Preferences.downscroll);
    set('upscroll', !Preferences.downscroll);
    set('upScroll', !Preferences.downscroll);
    set('scrollSpeed', PlayState.instance.currentChart.scrollSpeed);

    set('invertStrumlineTarget', ModConstants.invertStrumlineTarget);

    Lua_helper.add_callback(lua, "targetExclude", function(who:String):Void {
      var strummy:Null<Strumline> = ModConstants.grabStrumModTarget(who).strum;
      if (strummy != null) allTargetExlusions.push(strummy);
    });

    Lua_helper.add_callback(lua, "notesBehindHUD", function(newVal:Bool) {
      if (PlayState.instance != null)
      {
        PlayState.instance.notesAboveHUD = !newVal;
      }
    });

    // v0.8.1a -> New function that allows you to get the beats of notes between two points in a song, similar to using GetNoteData() for NotITG mirin
    // v[1] == the beats that the charted notes are on
    // v[2] == the column that the charted notes are on, starting from 0
    // v[3] == the hold length (0 means no hold) in ms
    // v[4] == the type of note (such as "default", "hurt", "invisible", "dodge",etc)
    Lua_helper.add_callback(lua, "getNoteBeats", ModConstants.getNoteBeats);

    // TODO:
    // FUNCS, FUNC_TWEEN, AND PERFRAME
    // OTHER LUA EVENT STUFF LOL

    Lua_helper.add_callback(lua, "setasleep", function(time:Float, playerTarget:String, newSleepState:Bool = false) {
      if (playerTarget == "bf" || playerTarget == "boyfriend" || playerTarget == "0" || playerTarget == "1")
      {
        PlayState.instance.modDebugNotif("Player strumline cannot be set to sleep!", FlxColor.ORANGE);
        return;
      }

      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          // DO NOT ASLEEP BF!
          if (customStrummer != PlayState.instance.playerStrumline)
          {
            PlayState.instance.modchartEventHandler.funcModEvent(customStrummer.mods, time, function() {
              customStrummer.asleep = newSleepState;
            });
          }
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
        if (modsTarget.strum != PlayState.instance.playerStrumline)
        {
          PlayState.instance.modchartEventHandler.funcModEvent(modsTarget, time, function() {
            modsTarget.strum.asleep = newSleepState;
          });
        }
      }
    });

    Lua_helper.add_callback(lua, "setStrumControl", function(playerTarget:String, isPlayerControlled:Bool, time:Float) {
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          // DO NOT ASLEEP BF!
          if (!(customStrummer == PlayState.instance.playerStrumline || customStrummer == PlayState.instance.opponentStrumline))
          {
            PlayState.instance.modchartEventHandler.funcModEvent(customStrummer.mods, time, function() {
              customStrummer.isPlayerControlled = isPlayerControlled;
            });
          }
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

        if (modsTarget.strum == PlayState.instance.opponentStrumline || modsTarget.strum == PlayState.instance.playerStrumline)
        {
          PlayState.instance.modDebugNotif("Changing player control only works for custom strumlines!", FlxColor.ORANGE);
        }
        else
        {
          PlayState.instance.modchartEventHandler.funcModEvent(modsTarget, time, function() {
            modsTarget.strum.isPlayerControlled = isPlayerControlled;
          });
        }
      }
    });

    // LMAO
    Lua_helper.add_callback(lua, "easeFlip", function(ease1:String):String {
      return 'flip(${ease1})';
    });
    Lua_helper.add_callback(lua, "easeBlend", function(ease1:String, ease2:String):String {
      return 'blend(${ease1},${ease2})';
    });
    Lua_helper.add_callback(lua, "easeMerge", function(ease1:String, ease2:String):String {
      return 'merge(${ease1},${ease2})';
    });
    Lua_helper.add_callback(lua, "easeLerp", function(ease1:String, ease2:String):String {
      return 'lerp(${ease1},${ease2})';
    });

    Lua_helper.add_callback(lua, "flip", function(ease1:String):String {
      return 'flip(${ease1})';
    });
    Lua_helper.add_callback(lua, "blend", function(ease1:String, ease2:String):String {
      return 'blend(${ease1},${ease2})';
    });
    Lua_helper.add_callback(lua, "merge", function(ease1:String, ease2:String):String {
      return 'merge(${ease1},${ease2})';
    });
    Lua_helper.add_callback(lua, "lerp", function(ease1:String, ease2:String):String {
      return 'lerp(${ease1},${ease2})';
    });

    Lua_helper.add_callback(lua, "tween", tweenFunc_parser);
    Lua_helper.add_callback(lua, "ease", tweenFunc_parser);
    Lua_helper.add_callback(lua, "value", valueFunc);
    Lua_helper.add_callback(lua, "setdefault", setDefaultFunc_parser);
    Lua_helper.add_callback(lua, "set", setFunc_parser);
    Lua_helper.add_callback(lua, "add", addFunc_parser);

    Lua_helper.add_callback(lua, "setdefaults", function(data:String) {
      var input:String = StringTools.replace(data, "\n", "");
      input = StringTools.replace(input, " ", "");
      var a:Array<String> = input.split(',');

      var modValues:Array<Float> = [];
      var modNames:Array<String> = [];
      var targets:Array<String> = [];

      var inArray:Bool = false;
      var stage:Int = 0;
      var usingAltFormat:Bool = false;

      for (i in 0...a.length)
      {
        var str:String = a[i];

        if (StringTools.startsWith(str, "[")) inArray = true;
        if (StringTools.endsWith(str, "]")) inArray = false;
        if (!inArray) stage++;
      }
      if (stage - 1 < 2)
      {
        usingAltFormat = true; // player target is never used, meaning modNames is where the targets are as the user wants to use mirin styled mod table thingy
        trace("USING ALT FORMAT");
      }
      stage = 0;
      inArray = false;
      var modAlternator:Bool = false; // ping pongs between true and false during alt format
      // trace(a);
      for (i in 0...a.length)
      {
        var str:String = a[i];

        // trace(str);
        if (StringTools.startsWith(str, "[")) inArray = true;
        str = StringTools.replace(str, "[", "");
        if (StringTools.endsWith(str, "]")) inArray = false;
        str = StringTools.replace(str, "]", "");
        // trace(inArray);
        switch (stage)
        {
          case 0:
            if (usingAltFormat && modAlternator) modNames.push(str);
            else
              modValues.push(Std.parseFloat(str));
            modAlternator = !modAlternator;
          case 1:
            if (usingAltFormat) targets.push(str);
            else
              modNames.push(str);
          case 2:
            if (!usingAltFormat) targets.push(str);
        }
        if (!inArray) stage++;
      }

      multiFunc([], [], [], modValues, modNames, targets, "default");
    });
    Lua_helper.add_callback(lua, "sets", function(data:String) {
      var input:String = StringTools.replace(data, "\n", "");
      input = StringTools.replace(input, " ", "");
      var a:Array<String> = input.split(',');

      var startBeats:Array<Float> = [];
      var modValues:Array<Float> = [];
      var modNames:Array<String> = [];
      var targets:Array<String> = [];

      var inArray:Bool = false;
      var stage:Int = 0;
      var usingAltFormat:Bool = false;

      for (i in 0...a.length)
      {
        var str:String = a[i];

        if (StringTools.startsWith(str, "[")) inArray = true;
        if (StringTools.endsWith(str, "]")) inArray = false;
        if (!inArray) stage++;
      }
      if (stage - 1 < 3)
      {
        usingAltFormat = true; // player target is never used, meaning modNames is where the targets are as the user wants to use mirin styled mod table thingy
        trace("USING ALT FORMAT");
      }
      stage = 0;
      inArray = false;
      var modAlternator:Bool = false; // ping pongs between true and false during alt format
      // trace(a);
      for (i in 0...a.length)
      {
        var str:String = a[i];

        // trace(str);
        if (StringTools.startsWith(str, "[")) inArray = true;
        str = StringTools.replace(str, "[", "");
        if (StringTools.endsWith(str, "]")) inArray = false;
        str = StringTools.replace(str, "]", "");
        // trace(inArray);
        switch (stage)
        {
          case 0:
            startBeats.push(Std.parseFloat(str));
          case 1:
            if (usingAltFormat && modAlternator) modNames.push(str);
            else
              modValues.push(Std.parseFloat(str));
            modAlternator = !modAlternator;
          case 2:
            if (usingAltFormat) targets.push(str);
            else
              modNames.push(str);
          case 3:
            if (!usingAltFormat) targets.push(str);
        }
        if (!inArray) stage++;
      }

      multiFunc(startBeats, [], [], modValues, modNames, targets, "set");
    });
    Lua_helper.add_callback(lua, "adds", function(data:String) {
      multiFuncParse(data, "add");
    });
    Lua_helper.add_callback(lua, "eases", function(data:String) {
      multiFuncParse(data, "tween");
    });
    Lua_helper.add_callback(lua, "tweens", function(data:String) {
      multiFuncParse(data, "tween");
    });
    Lua_helper.add_callback(lua, "values", function(data:String) {
      trace("!!! TEST !!!");

      // remove all \n and spaces
      var input:String = StringTools.replace(data, "\n", "");
      input = StringTools.replace(input, " ", "");
      // "[4,6,8.5,9],[0.75,1,1.5],[sineInOut,bounce,sineInOut],[100,drunk,200,tipsy],[bf,3]"
      // "4, 1, bounce, [100, -100], [x, y], bf"
      var a:Array<String> = input.split(',');

      // [[4], [6], [8.5], [9]] ....
      // [4], [1], [bounce], [[100], [-100]], [[x], [y]], [bf]
      var startBeats:Array<Float> = [];
      var lengthBeats:Array<Float> = [];
      var eases:Array<String> = [];
      var modStartValues:Array<Float> = [];
      var modEndValues:Array<Float> = [];
      var modNames:Array<String> = [];
      var targets:Array<String> = [];

      var inArray:Bool = false;
      var stage:Int = 0;
      var usingAltFormat:Bool = false;

      for (i in 0...a.length)
      {
        var str:String = a[i];

        if (StringTools.startsWith(str, "[")) inArray = true;
        if (StringTools.endsWith(str, "]")) inArray = false;
        if (!inArray) stage++;
      }
      trace("stage: " + stage);
      if (stage - 1 <= 4)
      {
        usingAltFormat = true; // player target is never used, meaning modNames is where the targets are as the user wants to use mirin styled mod table thingy
        trace("USING ALT FORMAT");
      }
      stage = 0;
      inArray = false;
      var modAlternator:Int = 0; // ping pongs between true and false during alt format
      // trace(a);
      for (i in 0...a.length)
      {
        var str:String = a[i];

        // trace(str);
        if (StringTools.startsWith(str, "[")) inArray = true;
        str = StringTools.replace(str, "[", "");
        if (StringTools.endsWith(str, "]")) inArray = false;
        str = StringTools.replace(str, "]", "");
        // trace(inArray);
        switch (stage)
        {
          case 0:
            startBeats.push(Std.parseFloat(str));
          case 1:
            lengthBeats.push(Std.parseFloat(str));
          case 2:
            eases.push(str);
          case 3:
            if (usingAltFormat)
            {
              switch (modAlternator)
              {
                case 0:
                  modStartValues.push(Std.parseFloat(str));
                case 1:
                  modEndValues.push(Std.parseFloat(str));
                case 2:
                  modNames.push(str);
              }
              modAlternator++;
              if (modAlternator > 2) modAlternator = 0;
            }
            else
            {
              modStartValues.push(Std.parseFloat(str));
            }
          case 4:
            if (usingAltFormat)
            {
              targets.push(str);
            }
            else
            {
              modEndValues.push(Std.parseFloat(str));
            }
          case 5:
            if (!usingAltFormat) modNames.push(str);
          case 6:
            if (!usingAltFormat) targets.push(str);
        }
        if (!inArray) stage++;
      }
      trace(" ---------- ");
      trace(startBeats);
      trace(lengthBeats);
      trace(eases);
      trace(modStartValues);
      trace(modEndValues);
      trace(modNames);
      trace(targets);
      trace("!!! FIN !!!");

      if (targets.length < 1)
      { // if empty, default to targetting all
        targets.push("all");
      }

      for (i in 0...startBeats.length)
      {
        var startBeat:Float = startBeats[i];
        var length:Float = 1;

        if (i < lengthBeats.length)
        {
          length = lengthBeats[i];
        }
        else
        {
          length = lengthBeats[lengthBeats.length - 1];
        }
        var e:String = "linear";

        if (i < eases.length)
        {
          e = eases[i];
        }
        else
        {
          e = eases[eases.length - 1];
        }
        for (m in 0...modNames.length)
        {
          var mn:String = modNames[m];
          var msv:Float = 1;
          if (m < modStartValues.length)
          {
            msv = modStartValues[m];
          }
          else
          {
            msv = modStartValues[modStartValues.length - 1];
          }
          var mev:Float = 0;
          if (m < modEndValues.length)
          {
            mev = modEndValues[m];
          }
          else
          {
            mev = modEndValues[modEndValues.length - 1];
          }
          for (k in 0...targets.length)
          {
            var t:String = targets[k];
            valueFunc(startBeat, length, e, msv, mev, mn, t);
          }
        }
      }
    });

    Lua_helper.add_callback(lua, "reset", function(startBeat:Float, playerTarget:String = "all") {
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (strummer in PlayState.instance.allStrumLines)
        {
          if (!allTargetExlusions.contains(strummer)) PlayState.instance.modchartEventHandler.resetModEvent(strummer.mods, startBeat);
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
        PlayState.instance.modchartEventHandler.resetModEvent(modsTarget, startBeat);
      }
    });

    Lua_helper.add_callback(lua, "resort", function(startBeat:Float, playerTarget:String = "all") {
      PlayState.instance.modchartEventHandler.modChartHasResort = true;
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (strummer in PlayState.instance.allStrumLines)
        {
          if (!allTargetExlusions.contains(strummer)) PlayState.instance.modchartEventHandler.resortModEvent(strummer.mods, startBeat);
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
        PlayState.instance.modchartEventHandler.resortModEvent(modsTarget, startBeat);
      }
    });

    Lua_helper.add_callback(lua, "percentageMode", function(newval:Bool = false) {
      trace("set percentage mode to: " + newval);
      PlayState.instance.modchartEventHandler.percentageMods = newval;
      luaTrace("'percentageMode' is not available!", FlxColor.RED);
    });

    Lua_helper.add_callback(lua, "hideNotifs", function(newval:Bool = false) {
      PlayState.instance.hideNotifs = newval;
      trace(PlayState.instance.hideNotifs ? "Will no longer display notifs..." : "Showing notifs!");
    });

    Lua_helper.add_callback(lua, "invertForDad", function(newval:Bool = false) {
      trace("set invert mode to: " + newval);
      PlayState.instance.modchartEventHandler.invertForOpponent = newval;
    });

    Lua_helper.add_callback(lua, "copyZoom", function(newval:Bool = false) {
      PlayState.instance.noteCamCopyHudZoom = newval;
    });

    Lua_helper.add_callback(lua, "centerPlayer", function(pointless:String = "") {
      var playerStrumline:Strumline = PlayState.instance.playerStrumline;
      if (playerStrumline != null)
      {
        playerStrumline.x = (FlxG.width / 2 - playerStrumline.width / 2);
      }
    });
    Lua_helper.add_callback(lua, "hideOpponent", function(pointless:String = "") {
      trace("attempting to hide opponent");
      var strummer = PlayState.instance.opponentStrumline;
      if (strummer != null)
      {
        strummer.asleep = true;
        strummer.x = -999;
        strummer.visible = false;
        for (arrow in strummer.members)
        {
          arrow.visible = false;
        }
      }
    });

    Lua_helper.add_callback(lua, "centerStrum", function(playerTarget:String = "all") {
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (strummer in PlayState.instance.allStrumLines)
        {
          if (!allTargetExlusions.contains(strummer))
          {
            strummer.x = (FlxG.width / 2 - strummer.width / 2);
          }
        }
      }
      else
      {
        var strummer:FlxSprite = ModConstants.grabStrumModTarget(playerTarget).strum;
        if (strummer != null)
        {
          strummer.x = (FlxG.width / 2 - strummer.width / 2);
        }
      }
    });

    Lua_helper.add_callback(lua, "hideStrum", function(playerTarget:String = "opponent") {
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (strummer in PlayState.instance.allStrumLines)
        {
          if (!allTargetExlusions.contains(strummer))
          {
            strummer.asleep = true;
            strummer.x = -999;
            strummer.visible = false;
            for (arrow in strummer.members)
            {
              arrow.visible = false;
            }
          }
        }
      }
      else
      {
        var strummer:Strumline = ModConstants.grabStrumModTarget(playerTarget).strum;
        if (strummer != null)
        {
          strummer.asleep = true;
          strummer.x = -999;
          strummer.visible = false;
          for (arrow in strummer.members)
          {
            arrow.visible = false;
          }
        }
      }
    });

    Lua_helper.add_callback(lua, "centerOpponent", function(pointless:String = "") {
      var strummer:FlxSprite = PlayState.instance.opponentStrumline;
      if (strummer != null)
      {
        strummer.x = (FlxG.width / 2 - strummer.width / 2);
      }
    });

    Lua_helper.add_callback(lua, "hidePlayer", function(pointless:String = "") {
      trace("attempting to hide player");
      var strummer:Strumline = PlayState.instance.playerStrumline;
      if (strummer != null)
      {
        strummer.asleep = true;
        strummer.x = -999;
        strummer.visible = false;
        for (arrow in strummer.members)
        {
          arrow.visible = false;
        }
      }
    });

    // legacy function, just use the grain mod
    Lua_helper.add_callback(lua, "setGrain", function(newGrainValue:Float = 80, playerTarget:String = "all") {
      luaTrace("'setGrain' is deprecated! Use the 'grain' modifier instead!", FlxColor.RED);
      if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
      {
        for (strumLine in PlayState.instance.allStrumLines)
        {
          // strumLine.mods.holdGrain = newGrainValue;
          for (lane in 0...Strumline.KEY_COUNT)
          {
            var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
            whichStrum.strumExtraModData.holdGrain = newGrainValue;
          }
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

        for (lane in 0...Strumline.KEY_COUNT)
        {
          var whichStrum:StrumlineNote = modsTarget.strum.getByIndex(lane);
          whichStrum.strumExtraModData.holdGrain = newGrainValue;
        }
      }
      trace("set grain to: " + newGrainValue);
    });

    // legacy function, use createNewPlayer
    Lua_helper.add_callback(lua, "customStrumAmount", function(newval:Int = 0) {
      luaTrace("'customStrumAmount' is obsolete! Use 'createNewPlayer()' instead!", true, FlxColor.RED);
    });

    Lua_helper.add_callback(lua, "createNewPlayer", function(playerControlled:Bool, ?noteStyle:String) {
      PlayState.instance.constructNewStrumLine(playerControlled, noteStyle);
    });

    Lua_helper.add_callback(lua, "trace", function(text:String, startBeat:Null<Float> = null) {
      if (startBeat != null)
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.modDebugNotif(text);
        }, false);
      }
      else
      {
        PlayState.instance.modDebugNotif(text);
      }
    });

    Lua_helper.add_callback(lua, "aftSetup", function(startBeat:Null<Float> = null) {
      if (PlayState.instance.luaAFT_Capture != null)
      {
        luaTrace("Only one Lua AFT sprite can exist.", FlxColor.ORANGE);
        return;
      }
      if (startBeat == null)
      {
        PlayState.instance.setUpLuaAft();
      }
      else
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.setUpLuaAft();
        });
      }
    });

    Lua_helper.add_callback(lua, "aftCaptureAlpha", function(startBeat:Float, v:Float) {
      luaTrace("aftTweenAlpha NOT SUPPORTED IN V0.8.0a", FlxColor.RED);
      /*
        if (PlayState.instance.luaAFT_Capture == null)
        {
          luaTrace("Lua AFT sprite not created!", FlxColor.RED);
          return;
        }
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.luaAFT_Capture.alpha = v;
          trace("oh hey, we alpha cap", v);
        });
       */
    });

    Lua_helper.add_callback(lua, "aftSpriteAlpha", function(startBeat:Float, v:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_sprite.alpha = v;
        trace("oh hey, we alpha spr", v);
      });
    });

    Lua_helper.add_callback(lua, "aftAlpha", function(startBeat:Float, v:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        // PlayState.instance.luaAFT_Capture.alpha = v;
        PlayState.instance.luaAFT_sprite.alpha = v;
        trace("oh hey, we alpha it", v);
      });
    });

    Lua_helper.add_callback(lua, "aftRecursive", function(startBeat:Float, v:Bool) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_Capture.recursive = v;
      });
    });
    Lua_helper.add_callback(lua, "aftUpdateRate", function(startBeat:Float, v:Float, trueValue:Bool = false) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      if (trueValue)
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.luaAFT_Capture.updateRate = v;
        });
      }
      else
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.luaAFT_Capture.targetFps(v);
        });
      }
    });
    Lua_helper.add_callback(lua, "aftBlend", function(startBeat:Float, b:String) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_Capture.blendMode = b;
      });
    });
    Lua_helper.add_callback(lua, "aftSize", function(startBeat:Float, s:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_sprite.setGraphicSize(Std.int(PlayState.instance.luaAFT_Capture.w * s));
        trace("oh hey, we resized it");
      });
    });

    Lua_helper.add_callback(lua, "aftTweenAlpha", function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float) {
      luaTrace("aftTweenAlpha NOT SUPPORTED IN V0.8.0a", FlxColor.RED);
      /*
        if (PlayState.instance.luaAFT_Capture == null)
        {
          luaTrace("Lua AFT sprite not created!", FlxColor.RED);
          return;
        }
        PlayState.instance.modchartEventHandler.funcTweenModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, lengthInBeats,
          ModConstants.getEaseFromString(easeToUse), PlayState.instance.luaAFT_Capture.alpha, modValue, function(v) {
            // PlayState.instance.luaAFT_Capture.alpha = v;
            PlayState.instance.luaAFT_sprite.alpha = v;
            return v;
        }, "luaAFT_alpha");
       */
    });

    Lua_helper.add_callback(lua, "aftTweenSize", function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        // PlayState.instance.modDebugNotif("No lua aft sprite!");
        // trace("No lua aft!");
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcTweenModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, lengthInBeats,
        ModConstants.getEaseFromString(easeToUse), 1, modValue, function(v) {
          PlayState.instance.luaAFT_sprite.setGraphicSize(Std.int(PlayState.instance.luaAFT_Capture.w * v));
          return v;
      }, "luaAFT_scale");
    });

    // Stolen from Funkin Lua
    Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
      #if hscript
      initHaxeModule();
      try
      {
        var str:String = '';
        if (libPackage.length > 0) str = libPackage + '.';

        hscript.variables.set(libName, Type.resolveClass(str + libName));
      }
      catch (e:Dynamic)
      {
        luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
      }
      #else
      luaTrace("HScript isn't supported on this platform!", false, false, FlxColor.RED);
      #end
    });

    Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String) {
      var retVal:Dynamic = null;

      #if hscript
      initHaxeModule();
      try
      {
        retVal = hscript.execute(codeToRun);
      }
      catch (e:Dynamic)
      {
        luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
      }
      #else
      luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
      #end

      if (retVal != null && !isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
      if (retVal == null) Lua.pushnil(lua);
      return retVal;
    });

    Lua_helper.add_callback(lua, "createSprite", function(tag:String, imagePath:String) {
      var newSpr:FlxSprite = new FlxSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      PlayState.instance.customLuaSprites.set(tag, newSpr);
      PlayState.instance.add(newSpr);
    });

    call('onCreate', []);
  }

  public static function isOfTypes(value:Any, types:Array<Dynamic>)
  {
    for (type in types)
    {
      if (Std.isOfType(value, type)) return true;
    }
    return false;
  }

  public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE):Void
  {
    // if (ignoreCheck || getBool('luaDebugMode'))
    // {
    //  if (deprecated && !getBool('luaDeprecatedWarnings'))
    //  {
    //    return;
    //  }
    // PlayState.instance.addTextToDebug(text, color);
    PlayState.instance.modDebugNotif(text, color, ignoreCheck);
    trace(text);
    // }
  }

  function multiFuncParse(data:String, type:String):Void
  {
    // format: adds("[4, 6, 8.5, 9], [0.75, 1, 1.5], [sineInOut, bounce, sineInOut], [100, drunk, 200, tipsy], [bf, 3] ")
    // startBeat = [4, 6, 8.5, 9]. Loops through each one and adds it as an event
    // lengthInBeats = [0.75,1,1.5]. 4 will be 0.75, 6 will be 1. If startBeat iteration is larger then this array, default to last member (so 9 is 1.5)
    // easeToUse = ["sineInOut", "bounce"]. Same as above.
    // modValue = [100, "drunk", 100, "tipsy"] same as Mirin. Alternatively, it can have the same logic as above (as such, playerTarget will then still be used)
    // modName will become player target
    // playerTarget becomes unused.

    trace("!!! TEST !!!");

    // remove all \n and spaces
    var input:String = StringTools.replace(data, "\n", "");
    input = StringTools.replace(input, " ", "");
    // "[4,6,8.5,9],[0.75,1,1.5],[sineInOut,bounce,sineInOut],[100,drunk,200,tipsy],[bf,3]"
    // "4, 1, bounce, [100, -100], [x, y], bf"
    var a:Array<String> = input.split(',');

    // [[4], [6], [8.5], [9]] ....
    // [4], [1], [bounce], [[100], [-100]], [[x], [y]], [bf]
    var startBeats:Array<Float> = [];
    var lengthBeats:Array<Float> = [];
    var eases:Array<String> = [];
    var modValues:Array<Float> = [];
    var modNames:Array<String> = [];
    var targets:Array<String> = [];

    var inArray:Bool = false;
    var stage:Int = 0;
    var usingAltFormat:Bool = false;

    for (i in 0...a.length)
    {
      var str:String = a[i];

      if (StringTools.startsWith(str, "[")) inArray = true;
      if (StringTools.endsWith(str, "]")) inArray = false;
      if (!inArray) stage++;
    }
    trace("stage: " + stage);
    if (stage - 1 < 5)
    {
      usingAltFormat = true; // player target is never used, meaning modNames is where the targets are as the user wants to use mirin styled mod table thingy
      trace("USING ALT FORMAT");
    }
    stage = 0;
    inArray = false;
    var modAlternator:Bool = false; // ping pongs between true and false during alt format
    // trace(a);
    for (i in 0...a.length)
    {
      var str:String = a[i];

      // trace(str);
      if (StringTools.startsWith(str, "[")) inArray = true;
      str = StringTools.replace(str, "[", "");
      if (StringTools.endsWith(str, "]")) inArray = false;
      str = StringTools.replace(str, "]", "");
      // trace(inArray);
      switch (stage)
      {
        case 0:
          startBeats.push(Std.parseFloat(str));
        case 1:
          lengthBeats.push(Std.parseFloat(str));
        case 2:
          eases.push(str);
        case 3:
          if (usingAltFormat && modAlternator) modNames.push(str);
          else
            modValues.push(Std.parseFloat(str));
          modAlternator = !modAlternator;
        case 4:
          if (usingAltFormat) targets.push(str);
          else
            modNames.push(str);
        case 5:
          if (!usingAltFormat) targets.push(str);
      }
      if (!inArray) stage++;
    }

    trace(" ---------- ");
    trace(startBeats);
    trace(lengthBeats);
    trace(eases);
    trace(modValues);
    trace(modNames);
    trace(targets);
    trace("!!! FIN !!!");

    multiFunc(startBeats, lengthBeats, eases, modValues, modNames, targets, type);
  }

  function multiFunc(startBeats:Array<Float>, lengthBeats:Array<Float>, eases:Array<String>, modValues:Array<Float>, modNames:Array<String>,
      targets:Array<String>, type:String):Void
  {
    if (targets.length < 1)
    { // if empty, default to targetting all
      targets.push("all");
    }
    switch (type)
    {
      case "default":
        for (m in 0...modNames.length)
        {
          var mn:String = modNames[m];
          var mv:Float = 1;
          if (m < modValues.length)
          {
            mv = modValues[m];
          }
          else
          {
            mv = modValues[modValues.length - 1];
          }
          for (k in 0...targets.length)
          {
            var t:String = targets[k];
            setDefaultFunc(mv, mn, t);
          }
        }
      case "set":
        for (i in 0...startBeats.length)
        {
          var startBeat:Float = startBeats[i];
          for (m in 0...modNames.length)
          {
            var mn:String = modNames[m];
            var mv:Float = 1;
            if (m < modValues.length)
            {
              mv = modValues[m];
            }
            else
            {
              mv = modValues[modValues.length - 1];
            }
            for (k in 0...targets.length)
            {
              var t:String = targets[k];
              setFunc(startBeat, mv, mn, t);
            }
          }
        }
      case "add" | "tween":
        for (i in 0...startBeats.length)
        {
          var startBeat:Float = startBeats[i];
          var length:Float = 1;

          if (i < lengthBeats.length)
          {
            length = lengthBeats[i];
          }
          else
          {
            length = lengthBeats[lengthBeats.length - 1];
          }
          var e:String = "linear";

          if (i < eases.length)
          {
            e = eases[i];
          }
          else
          {
            e = eases[eases.length - 1];
          }
          for (m in 0...modNames.length)
          {
            var mn:String = modNames[m];
            var mv:Float = 1;
            if (m < modValues.length)
            {
              mv = modValues[m];
            }
            else
            {
              mv = modValues[modValues.length - 1];
            }
            for (k in 0...targets.length)
            {
              var t:String = targets[k];

              if (type == "add")
              {
                addFunc(startBeat, length, e, mv, mn, t);
              }
              else
              {
                tweenFunc(startBeat, length, e, mv, mn, t);
              }
            }
          }
        }
    }
  }

  function valueFunc(startBeat:Float, lengthInBeats:Float, easeToUse:String, startingValue:Float, endingValue:Float, modName:String,
      playerTarget:String = "all"):Void
  {
    // trace("WOW! WE NEED TWEEN: " + modName);
    modName = ModConstants.modAliasCheck(modName);

    // trace("ease name : " + easeToUse);
    // trace("ease to use : " + ModConstants.getEaseFromString(easeToUse));
    if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
    {
      for (strummer in PlayState.instance.allStrumLines)
      {
        if (!allTargetExlusions.contains(strummer)) PlayState.instance.modchartEventHandler.valueTweenModEvent(strummer.mods, startBeat, lengthInBeats,
          ModConstants.getEaseFromString(easeToUse), startingValue, endingValue, modName);
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

      PlayState.instance.modchartEventHandler.valueTweenModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse),
        startingValue, endingValue, modName);
    }
  }

  function formaterTargets(targetsRaw:Any):Array<String>
  {
    var targets:Array<String> = [];
    if (Std.isOfType(targetsRaw, Array))
    {
      var targetsArray:Array<String> = cast targetsRaw;
      for (i in targetsArray)
      {
        targets.push(i);
      }
    }
    else
    {
      targets = [(targetsRaw ?? "all")];
    }
    return targets;
  }

  function setDefaultFunc_parser(modValue:Any, modName:Any, _playerTarget:Any = "all"):Void
  {
    var targets_raw:Any = _playerTarget;

    var modArray:Bool = false;
    if (Std.isOfType(modValue, Array))
    {
      // modName becomes playerTarget and _playerTarget is unused.
      modArray = true;
      targets_raw = modName;
    }

    var targets:Array<String> = formaterTargets(targets_raw);

    var modValues:Array<Float> = [];
    var modNames:Array<String> = [];
    if (!modArray)
    {
      modValues = [modValue];
      modNames = [modName];
    }
    else
    {
      var isName:Bool = false;
      var modsInputArray:Array<String> = cast modValue;
      for (i in modsInputArray)
      {
        if (isName) modNames.push(i);
        else
          modValues.push(Std.parseFloat(i));
        isName = !isName;
      }
    }

    for (t in targets)
    {
      for (i in 0...modNames.length)
      {
        setDefaultFunc(modValues[i], modNames[i], t);
      }
    }
  }

  function setFunc_parser(startBeat:Float, modValue:Any, modName:Any, _playerTarget:Any = "all"):Void
  {
    var targets_raw:Any = _playerTarget;

    var modArray:Bool = false;
    if (Std.isOfType(modValue, Array))
    {
      // modName becomes playerTarget and _playerTarget is unused.
      modArray = true;
      targets_raw = modName;
    }

    var targets:Array<String> = formaterTargets(targets_raw);

    var modValues:Array<Float> = [];
    var modNames:Array<String> = [];
    if (!modArray)
    {
      modValues = [modValue];
      modNames = [modName];
    }
    else
    {
      var isName:Bool = false;
      var modsInputArray:Array<String> = cast modValue;
      for (i in modsInputArray)
      {
        if (isName) modNames.push(i);
        else
          modValues.push(Std.parseFloat(i));
        isName = !isName;
      }
    }

    for (t in targets)
    {
      for (i in 0...modNames.length)
      {
        setFunc(startBeat, modValues[i], modNames[i], t);
      }
    }
  }

  function addFunc_parser(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Any, modName:Any, _playerTarget:Any = "all"):Void
  {
    var targets_raw:Any = _playerTarget;

    var modArray:Bool = false;
    if (Std.isOfType(modValue, Array))
    {
      // modName becomes playerTarget and _playerTarget is unused.
      modArray = true;
      targets_raw = modName;
    }

    var targets:Array<String> = formaterTargets(targets_raw);

    var modValues:Array<Float> = [];
    var modNames:Array<String> = [];
    if (!modArray)
    {
      modValues = [modValue];
      modNames = [modName];
    }
    else
    {
      var isName:Bool = false;
      var modsInputArray:Array<String> = cast modValue;
      for (i in modsInputArray)
      {
        if (isName) modNames.push(i);
        else
          modValues.push(Std.parseFloat(i));
        isName = !isName;
      }
    }

    for (t in targets)
    {
      for (i in 0...modNames.length)
      {
        addFunc(startBeat, lengthInBeats, easeToUse, modValues[i], modNames[i], t);
      }
    }
  }

  // could be
  // tween(0, 4, "linear", 1, "beat", "3")
  // tween(0, 4, "linear", {1, "beat", 1, "drunk"}, {3,1})
  // Work In Progress replacement to allow users to input multiple mod values into the same function without needing to convert it all to a string like for tweens func
  function tweenFunc_parser(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Any, modName:Any, _playerTarget:Any = "all"):Void
  {
    var targets_raw:Any = _playerTarget;
    var modArray:Bool = false;
    if (Std.isOfType(modValue, Array))
    {
      // modName becomes playerTarget and _playerTarget is unused.
      modArray = true;
      targets_raw = modName;
    }

    var targets:Array<String> = formaterTargets(targets_raw);

    var modValues:Array<Float> = [];
    var modNames:Array<String> = [];
    if (!modArray)
    {
      modValues = [modValue];
      modNames = [modName];
    }
    else
    {
      var isName:Bool = false;
      var modsInputArray:Array<String> = cast modValue;
      for (i in modsInputArray)
      {
        if (isName) modNames.push(i);
        else
          modValues.push(Std.parseFloat(i));
        isName = !isName;
      }
    }

    for (t in targets)
    {
      for (i in 0...modNames.length)
      {
        tweenFunc(startBeat, lengthInBeats, easeToUse, modValues[i], modNames[i], t);
      }
    }
  }

  function tweenFunc(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float, modName:String, playerTarget:String = "all"):Void
  {
    // trace("WOW! WE NEED TWEEN: " + modName);
    modName = ModConstants.modAliasCheck(modName);

    // trace("ease name : " + easeToUse);
    // trace("ease to use : " + ModConstants.getEaseFromString(easeToUse));
    if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
    {
      for (strummer in PlayState.instance.allStrumLines)
      {
        if (!allTargetExlusions.contains(strummer))
        {
          PlayState.instance.modchartEventHandler.tweenModEvent(strummer.mods, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue,
            modName);
        }
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

      PlayState.instance.modchartEventHandler.tweenModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue, modName);
    }
  }

  function setDefaultFunc(modValue:Float, modName:String, playerTarget:String = "all"):Void
  {
    modName = ModConstants.modAliasCheck(modName);

    if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
    {
      for (strummer in PlayState.instance.allStrumLines)
      {
        if (!allTargetExlusions.contains(strummer)) strummer.mods.setDefaultModVal(modName, modValue);
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

      modsTarget.setDefaultModVal(modName, modValue);
    }
  }

  function setFunc(startBeat:Float, modValue:Float, modName:String, playerTarget:String = "all"):Void
  {
    // trace("WOW! WE NEED SET: " + modName);
    modName = ModConstants.modAliasCheck(modName);

    if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
    {
      for (strummer in PlayState.instance.allStrumLines)
      {
        if (!allTargetExlusions.contains(strummer)) PlayState.instance.modchartEventHandler.setModEvent(strummer.mods, startBeat, modValue, modName);
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

      PlayState.instance.modchartEventHandler.setModEvent(modsTarget, startBeat, modValue, modName);
    }
  }

  function addFunc(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float, modName:String, playerTarget:String = "all"):Void
  {
    // trace("WOW! WE NEED ADD: " + modName);
    modName = ModConstants.modAliasCheck(modName);
    if (playerTarget == "everyone" || playerTarget == "both" || playerTarget == "all")
    {
      for (strummer in PlayState.instance.allStrumLines)
      {
        if (!allTargetExlusions.contains(strummer)) PlayState.instance.modchartEventHandler.addModEvent(strummer.mods, startBeat, lengthInBeats,
          ModConstants.getEaseFromString(easeToUse), modValue, modName);
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

      PlayState.instance.modchartEventHandler.addModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue, modName);
    }
  }

  function getErrorMessage(status:Int):String
  {
    #if LUA_ALLOWED
    var v:String = Lua.tostring(lua, -1);
    Lua.pop(lua, 1);

    if (v != null) v = v.trim();
    if (v == null || v == "")
    {
      switch (status)
      {
        case Lua.LUA_ERRRUN:
          return "Runtime Error";
        case Lua.LUA_ERRMEM:
          return "Memory Allocation Error";
        case Lua.LUA_ERRERR:
          return "Critical Error";
      }
      return "Unknown Error";
    }

    return v;
    #end
    return null;
  }

  function typeToString(type:Int):String
  {
    #if LUA_ALLOWED
    switch (type)
    {
      case Lua.LUA_TBOOLEAN:
        return "boolean";
      case Lua.LUA_TNUMBER:
        return "number";
      case Lua.LUA_TSTRING:
        return "string";
      case Lua.LUA_TTABLE:
        return "table";
      case Lua.LUA_TFUNCTION:
        return "function";
    }
    if (type <= Lua.LUA_TNIL) return "nil";
    #end
    return "unknown";
  }

  var lastCalledFunction:String = '';

  public function call(func:String, args:Array<Dynamic>):Dynamic
  {
    // if (closed) return Function_Continue;

    lastCalledFunction = func;
    try
    {
      if (lua == null) return Function_Continue;

      Lua.getglobal(lua, func);
      var type:Int = Lua.type(lua, -1);

      if (type != Lua.LUA_TFUNCTION)
      {
        if (type > Lua.LUA_TNIL) luaTrace("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value", false, false, FlxColor.RED);

        Lua.pop(lua, 1);
        return Function_Continue;
      }

      for (arg in args)
        Convert.toLua(lua, arg);
      var status:Int = Lua.pcall(lua, args.length, 1, 0);

      // Checks if it's not successful, then show a error.
      if (status != Lua.LUA_OK)
      {
        var error:String = getErrorMessage(status);
        luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
        return Function_Continue;
      }

      // If successful, pass and then return the result.
      var result:Dynamic = cast Convert.fromLua(lua, -1);
      if (result == null) result = Function_Continue;

      Lua.pop(lua, 1);
      return result;
    }
    catch (e:Dynamic)
    {
      trace(e);
    }
    return Function_Continue;
  }

  public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
  public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
  public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";

  function set(variable:String, data:Dynamic):Void
  {
    if (lua == null)
    {
      return;
    }

    Convert.toLua(lua, data);
    Lua.setglobal(lua, variable);
  }

  public function stop():Void
  {
    if (lua == null)
    {
      return;
    }

    Lua.close(lua);
    lua = null;
  }
}

class HScript
{
  public static var parser:Parser = new Parser();

  public var interp:Interp;

  public var variables(get, never):Map<String, Dynamic>;

  function get_variables()
  {
    return interp.variables;
  }

  public function new()
  {
    interp = new Interp();
    interp.variables.set('FlxG', FlxG);
    interp.variables.set('FlxSprite', FlxSprite);
    interp.variables.set('ZSprite', ZSprite);
    interp.variables.set('FlxCamera', FlxCamera);
    interp.variables.set('FlxTimer', FlxTimer);
    interp.variables.set('FlxTween', FlxTween);
    interp.variables.set('FlxEase', FlxEase);
    interp.variables.set('PlayState', PlayState);
    interp.variables.set('game', PlayState.instance);
    interp.variables.set('Paths', Paths);
    interp.variables.set('Conductor', Conductor);
    interp.variables.set('StringTools', StringTools);
    interp.variables.set('Std', Std);
    interp.variables.set('eh', PlayState.instance.modchartEventHandler);

    interp.variables.set('FlxMath', FlxMath);
    interp.variables.set('Math', Math);

    interp.variables.set("ModConstants", Type.resolveClass("funkin.play.modchartSystem.ModConstants"));
    interp.variables.set("BaseModifier", Type.resolveClass("funkin.play.modchartSystem.modifiers.BaseModifier"));
    interp.variables.set("CustomModifier", Type.resolveClass("funkin.play.modchartSystem.modifiers.CustomModifier"));
    interp.variables.set("NoteData", Type.resolveClass("funkin.play.modchartSystem.NoteData"));
    interp.variables.set('ModHandler', ModHandler);
    interp.variables.set('ModEventHandler', ModEventHandler);

    interp.variables.set('Preferences', Preferences);
    interp.variables.set('downScroll', Preferences.downscroll);
    interp.variables.set('upScroll', !Preferences.downscroll);

    interp.variables.set("FlxTypedSpriteGroup", Type.resolveClass("flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup"));

    interp.variables.set("BlendMode", Type.resolveClass("openfl.display.BlendMode"));

    interp.variables.set('setBlendMode', function(name:String, blendy:String = "") {
      if (PlayState.instance.customLuaSprites.exists(name))
      {
        PlayState.instance.customLuaSprites.get(name).blend = ModConstants.blendModeFromString(blendy);
      }
    });

    interp.variables.set('getBlendMode', function(b:String):BlendMode {
      return ModConstants.blendModeFromString(b);
    });

    interp.variables.set('textBorderStyle', function(b:String) {
      switch (b.toLowerCase())
      {
        case "shadow":
          return FlxTextBorderStyle.SHADOW;
        case "none":
          return FlxTextBorderStyle.NONE;
        case "outline_fast":
          return FlxTextBorderStyle.OUTLINE_FAST;
        case "outline":
          return FlxTextBorderStyle.OUTLINE;

        default:
          return FlxTextBorderStyle.NONE;
      }
    });

    interp.variables.set('culling', function(b:String) {
      switch (b.toLowerCase())
      {
        case "positive":
          return TriangleCulling.POSITIVE;
        case "none":
          return TriangleCulling.NONE;
        case "negative":
          return TriangleCulling.NEGATIVE;
        default:
          return TriangleCulling.NONE;
      }
    });

    interp.variables.set('createCustomEase', function(nameOfEase:String, func:Float->Float):Void {
      if (PlayState.instance.modchartEventHandler != null)
      {
        PlayState.instance.modchartEventHandler.customEases.set(nameOfEase, func);
      }
    });

    interp.variables.set('createSprGroup', function(variableTag:String, addToGame:Bool = true) {
      var grp:FlxTypedSpriteGroup<FlxSprite> = null;

      if (PlayState.instance.variables.exists(variableTag))
      {
        grp = PlayState.instance.variables.get(variableTag);
      }
      else
      {
        var grp:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>(0, 0);
        grp.scrollFactor.set();
        // grp.scrollFactor.set();
        if (addToGame)
        {
          PlayState.instance.variables.set(variableTag, grp);
          PlayState.instance.add(grp);
        }
      }
      return grp;
    });
    interp.variables.set('addToSprGrp', function(variableTag_Grp:String, toAdd:FlxSprite) {
      var grp:FlxTypedSpriteGroup<FlxSprite> = null;
      if (PlayState.instance.variables.exists(variableTag_Grp)) grp = PlayState.instance.variables.get(variableTag_Grp);
      if (grp != null)
      {
        grp.add(toAdd);
      }
      return grp;
    });

    // interp.variables.set('FlxColor', FlxColor);
    // interp.variables.set('HazardAFT', HazardAFT);

    interp.variables.set('getSpr', function(name:String) {
      var result:FlxSprite = null;
      if (PlayState.instance.customLuaSprites.exists(name)) result = PlayState.instance.customLuaSprites.get(name);
      return result;
    });

    interp.variables.set('createSpr', function(tag:String, imagePath:String, addToGame:Bool = true) {
      var newSpr:FlxSprite = new FlxSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      if (addToGame)
      {
        PlayState.instance.customLuaSprites.set(tag, newSpr);
        PlayState.instance.add(newSpr);
      }
      return newSpr;
    });

    interp.variables.set('createZSpr', function(tag:String, imagePath:String, addToGame:Bool = true) {
      var newSpr:ZSprite = new ZSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      if (addToGame)
      {
        PlayState.instance.customLuaSprites.set(tag, newSpr);
        PlayState.instance.add(newSpr);
      }
      return newSpr;
    });

    interp.variables.set('createCloneMod', function(modName:String) {
      if (PlayState.instance.modchartEventHandler == null)
      {
        HazardModLuaTest.luaTrace("Custom Mod could not be created as this song isn't a modchart song!", false, false, FlxColor.RED);
        return null;
      }

      return ModConstants.createNewMod(modName);
    });

    interp.variables.set('createCustomMod', function(modName:String, defaultBaseValue:Float = 0) {
      if (PlayState.instance.modchartEventHandler == null)
      {
        HazardModLuaTest.luaTrace("Custom Mod could not be created as this song isn't a modchart song!", false, false, FlxColor.RED);
        return null;
      }
      var newMod:CustomModifier = ModConstants.createNewCustomMod(modName, defaultBaseValue);
      return newMod;
    });

    // createSubMod("steps", 4.0);

    interp.variables.set('setResetEvent', function(func:Void->Void) {
      if (PlayState.instance.modchartEventHandler != null)
      {
        PlayState.instance.modchartEventHandler.modResetFuncs.push(func);
      }
    });
    interp.variables.set('addResetEvent', function(func:Void->Void) {
      if (PlayState.instance.modchartEventHandler != null)
      {
        PlayState.instance.modchartEventHandler.modResetFuncs.push(func);
      }
    });

    interp.variables.set('addUpdate', function(func:Float->Void) {
      if (PlayState.instance.perframeFunctions != null)
      {
        PlayState.instance.perframeFunctions.push(func);
      }
    });
    interp.variables.set('print', function(text:String, color:FlxColor = FlxColor.WHITE) {
      PlayState.instance.modDebugNotif(text, color);
    });

    interp.variables.set('stringSplit', function(inputString:String, splitThing:String) {
      var split:Array<String> = inputString.split(splitThing);
      return split;
    });

    interp.variables.set('existsFromMap', function(theMap:Dynamic, thingToGet:Dynamic) {
      return theMap.exists(thingToGet);
    });
    interp.variables.set('getFromMap', function(theMap:Dynamic, thingToGet:Dynamic) {
      return theMap.get(thingToGet);
    });

    interp.variables.set('setVar', function(name:String, value:Dynamic) {
      PlayState.instance.variables.set(name, value);
    });
    interp.variables.set('getVar', function(name:String) {
      var result:Dynamic = null;
      if (PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
      return result;
    });
    interp.variables.set('removeVar', function(name:String) {
      if (PlayState.instance.variables.exists(name))
      {
        PlayState.instance.variables.remove(name);
        return true;
      }
      return false;
    });
  }

  public function execute(codeToRun:String):Dynamic
  {
    @:privateAccess
    HScript.parser.line = 1;
    HScript.parser.allowTypes = true;
    return interp.execute(HScript.parser.parseString(codeToRun));
  }
}
