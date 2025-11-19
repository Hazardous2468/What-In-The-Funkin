package funkin.play.modchartSystem;

import flixel.FlxG;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import lime.graphics.Image;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.display.BitmapDataChannel;
import openfl.display.BlendMode;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.Vector;
import openfl.display.GraphicsPathCommand;
import funkin.play.notes.Strumline;
import lime.math.Vector2;
import funkin.graphics.ZSprite;
import funkin.play.notes.StrumlineNote;

// SCRAPED BECAUSE IT JUST CAUSED MAJOR LAG PROBLEMS LOL
class HazardArrowpath
{
  // The actual bitmap data
  public var bitmap:BitmapData;

  var flashGfxSprite(default, null):Sprite = new Sprite();
  var flashGfx(default, null):Graphics;

  // For limiting the AFT update rate. Useful to make it less framerate dependent.
  // TODO -> Make a public function called limitAFT() which takes a target FPS (like the mirin template plugin)
  public var updateTimer:Float = 0.0;
  public var updateRate:Float = 0.25;

  // Just a basic rectangle which fills the entire bitmap when clearing out the old pixel data
  var rec:Rectangle;

  var blendMode:String = "normal";
  var colTransf:ColorTransform;

  var strum:Strumline;

  var fakeNoteData:NoteData;

  function setNotePos(note:ZSprite, strumTime:Float, lane:Int, whichStrumNote:StrumlineNote):Void
  {
    // note.strumTime = Conductor.instance?.songPosition ?? 0;
    // note.strumTime -= arrowpathBackwardsLength[note.noteDirection % KEY_COUNT] ?? 0;

    var scrollMult:Float = 1.0;
    var notePosUnscaled:Float = strum.calculateNoteYPos(strumTime);

    // for (mod in modifiers){
    for (mod in strum.mods.mods_speed)
    {
      if (mod.targetLane != -1 && lane != mod.targetLane) continue;
      scrollMult *= mod.speedMath(lane, notePosUnscaled, strum, true);
    }

    var notePos:Float = strum.calculateNoteYPos(strumTime) * scrollMult;
    note.angle = whichStrumNote.angle;
    note.x = whichStrumNote.x + strum.getNoteXOffset();
    // note.set_y(whichStrumNote.y - INITIAL_OFFSET + notePos);

    note.y = whichStrumNote.y + strum.getNoteYOffset() + notePos;

    note.x += whichStrumNote.width / 2 * ModConstants.noteScale;
    note.y += whichStrumNote.height / 2 * ModConstants.noteScale;

    note.z = whichStrumNote.z;
    note.alpha = 1;
    note.scale.set(ModConstants.noteScale, ModConstants.noteScale);

    fakeNoteData.defaultValues();
    fakeNoteData.setValuesFromZSprite(note);
    fakeNoteData.direction = lane;
    fakeNoteData.speedMod = scrollMult;
    fakeNoteData.curPos = notePos;
    fakeNoteData.curPos_unscaled = notePosUnscaled;
    fakeNoteData.strumTime = strumTime;
    fakeNoteData.whichStrumNote = whichStrumNote;

    for (mod in strum.mods.mods_arrowpath)
    {
      if (mod.targetLane != -1 && fakeNoteData.direction != mod.targetLane) continue;
      mod.noteMath(fakeNoteData, strum, true, true);
    }

    fakeNoteData.funnyOffMyself();
    fakeNote.applyNoteData(fakeNoteData);

    ModConstants.applyPerspective(fakeNote, defaultLineSize, 1);
  }

  var fakeNote:ZSprite;
  var defaultLineSize:Float = 2;

  public function updateAFT():Void
  {
    bitmap.lock();
    clearAFT();
    flashGfx.clear();

    for (l in 0...Strumline.KEY_COUNT)
    {
      final whichStrumNote:StrumlineNote = strum.getByIndex(l % Strumline.KEY_COUNT);

      // var arrowPathAlpha:Float = strum.arrowPathAlpha[l];
      var arrowPathAlpha:Float = whichStrumNote?.strumExtraModData?.arrowPathAlpha;
      if (arrowPathAlpha <= 0) continue; // skip path if we can't see shit

      var pathLength:Float = whichStrumNote?.strumExtraModData?.arrowpathLength ?? 1500;
      var pathBackLength:Float = whichStrumNote?.strumExtraModData?.arrowpathBackwardsLength ?? 200;
      var holdGrain:Float = ModConstants.defaultPathGrain;

      final fullLength:Float = pathLength + pathBackLength;
      var holdResolution:Int = 2; // Will get set after the first sample to get the path-specific modifiers (mainly grain)

      // https://github.com/4mbr0s3-2/Schmovin/blob/main/SchmovinRenderers.hx
      var commands = new Vector<Int>();
      var data = new Vector<Float>();

      var tim:Float = Conductor.instance?.songPosition ?? 0;
      tim -= whichStrumNote.strumExtraModData.strumPos; // for drive2 mod
      tim -= pathBackLength;
      for (i in 0...holdResolution)
      {
        if (i == 0)
        {
          setNotePos(fakeNote, tim, l, whichStrumNote);
          holdGrain = fakeNoteData.holdGrain;
          holdResolution = Math.floor(fullLength / holdGrain);
        }
        else
        {
          var timmy:Float = ((fullLength / holdResolution) * i);
          setNotePos(fakeNote, tim + timmy, l, whichStrumNote);
        }

        var scaleX = FlxMath.remapToRange(fakeNote.scale.x, 0, ModConstants.noteScale, 0, 1);
        var lineSize:Float = defaultLineSize * scaleX;

        var path2:Vector2 = new Vector2(fakeNote.x, fakeNote.y);

        if (i == 0)
        {
          commands.push(GraphicsPathCommand.MOVE_TO);
          flashGfx.lineStyle(lineSize, fakeNote.color, arrowPathAlpha);
        }
        else
        {
          commands.push(GraphicsPathCommand.LINE_TO);
        }
        data.push(path2.x);
        data.push(path2.y);
      }
      flashGfx.drawPath(commands, data);
    }
    bitmap.draw(flashGfxSprite);
    bitmap.disposeImage();
    flashGfx.clear();
    bitmap.unlock();
  }

  // clear out the old bitmap data
  public function clearAFT():Void
  {
    bitmap.fillRect(rec, 0);
  }

  public function update(elapsed:Float = 0.0):Void
  {
    if (bitmap != null)
    {
      if (updateTimer >= 0 && updateRate != 0)
      {
        updateTimer -= elapsed;
      }
      else if (updateTimer < 0 || updateRate == 0)
      {
        updateTimer = updateRate;
        updateAFT();
      }
    }
  }

  var width:Int = 0;
  var height:Int = 0;

  public function new(s:Strumline, w:Int = -1, h:Int = -1)
  {
    fakeNoteData = new NoteData();
    fakeNote = new ZSprite();
    this.strum = s;
    // this.lane = col;
    height = h;
    width = w;
    if (width == -1 || height == -1)
    {
      width = FlxG.width;
      height = FlxG.height;
    }

    flashGfx = flashGfxSprite.graphics;
    bitmap = new BitmapData(width, height, true, 0);
    rec = new Rectangle(0, 0, width, height);
    colTransf = new ColorTransform();
  }
}
