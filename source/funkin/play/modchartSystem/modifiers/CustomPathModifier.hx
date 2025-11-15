package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;
import lime.math.Vector4;
import sys.FileSystem;
import funkin.modding.PolymodHandler;
import openfl.geom.Vector3D;
import sys.io.File;

class TimeVector extends Vector4
{
  public var startDist:Float;
  public var endDist:Float;
  public var next:TimeVector;

  public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0)
  {
    super(x, y, z, w);
    startDist = 0.0;
    endDist = 0.0;
    next = null;
  }
}

// Contains all mods which are unique or have debug purposes!
// load a path from an external file
class CustomPathMod extends Modifier
{
  // The file this modifier looks for to load when first created
  public var pathToLoad(default, set):String = "path.txt";

  function set_pathToLoad(value:String):String
  {
    this.pathToLoad = value;
    loadPath();
    return this.pathToLoad;
  }

  // The filepath of the loaded arrowpath.
  var customArrowPathModTest:String = null;

  function calculatePathDistances(path:List<TimeVector>):Float
  {
    @:privateAccess
    var iterator_head = path.h;
    var val = iterator_head.item;
    iterator_head = iterator_head.next;
    var last = val;
    last.startDist = 0;
    var dist = 0.0;
    while (iterator_head != null)
    {
      var val = iterator_head.item;
      iterator_head = iterator_head.next;
      var current = val;
      var result = new Vector4();
      result.x = current.x - last.x;
      result.y = current.y - last.y;
      result.z = current.z - last.z;
      var differential = result;
      dist += Math.sqrt(differential.x * differential.x + differential.y * differential.y + differential.z * differential.z);
      current.startDist = dist;
      last.next = current;
      last.endDist = current.startDist;
      last = current;
    }
    return dist;
  }

  function getPointAlongPath(distance:Float):TimeVector
  {
    @:privateAccess
    var _g_head = this._path.h;
    while (_g_head != null)
    {
      var val = _g_head.item;
      _g_head = _g_head.next;
      var vec = val;
      var Min = vec.startDist;
      var Max = vec.endDist;
      // looks like a FlxMath function could be that
      if ((Min == 0 || distance >= Min) && (Max == 0 || distance <= Max) && vec.next != null)
      {
        var ratio = distance - vec.startDist;
        var _this = vec.next;
        var result = new Vector4();
        result.x = _this.x - vec.x;
        result.y = _this.y - vec.y;
        result.z = _this.z - vec.z;
        var ratio1 = ratio / Math.sqrt(result.x * result.x + result.y * result.y + result.z * result.z);
        var vec2 = vec.next;
        var out1 = new Vector4(vec.x, vec.y, vec.z, vec.w);
        var s = 1 - ratio1;
        out1.x *= s;
        out1.y *= s;
        out1.z *= s;
        var out2 = new Vector4(vec2.x, vec2.y, vec2.z, vec2.w);
        out2.x *= ratio1;
        out2.y *= ratio1;
        out2.z *= ratio1;
        var result1 = new Vector4();
        result1.x = out1.x + out2.x;
        result1.y = out1.y + out2.y;
        result1.z = out1.z + out2.z;
        return new TimeVector(result1.x, result1.y, result1.z, result1.w);
      }
    }
    return _path.first();
  }

  function executePath(currentBeat:Float, strumTimeDiff:Float, column:Int, modValue:Float, pos:Vector4):Vector4
  {
    if (_path == null)
    {
      return pos;
    }
    var path = getPointAlongPath(strumTimeDiff / -1500.0 * _pathDistance);
    // var a = new Vector4(FlxG.width / 2, FlxG.height / 2 + 280, column % 4 * getOtherPercent("arrowshapeoffset", player) + pos.z);
    var a = new Vector4(FlxG.width / 2, FlxG.height / 2 + 280, column % 4 * 1 + pos.z);
    var result = new Vector4();
    result.x = path.x + a.x;
    result.y = path.y + a.y;
    result.z = path.z + a.z;
    var vec2 = result;
    // var lerp = getPercent(player);
    var lerp = modValue;
    var out1 = new Vector4(pos.x, pos.y, pos.z, pos.w);
    var s = 1 - lerp;
    out1.x *= s;
    out1.y *= s;
    out1.z *= s;
    var out2 = new Vector4(vec2.x, vec2.y, vec2.z, vec2.w);
    out2.x *= lerp;
    out2.y *= lerp;
    out2.z *= lerp;
    var result = new Vector4();
    result.x = out1.x + out2.x;
    result.y = out1.y + out2.y;
    result.z = out1.z + out2.z;
    return result;
  }

  var _path:List<TimeVector> = null;
  var _pathDistance:Float = 0;

