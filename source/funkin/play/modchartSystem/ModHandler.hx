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
import funkin.play.notes.NoteSprite;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.ModConstants;
// Math and utils
import StringTools;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import funkin.util.SortUtil;
import flixel.util.FlxSort;
// extra
import funkin.graphics.FunkinSprite;
import flixel.FlxSprite;
import flixel.FlxStrip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import openfl.display.Sprite;
import flixel.text.FlxText;
import funkin.audio.FunkinSound; // used for debugging stuff lol
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.graphics.ZSprite;
import flixel.util.FlxColor;

class ModHandler
{
  public var debugTxtOffsetX:Float = 0;
  public var debugTxtOffsetY:Float = 0;
  public var invertValues:Bool = false;
  public var isDad:Bool = false;

  public var modifiers:Map<String, Modifier>;

  // public var mods_SORTED:Array<Modifier> = [];
  public var mods_all:Array<Modifier> = [];
  public var mods_arrowpath:Array<Modifier> = [];
  public var mods_strums:Array<Modifier> = [];
  public var mods_notes:Array<Modifier> = [];
  public var mods_speed:Array<Modifier> = [];
  public var mods_special:Array<Modifier> = [];

  // The prefix added to every tween name associated with this ModHandler.
  public var customTweenerName:String = "???";

  // The strumline this modHandler is tied to
  public var strum:Strumline;

  public function new(daddy:Bool = false)
  {
    // this is so fucking stupid lmao
    modifiers = ["dumb_setup" => null];
    modifiers.remove("dumb_setup");

    if (daddy)
    {
      isDad = daddy;
    }

    addMod('speedmod', 1, 1);
  }

  public function resortMods():Void
  {
    sortMods(true);
    strum.debugNeedsUpdate = true;
  }

  public function resetModValues():Void
  {
    // trace("Reset mod values lol");

    for (mod in mods_all)
      mod.reset();

    debugTxtOffsetX = 0;
    debugTxtOffsetY = 0;

    for (i in 0...Strumline.KEY_COUNT)
    {
      strum.strumlineNotes.members[i].strumExtraModData.reset();
    }

    strum.debugNeedsUpdate = true;
  }

  public function clearMods():Void
  {
    resetModValues();
    for (key in modifiers.keys())
    {
      modifiers.remove(key);
    }

    // https://stackoverflow.com/questions/45324169/what-is-the-correct-way-to-clear-an-array-in-haxe
    while (mods_all.length > 0)
      mods_all.pop();

    while (mods_strums.length > 0)
      mods_strums.pop();

    while (mods_notes.length > 0)
      mods_notes.pop();

    while (mods_speed.length > 0)
      mods_speed.pop();

    while (mods_arrowpath.length > 0)
      mods_arrowpath.pop();

    while (mods_special.length > 0)
      mods_special.pop();
  }

  // Set a mod value instantly.
  public function setModVal(tag:String, val:Float):Void
  {
    var tagToUse:String = tag;
    var mmm = ModConstants.invertValueCheck(tagToUse, invertValues);
    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(tag))
    {
      isSub = true;
      subModArr = tag.split('__');
      tagToUse = subModArr[1];
    }

    if (isSub)
    {
      if (modifiers.exists(subModArr[0]))
      {
        modifiers.get(subModArr[0]).setSubVal(subModArr[1], val * mmm);
        strum.debugNeedsUpdate = true;
      }
      return;
    }

    if (modifiers.exists(tagToUse))
    {
      modifiers.get(tagToUse).setVal(val * mmm);
    }
    else
    {
      PlayState.instance.modDebugNotif(tagToUse + " mod doesn't exist!\nTrying to add it now!", FlxColor.ORANGE);
      addMod(tagToUse, val, 0.0); // try and add the mod lol
      modifiers.get(tagToUse).setVal(val * mmm);
      sortMods();
    }
    strum.debugNeedsUpdate = true;
  }

  // Set a mod value instantly.
  public function setDefaultModVal(tag:String, val:Float):Void
  {
    var tagToUse:String = tag;
    var mmm = ModConstants.invertValueCheck(tagToUse, invertValues);
    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(tag))
    {
      isSub = true;
      subModArr = tag.split('__');
      tagToUse = subModArr[1];
    }

    if (isSub)
    {
      if (modifiers.exists(subModArr[0]))
      {
        modifiers.get(subModArr[0]).setDefaultSubVal(subModArr[1], val * mmm);
      }
      return;
    }

    if (modifiers.exists(tagToUse))
    {
      modifiers.get(tagToUse).setDefaultVal(val * mmm);
    }
    else
    {
      addMod(tagToUse, val, 0.0); // try and add the mod lol
      modifiers.get(tagToUse).setDefaultVal(val * mmm);
    }
  }

  public function addMod(nameOfMod:String, startingValue:Float = 0.0, baseVal = null):Void
  {
    var mod = ModConstants.createNewMod(nameOfMod);
    if (mod == null)
    {
      mod = new Modifier(nameOfMod); // to prevent everything from going to shit when an unknown mod gets used
    }

    var mmm = ModConstants.invertValueCheck(nameOfMod, invertValues);

    startingValue *= mmm;
    mod.baseValue = baseVal == null ? startingValue : baseVal;
    mod.setVal(startingValue);

    // check if is lane mod
    var subModArr = null;
    if (StringTools.contains(mod.tag, "--"))
    {
      subModArr = mod.tag.split('--');
      mod.targetLane = Std.parseInt(subModArr[1]);
    }

    mod.strumOwner = strum;

    modifiers.set(mod.tag, mod);

    // If a 3D mod is spotted, then we need to make sure meshes are created for when it gets enabled!!!
    // Otherwise, meshes are never created for performance reasons if a song never uses the 3D mode.
    if (nameOfMod == "3d")
    {
      strum.requestNoteMeshCreation();
    }
  }

  public function addCustomMod(modIn:CustomModifier, makeCopy:Bool = false):Void
  {
    var mod:CustomModifier = makeCopy ? modIn.clone() : modIn;

    /*
      // we already have this!
      if (modifiers.exists(mod.tag))
      {
        PlayState.instance.modDebugNotif(mod.tag + " already exists?", FlxColor.RED);
        return;
      }
     */

    // check if is lane mod
    var subModArr = null;
    if (StringTools.contains(mod.tag, "--"))
    {
      subModArr = mod.tag.split('--');
      mod.targetLane = Std.parseInt(subModArr[1]);
    }
    mod.strumOwner = strum;

    if (mod.specialMod)
    {
      try
      {
        mod.specialMath(0, strum);
      }
      catch (e)
      {
        PlayState.instance.modDebugNotif(e.toString(), FlxColor.RED);
        return;
      }
    }
    modifiers.set(mod.tag, mod);
  }

  function isSpecialMod(m:Modifier):Bool
  {
    // m.specialMath(0, this.strum);
    if (!m.unknown) return m.specialMod;

    return ModConstants.specialMods.contains(m.tag.toLowerCase());
  }

  var fakeNote:NoteData;

  var sampleModVals:Array<Float> = [-200, -144, -1, -0.5, 0, 0.5, 1, 2, 79, 133, 555];

  function propeModMath_Speed(m:Modifier):Bool
  {
    if (!m.unknown) return m.speedMod;

    var sampleValue:Float = 1;
    var valueChanged:Bool = false;
    var baseModVal:Float = m.currentValue;

    for (i in 0...Strumline.KEY_COUNT)
    {
      for (v in sampleModVals)
      {
        for (s in -3...20)
        {
          m.currentValue = v;
          sampleValue = m.speedMath(i, s * 100, this.strum, false);
          if (sampleValue != 1)
          {
            valueChanged = true;
            break;
          }
        }
      }
    }
    m.currentValue = baseModVal;
    // trace("tested: " + m.tag + " as " + valueChanged);
    return valueChanged;
  }

  var specialModCases:Array<String> = [
    "straightholds",
    "spiralholds",
    "longholds",
    "grain",
    "debugx",
    "debugy",
    "strumx",
    "strumz",
    "strumy",
    "drawdistanceback",
    "drawdistance",
    "showsubmods",
    "showallmods",
    "showextra",
    "showlanemods",
    "showzerovalue",
    "arrowpathgrain",
    "arrowpathlength",
    "arrowpathbacklength",
    "arrowpathstraighthold",
    "arrowpath",
    "arrowpath_notitg",
    "zsort",
    "mathcutoff"
  ];

  function propeModMath(m:Modifier, type:String):Bool
  {
    var valueChanged:Bool = false;
    var modName:String = m.tag.toLowerCase();
    // if (modName == "arrowpath" && type != "strum") return false; // don't add this for now?

    switch (type)
    {
      case "strum":
        if (!m.unknown) return m.strumsMod;
        for (n in specialModCases)
        {
          // trace("n = " + n);
          if (StringTools.contains(modName, n)) valueChanged = true;
        }
      case "arrowpath":
        if (!m.unknown) return m.pathMod;
        if (StringTools.contains(modName, "scale") || StringTools.contains(modName, "angle") || modName == "orient")
        {
          // trace("EEEEEE LOUD BUZZER" + m.tag);
          return false;
        }
      case "hold":
        if (!m.unknown) return m.holdsMod;
        if (modName == "sudden") valueChanged = true;
      case "note":
        if (!m.unknown) return m.notesMod;
        if (modName == "sudden") valueChanged = true;
    }

    // lol, special case for orient mod cuz unique math XD
    if (type != "arrowpath")
    {
      if (modName == "orient" && type != "hold") valueChanged = true;
      else if (modName == "blink") valueChanged = true;
    }
    if (modName == "custompath") valueChanged = true;
    if (valueChanged) return true;

    // trace("about to test: " + m.tag);

    var baseModVal:Float = m.currentValue;
    for (lane in 0...Strumline.KEY_COUNT)
    {
      for (v in sampleModVals)
      {
        for (s in -3...20)
        {
          fakeNote.defaultValues();

          fakeNote.direction = lane;
          fakeNote.curPos = s * 100;
          fakeNote.curPos_unscaled = s * 100 * 1.1;

          m.currentValue = v;
          switch (type)
          {
            case "note":
              m.noteMath(fakeNote, this.strum, false);
            case "hold":
              m.noteMath(fakeNote, this.strum, true);
            case "arrowpath":
              m.noteMath(fakeNote, this.strum, true, true);
            case "strum":
              fakeNote.x = 50; // TEMP
              // m.strumMath(fakeNote, lane, this.strum);
          }

          if (fakeNote.didValueChange())
          {
            m.currentValue = baseModVal;
            valueChanged = true;
            break;
          }
        }
      }
    }
    // trace("tested: " + m.tag + " as " + valueChanged);

    fakeNote.defaultValues();
    m.currentValue = baseModVal;
    return valueChanged;
  }

  // Call this to properly sort the mod apply order!
  public function sortMods(skipProbe:Bool = false):Void
  {
    if (fakeNote == null) fakeNote = new NoteData();

    if (!skipProbe)
    {
      mods_all = [];
      mods_strums = [];
      mods_notes = [];
      mods_speed = [];
      mods_arrowpath = [];
      mods_special = [];

      for (m in modifiers)
      {
        mods_all.push(m);

        if (StringTools.contains(m.tag, "--"))
        {
          // m.modPriority += 6; // make it higher priority if lane mod!
          m.modPriority -= 6; // V0.7.1, NOW IS LOWER PRIORITY FOR SPECIAL MODS TO WORK PROPERLY!
        }

        // test to see if it'll affect this?
        if (propeModMath_Speed(m))
        {
          mods_speed.push(m);
        }
        if (propeModMath(m, "note") || propeModMath(m, "hold"))
        {
          mods_notes.push(m);
        }
        if (propeModMath(m, "strum"))
        {
          mods_strums.push(m);
        }
        if (propeModMath(m, "arrowpath"))
        {
          mods_arrowpath.push(m);
        }
        if (isSpecialMod(m)) mods_special.push(m);
      }
    }

    // mods_arrowpath = mods_all;

    mods_all.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    mods_strums.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    mods_notes.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    mods_speed.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    mods_arrowpath.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    mods_special.sort(function(a, b) {
      if (a.modPriority + a.modPriority_additive < b.modPriority + b.modPriority_additive) return 1;
      else if (a.modPriority + a.modPriority_additive > b.modPriority + b.modPriority_additive) return -1;
      else
        return 0;
    });

    if (traceDebug)
    {
      trace("\n------------------------------");
      trace("ALL MODS TO BE USED:  \n");

      trace("Speed Mods:");
      for (m in mods_speed)
      {
        trace(m.tag);
      }

      trace("\nStrum Mods:");
      for (m in mods_strums)
      {
        trace(m.tag);
      }

      trace("\nNote Mods:");
      for (m in mods_notes)
      {
        trace(m.tag);
      }

      trace("\nArrowPath Mods:");
      for (m in mods_arrowpath)
      {
        trace(m.tag);
      }
      trace("\n------------------------------\n");
    }
  }

  // if true, will do all the traces above ^
  var traceDebug:Bool = false;

  public function getHoldOffsetX(arrowpath:Bool = false, graphicWidth:Float = 0):Float
  {
    if (arrowpath)
    {
      return (Strumline.STRUMLINE_SIZE / 2.0) + 10; // old math to keep paths happy until they become part of notestyle
    }
    else
    {
      // Move the hold note left side to always be in the middle of the strum note!
      // works for default funkin noteskin which is 52.
      var shit:Float = (Strumline.STRUMLINE_SIZE / 2.0) + 28; // JANK NUMBER SPOTTED

      // then offset it with the correct graphicwidth in use
      if (graphicWidth == 0) graphicWidth = strum.sustainGraphicWidth;
      shit -= graphicWidth / 2;

      return shit;
    }
  }

  public function makeHoldCopyStrum_sample(note:ZSprite, strumTime:Float, direction:Int, strumLine:Strumline, notePos:Float, isArrowPath:Bool = false,
      graphicWidth:Float = 0):Float
  {
    var whichStrumNote = strumLine.getByIndex(direction % Strumline.KEY_COUNT);
    var scrollMult:Float = 1.0;
    for (mod in mods_speed)
    {
      scrollMult *= mod.speedMath((direction) % Strumline.KEY_COUNT, notePos, strumLine, true);
    }

    note.x = whichStrumNote.x + getHoldOffsetX(isArrowPath, graphicWidth);
    var sillyPos:Float = strumLine.calculateNoteYPos(strumTime) * scrollMult;

    var note_heighht:Float = 0.0;
    if (Preferences.downscroll)
    {
      note.y = (whichStrumNote.y + sillyPos - note_heighht + Strumline.STRUMLINE_SIZE / 2);
    }
    else
    {
      note.y = (whichStrumNote.y - Strumline.INITIAL_OFFSET + sillyPos + Strumline.STRUMLINE_SIZE / 2);
    }
    note.z = whichStrumNote.z;
    return sillyPos;
  }

  public function mathCutOffCheck(notePos:Float, lane:Int = 0):Bool
  {
    var whichStrumNote:StrumlineNote = strum.getByIndex(lane % Strumline.KEY_COUNT);
    return (whichStrumNote.strumExtraModData.mathCutOff > 0 && !(whichStrumNote.strumExtraModData.mathCutOff >= Math.abs(notePos)));
  }

  public function sampleModMath(susFakeNote:ZSprite, strumTime:Float, lane:Int, strumLine:Strumline, hold:Bool = false, yJank:Bool = false,
      ?notePos:Float = -0.69, ?isArrowpath:Bool = false, ?fakeNoteWidth:Float, ?fakeNoteHeight:Float):Void
  {
    var notePos2:Float = strumLine.calculateNoteYPos(strumTime);
    if (notePos == -0.69 || notePos == null)
    {
      notePos = notePos2;
    }

    if (fakeNote == null) fakeNote = new NoteData();
    fakeNote.defaultValues();
    fakeNote.setValuesFromZSprite(susFakeNote);
    fakeNote.direction = lane;
    fakeNote.curPos = notePos;
    fakeNote.curPos_unscaled = notePos2;

    for (mod in (isArrowpath ? mods_arrowpath : mods_notes))
    {
      mod.noteMath(fakeNote, strumLine, hold, isArrowpath);
    }
    susFakeNote.applyNoteData(fakeNote);

    if (Preferences.downscroll) susFakeNote.y += 27; // fix gap for downscroll lol Moved from verts so it is applied before perspective fucks it up!

    ModConstants.applyPerspective(susFakeNote, fakeNoteWidth, fakeNoteHeight);
  }

  /**
   * Input a noteSprite into this function to set it's position, applying this ModHandler's Mods Array
   * @param note The note to be set.
   * @param orientPass If true, will set the note based on a slightly different strumTime so that it's last known position gets set for orient2 to work.
   */
  public function setNotePos(note:NoteSprite, orientPass:Bool = false):Void
  {
    if (!orientPass && (note.noteModData.orient2[0] != 0 || note.noteModData.orient2[1] != 0 || note.noteModData.orient2[2] != 0))
    {
      setNotePos(note, true);
    }

    note.noteModData.defaultValues();
    note.noteModData.strumTime = note.strumTime + (orientPass ? ModConstants.orientTimeOffset : 0);
    note.noteModData.noteType = note.kind;
    note.noteModData.direction = note.direction;
    note.color = FlxColor.WHITE;
    note.noteModData.whichStrumNote = strum.getByIndex(note.noteModData.direction);
    var timmy:Float = note.noteModData.strumTime - note.noteModData.whichStrumNote.strumExtraModData.strumPos;

    note.noteModData.curPos_unscaled = strum.calculateNoteYPos(timmy);

    for (mod in this.mods_speed)
    {
      if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
      note.noteModData.speedMod *= mod.speedMath(note.noteModData.direction, note.noteModData.curPos_unscaled, strum, false);
    }
    note.noteModData.curPos = strum.calculateNoteYPos(timmy) * note.noteModData.speedMod;

    if (strum.dumbTempScaleTargetThing == null) strum.dumbTempScaleTargetThing = note.targetScale;

    note.scale.set(note.targetScale, note.targetScale);
    note.noteModData.scaleX = note.scale.x;
    note.noteModData.scaleY = note.scale.y;

    note.noteModData.angleZ = note.noteModData.whichStrumNote.angle;
    note.noteModData.y = note.noteModData.whichStrumNote.y + note.noteModData.getNoteYOffset() + note.noteModData.curPos;
    note.noteModData.z = note.noteModData.whichStrumNote.z; // Copy strum Z

    note.noteModData.x = strum.x;
    note.noteModData.x += strum.getXPos(note.noteModData.direction);
    note.noteModData.x -= (note.width - Strumline.STRUMLINE_SIZE) / 2; // Center it
    note.noteModData.x -= Strumline.NUDGE;

    var defaultPosition:Array<Float> = getDefaultStrumPos(note.noteModData.direction);
    var xDif:Float = note.noteModData.whichStrumNote.x - defaultPosition[0];
    note.noteModData.x += xDif;
    note.noteModData.y -= note.noteModData.whichStrumNote.strumExtraModData.noteStyleOffsetY;

    if (!this.mathCutOffCheck(note.noteModData.curPos, note.noteModData.direction))
    {
      for (mod in this.mods_notes)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.noteMath(note.noteModData, strum);
      }

      for (mod in note.noteModData.noteMods)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.noteMath(note.noteModData, strum);
      }
    }
    note.noteModData.funnyOffMyself();

    note.applyNoteData(note.noteModData);
    note.updateLastKnownPos();
    note.noteModData.lastKnownPosition = note.lastKnownPosition;

    if (!(note.noteModData?.whichStrumNote?.strumExtraModData?.threeD ?? false))
    {
      ModConstants.playfieldSkew(note, note.noteModData.skewX_playfield, note.noteModData.skewY_playfield,
        note.noteModData.whichStrumNote.strumExtraModData.playfieldX, note.noteModData.whichStrumNote.strumExtraModData.playfieldY, note.width / 2,
        note.height / 2);
      // undo the strum skew
      note.x -= note.noteModData.whichStrumNote.strumExtraModData.skewMovedX;
      note.y -= note.noteModData.whichStrumNote.strumExtraModData.skewMovedY;
      note.skew.x += note.noteModData.skewX_playfield;
      note.skew.y += note.noteModData.skewY_playfield;
    }

    // for mesh shenaniguns
    if (note.mesh != null)
    {
      note.mesh.pivotOffsetX = note.noteModData.meshOffsets_PivotX;
      note.mesh.pivotOffsetY = note.noteModData.meshOffsets_PivotY;
      note.mesh.pivotOffsetZ = note.noteModData.meshOffsets_PivotZ;
      note.mesh.skewX_offset = note.noteModData.meshOffsets_SkewX;
      note.mesh.skewY_offset = note.noteModData.meshOffsets_SkewY;
      note.mesh.skewZ_offset = note.noteModData.meshOffsets_SkewZ;
    }

    note.updateStealthGlow();
    // perspective applied in applyperspective part of update routine
  }

  /**
   * Go through each special mod and trigger it's specialMath function
   */
  public function updateSpecialMods():Void
  {
    for (lane in 0...Strumline.KEY_COUNT)
    {
      for (mod in this.mods_special)
      {
        if (mod.targetLane != -1 && lane != mod.targetLane) continue;
        try
        {
          mod.specialMath(lane, strum);
        }
        catch (e)
        {
          PlayState.instance.modDebugNotif(e.toString(), FlxColor.RED);
          return;
        }
      }
    }
  }

  public function getStrumOffsetX():Float
  {
    @:privateAccess
    return strum.noteStyle._data.assets.noteStrumline.offsets[0];
  }

  public function getStrumOffsetY():Float
  {
    @:privateAccess
    return strum.noteStyle._data.assets.noteStrumline.offsets[1];
  }

  public function getDefaultStrumPos(direction):Array<Float>
  {
    var pos:Array<Float> = [0, 0, 0]; // x,y,z

    pos[0] = strum.getXPos(direction);
    pos[0] += strum.x;
    pos[0] += Strumline.INITIAL_OFFSET;
    pos[1] = strum.y;

    var offsets:Array<Float> = strum.noteStyle.getStrumlineOffsets();
    pos[0] += offsets[0];
    pos[1] += offsets[1];

    return pos;
  }

  /**
   * Sets the StrumlineNote to where it's supposed to be first, BEFORE any modifiers are applied to it.
   */
  function setStrumPos(note:StrumlineNote):Void
  {
    var p:Array<Float> = getDefaultStrumPos(note.direction);
    note.x = p[0];
    note.y = p[1];
    note.z = p[2];

    note.alpha = 1;
    note.angle = 0;
    note.scale.set(note.targetScale, note.targetScale);

    note.skew.x = 0;
    note.skew.y = 0;

    if (note.strumExtraModData.introTweenPercentage != 1)
    {
      var p:Float = note.strumExtraModData.introTweenPercentage;
      note.alpha = p;
      p = 1 - p;
      note.y -= p * 10;
    }

    note.resetStealthGlow(true);
    note.noteModData.defaultValues();
    note.noteModData.setValuesFromZSprite(note);
    note.noteModData.direction = note.direction;
    note.noteModData.whichStrumNote = note;
    note.noteModData.noteType = "receptor";

    note.noteModData.curPos = 0;
    note.noteModData.curPos_unscaled = 0;

    var ohgod:Float = note.strumExtraModData.strumPos;
    note.strumDistance = ohgod;
    note.noteModData.strumPosition = ohgod;

    note.strumExtraModData.playfieldX = strum.x + (2 * Strumline.NOTE_SPACING);
    // note.strumExtraModData.playfieldY = strum.y + (strum.height / 2);
    note.strumExtraModData.playfieldY = FlxG.height / 2;
    note.strumExtraModData.playfieldZ = 0;
  }

  /**
   * This function applies the modifier math onto the strumline note!
   */
  function applyStrumModifierMath(note:StrumlineNote, timeOffset:Float = 0):Void
  {
    if (note.strumDistance != 0 || timeOffset != 0)
    {
      note.noteModData.strumTime = Conductor.instance?.songPosition ?? 0;
      note.noteModData.strumTime += note.noteModData.strumPosition + timeOffset;

      note.noteModData.curPos_unscaled = strum.calculateNoteYPos(note.noteModData.strumTime) * -1;
      for (mod in this.mods_speed)
      {
        if (mod.targetLane != -1 && note.direction != mod.targetLane) continue;
        note.noteModData.speedMod *= mod.speedMath(note.noteModData.direction, note.noteModData.curPos_unscaled, strum, false);
      }
      note.noteModData.curPos = strum.calculateNoteYPos(note.noteModData.strumTime) * note.noteModData.speedMod * -1;
      for (mod in this.mods_strums)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.strumMath(note.noteModData, strum);
      }

      note.noteModData.setStrumPosWasHere(); // for rotate mods to still function as intended

      note.noteModData.y += note.noteModData.curPos; // move it like a regular note

      if (!this.mathCutOffCheck(note.noteModData.curPos, note.noteModData.direction))
      {
        for (mod in this.mods_notes)
        {
          if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
          mod.noteMath(note.noteModData, strum, false);
        }
      }
      note.noteModData.strumPosOffsetThingy.x = note.noteModData.strumPosWasHere.x - note.noteModData.x;
      note.noteModData.strumPosOffsetThingy.y = note.noteModData.strumPosWasHere.y - note.noteModData.y;
      note.noteModData.strumPosOffsetThingy.z = note.noteModData.strumPosWasHere.z - note.noteModData.z;
    }
    else
    {
      for (mod in this.mods_strums)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.strumMath(note.noteModData, strum);
      }
    }
    note.applyNoteData(note.noteModData);
    note.updateLastKnownPos();
    note.noteModData.lastKnownPosition = note.lastKnownPosition;
    note.updateStealthGlow();

    if (!(note.strumExtraModData?.threeD ?? false))
    {
      var wasX:Float = note.x;
      var wasY:Float = note.y;
      ModConstants.playfieldSkew(note, note.noteModData.skewX_playfield, note.noteModData.skewY_playfield, note.strumExtraModData.playfieldX,
        note.strumExtraModData.playfieldY, note.width / 2, note.height / 2);
      note.strumExtraModData.skewMovedX = note.x - wasX;
      note.strumExtraModData.skewMovedY = note.y - wasY;
      note.skew.x += note.noteModData.skewX_playfield;
      note.skew.y += note.noteModData.skewY_playfield;
    }

    // for mesh shenaniguns
    if (note.mesh != null)
    {
      note.mesh.pivotOffsetX = note.noteModData.meshOffsets_PivotX;
      note.mesh.pivotOffsetY = note.noteModData.meshOffsets_PivotY;
      note.mesh.pivotOffsetZ = note.noteModData.meshOffsets_PivotZ;
      note.mesh.skewX_offset = note.noteModData.meshOffsets_SkewX;
      note.mesh.skewY_offset = note.noteModData.meshOffsets_SkewY;
      note.mesh.skewZ_offset = note.noteModData.meshOffsets_SkewZ;
    }
  }

  /**
   * Goes through each strumlineNote and set's their position using the current active mods.
   */
  public function updateStrums():Void
  {
    strum.strumlineNotes.forEach(function(note:StrumlineNote) {
      setStrumPos(note);

      note.updateLastKnownPos();
      note.noteModData.lastKnownPosition = note.lastKnownPosition;

      var doOrientPass:Bool = false;
      for (o in 0...note.strumExtraModData.orientExtraMath.length)
      {
        if (note.strumExtraModData.orientExtraMath[o] != 0)
        {
          doOrientPass = true;
          break;
        }
      }

      if (doOrientPass)
      {
        applyStrumModifierMath(note, ModConstants.orientTimeOffset);
        setStrumPos(note);
      }
      applyStrumModifierMath(note);
    });
  }
}