  public function loadPath()
  {
    // scan for the path.txt file
    var songna:String = (PlayState.instance?.currentSong?.id ?? '').toLowerCase();
    var firstCheckTest:String = 'assets/data/modchart/' + PlayState.instance?.currentChart.songName.toLowerCase() + "/";
    var secondCheckTest:String = 'assets/data/modchart/' + songna + "/";
    var foldersToCheck:Array<String> = [firstCheckTest, secondCheckTest];

    customArrowPathModTest = null;

    // fuck it, we just check every mod lmfao
    for (modid in PolymodHandler.loadedModIds)
    {
      var lmfao:String = 'mods/' + modid + '/data/modchart/' + songna + "/";
      foldersToCheck.insert(0, lmfao);
      lmfao = 'mods/' + modid + '/data/modchart/' + PlayState.instance?.currentChart.songName.toLowerCase() + "/";
      foldersToCheck.insert(0, lmfao);
    }

    for (folder in foldersToCheck)
    {
      trace("Looking into - " + folder);
      if (FileSystem.exists(folder))
      {
        trace("Folder exists...");
        for (file in FileSystem.readDirectory(folder))
        {
          trace("file : " + file);
          if (file == pathToLoad && customArrowPathModTest == null)
          {
            customArrowPathModTest = folder + file;
            trace("Oh shit, we found somethin? " + customArrowPathModTest);
            // var file = sys.io.File.getContent(customArrowPathModTest);
            var file_part1 = funkin.util.FileUtil.readStringFromPath(customArrowPathModTest);

            var filePath:Array<String> = [];
            filePath = file_part1.trim().split('\n');

            for (i in 0...filePath.length)
            {
              filePath[i] = filePath[i].trim();
            }
            filePath.reverse(); // lmao, the points are reversed when used in my system

            if (filePath != null)
            {
              var path = new List<TimeVector>();
              var _g = 0;
              while (_g < filePath.length)
              {
                var line = filePath[_g];
                // trace("line: " + line);
                _g++;
                var coords = line.split(";");
                // trace((_g - 1) + "split: " + coords);
                var vec = new TimeVector(Std.parseFloat(coords[0]), Std.parseFloat(coords[1]) * (Preferences.downscroll ? -1 : 1), Std.parseFloat(coords[2]),
                  Std.parseFloat(coords[3]));
                vec.x *= 200;
                vec.y *= 200;
                vec.z *= 200;
                path.add(vec);

                //  trace("x: " + vec.x);
                // trace("y: " + vec.y);
                // trace("z: " + vec.z);
                // trace("-------");
              }

              _pathDistance = calculatePathDistances(path);
              _path = path;
              return; // We done here
            }
            else
            {
              trace("nvm, file is fucked");
              customArrowPathModTest == null;
            }
          }
        }
      }
    }
  }

  var blendSubmod:ModifierSubValue;

  public function new(name:String)
  {
    super(name, 0);
    // modPriority = 119;
    modPriority = 119;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;

    blendSubmod = createSubMod("blend", 1.0);
    loadPath();
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var path = customArrowPathModTest;
    var whichStrumNote = data.whichStrumNote;
    if (path == null || currentValue == 0 || whichStrumNote == null) return;

    var strumX:Float = whichStrumNote.x;
    var strumY:Float = whichStrumNote.y;
    var strumZ:Float = whichStrumNote.z;

    if (data.noteType == "receptor")
    {
      strumX = data.strumPosWasHere.x;
      strumY = data.strumPosWasHere.y;
      strumZ = data.strumPosWasHere.z;
    }
    else
    {
      strumX += isHoldNote ? strumLine.mods.getHoldOffsetX(isArrowPath) : strumLine.getNoteXOffset();
      if (isHoldNote)
      {
        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        strumY -= Strumline.INITIAL_OFFSET;
      }
    }

    var strumPosition:Vector4 = new Vector4(strumX, strumY, strumZ, 0);
    var notePosition:Vector4 = new Vector4(data.x, data.y, data.z, 0);

    var newPosition1:Vector4 = executePath(beatTime, Math.abs(data.whichStrumNote?.noteModData?.curPos ?? 0.0) * -1 / 0.47, data.direction, currentValue,
      strumPosition);
    var newPosition2:Vector4 = executePath(beatTime, Math.abs(data.curPos) * -1 / 0.47, data.direction, currentValue, notePosition);

    var blend:Float = Math.abs(currentValue);
    if (blendSubmod.value < 0.5) blend = 0;
    blend = FlxMath.bound(blend, 0, 1); // clamp

    data.x = notePosition.x + ((newPosition1.x - newPosition2.x) * blend);
    data.y = notePosition.y + ((newPosition1.y - newPosition2.y) * blend);
    data.z = notePosition.z + ((newPosition1.z - newPosition2.z) * blend);

    // automatically apply linearY mod to cancel the default y movement
    var curVal:Float = currentValue * -1;
    data.y += data.curPos * curVal;
  }

  var calculatedOffset:Bool = false;
  var offset:Vector3D = new Vector3D(0, 0, 0);

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var path = customArrowPathModTest;
    if (path == null) return;

    if (!calculatedOffset)
    {
      calculatedOffset = true;

      var wasHereOriginally = ModConstants.getDefaultStrumPosition(strumLine, data.direction);

      var newPosition = executePath(beatTime, 0.0, data.direction, 1.0, new Vector4(data.x, data.y, data.z, 0));
      offset = new Vector3D(wasHereOriginally.x - newPosition.x, wasHereOriginally.y - newPosition.y, wasHereOriginally.z - newPosition.z);

      offset.x += (1.5 * Strumline.NOTE_SPACING); // To make the notes flip towards the center instead of all onto lane 0

      trace("offset calculted!");
      trace(offset.x);
      trace(offset.y);
      trace(offset.z);
    }

    if (currentValue == 0) return;

    var newPosition = executePath(beatTime, 0.0, data.direction, currentValue, new Vector4(data.x, data.y, data.z, 0));
    data.x = newPosition.x + (offset.x * currentValue);
    data.y = newPosition.y + (offset.y * currentValue);
    data.z = newPosition.z + (offset.z * currentValue);
  }
}
