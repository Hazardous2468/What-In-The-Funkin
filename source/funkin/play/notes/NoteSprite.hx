package funkin.play.notes;

import flixel.FlxBasic;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import funkin.data.song.SongData.NoteParamData;
import funkin.data.song.SongData.SongNoteData;
import funkin.graphics.FunkinSprite;
import funkin.graphics.ZProjectSprite_Note;
import funkin.graphics.ZSprite;
import funkin.graphics.shaders.HSVNotesShader;
import funkin.play.modchartSystem.NoteData;
import funkin.play.notes.notestyle.NoteStyle;

class NoteSprite extends ZSprite
{
  public var mesh:ZProjectSprite_Note;
  public var noteModData:NoteData;

  static final DIRECTION_COLORS:Array<String> = ['purple', 'blue', 'green', 'red'];

  public var holdNoteSprite:SustainTrail;

  public var hsvShader:HSVNotesShader;

  /**
   * The strum time at which the note should be hit, in milliseconds.
   */
  public var strumTime(get, set):Float;

  function get_strumTime():Float
  {
    return this.noteData?.time ?? 0.0;
  }

  function set_strumTime(value:Float):Float
  {
    if (this.noteData == null) return value;
    return this.noteData.time = value;
  }

  /**
   * The length for which the note should be held, in milliseconds.
   * Defaults to 0 for single notes.
   */
  public var length(get, set):Float;

  function get_length():Float
  {
    return this.noteData?.length ?? 0.0;
  }

  function set_length(value:Float):Float
  {
    if (this.noteData == null) return value;
    return this.noteData.length = value;
  }

  /**
   * An extra attribute for the note.
   * For example, whether the note is an "alt" note, or whether it has custom behavior on hit.
   */
  public var kind(get, set):Null<String>;

  function get_kind():Null<String>
  {
    return this.noteData?.kind;
  }

  function set_kind(value:String):String
  {
    if (this.noteData == null) return value;
    return this.noteData.kind = value;
  }

  /**
   * An array of custom parameters for this note
   */
  public var params(get, set):Array<NoteParamData>;

  function get_params():Array<NoteParamData>
  {
    return this.noteData?.params ?? [];
  }

  function set_params(value:Array<NoteParamData>):Array<NoteParamData>
  {
    if (this.noteData == null) return value;
    return this.noteData.params = value;
  }

  /**
   * The data of the note (i.e. the direction.)
   */
  public var direction(default, set):NoteDirection;

  function set_direction(value:Int):Int
  {
    if (frames == null) return value;

    playNoteAnimation(value);

    this.direction = value;
    return this.direction;
  }

  public var noteData:SongNoteData;

  public var isHoldNote(get, never):Bool;

  function get_isHoldNote():Bool
  {
    return noteData.length > 0;
  }

  /**
   * The Y Offset of the note.
   */
  public var yOffset:Float = 0.0;

  /**
   * Set this flag to true when hitting the note to avoid scoring it multiple times.
   */
  public var hasBeenHit:Bool = false;

  /**
   * Register this note as hit only after any other notes
   */
  public var lowPriority:Bool = false;

  /**
   * This is true if the note is later than 10 frames within the strumline,
   * and thus can't be hit by the player.
   * It will be destroyed after it moves offscreen.
   * Managed by PlayState.
   */
  public var hasMissed:Bool;

  /**
   * This is true if the note is earlier than 10 frames within the strumline.
   * and thus can't be hit by the player.
   * Managed by PlayState.
   */
  public var tooEarly:Bool;

  /**
   * This is true if the note is within 10 frames of the strumline,
   * and thus may be hit by the player.
   * Managed by PlayState.
   */
  public var mayHit:Bool;

  /**
   * This is true if the PlayState has performed the logic for missing this note.
   * Subtracting score, subtracting health, etc.
   */
  public var handledMiss:Bool;

  // Call this to create a mesh
  public function setupMesh():Void
  {
    if (mesh == null)
    {
      mesh = new ZProjectSprite_Note();
      mesh.graphicCacheSuffix = noteStyleName;
      mesh.spriteGraphic = this;
      mesh.doDraw = false;
      mesh.copySpriteGraphic = false;
    }
    mesh.setUp();
  }

  public var vwooshing:Bool = false;

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (this.alpha <= 0 || !this.visible || !this.alive)
    {
      return;
    }

    if (mesh != null && noteModData?.whichStrumNote?.strumExtraModData?.threeD ?? false)
    {
      if (!vwooshing)
      {
        mesh.x = noteModData.x;
        mesh.y = noteModData.y;
        mesh.z = noteModData.z;

        mesh.angleX = noteModData.angleX;
        mesh.angleY = noteModData.angleY;
        mesh.angleZ = noteModData.angleZ;

        mesh.scaleX = noteModData.scaleX;
        mesh.scaleY = noteModData.scaleY;
        mesh.scaleZ = noteModData.scaleZ;

        mesh.skewX = noteModData.skewX;
        mesh.skewY = noteModData.skewY;
        mesh.skewZ = noteModData.skewZ;
        mesh.skewX_playfield = noteModData.skewX_playfield;
        mesh.skewY_playfield = noteModData.skewY_playfield;
        mesh.skewZ_playfield = noteModData.skewZ_playfield;

        mesh.playfieldSkewCenterX = (noteModData?.whichStrumNote?.strumExtraModData?.playfieldX ?? FlxG.width / 2);
        mesh.playfieldSkewCenterY = (noteModData?.whichStrumNote?.strumExtraModData?.playfieldY ?? FlxG.height / 2);
        mesh.playfieldSkewCenterZ = (noteModData?.whichStrumNote?.strumExtraModData?.playfieldZ ?? 0);

        mesh.offset = this.offset;
        mesh.cameras = this.cameras;
      }

      mesh.updateTris();
      mesh.graphicCacheSuffix = noteStyleName;
      mesh.drawManual(this.graphic);
    }
    else
    {
      super.draw();
    }
  }

  // for identifying what noteStyle this notesprite is using in hxScript or even lua
  public var noteStyleName:String = "funkin";

  public function new(noteStyle:NoteStyle, direction:Int = 0)
  {
    super(0, -9999);
    this.direction = direction;

    this.hsvShader = new HSVNotesShader();

    noteModData = new NoteData();

    noteStyleName = noteStyle.id;

    setupNoteGraphic(noteStyle);
    vwooshing = false;
  }

  public var targetScale:Float = 0.7;

  /**
   * Creates frames and animations
   * @param noteStyle The `NoteStyle` instance
   */
  public function setupNoteGraphic(noteStyle:NoteStyle):Void
  {
    noteStyle.buildNoteSprite(this);

    this.shader = hsvShader;
    stealthGlow = 0.0;
    stealthGlowBlue = 1.0;
    stealthGlowGreen = 1.0;
    stealthGlowRed = 1.0;
    updateStealthGlow();
    if (mesh != null) mesh.updateCol();

    targetScale = this.scale.x;

    // `false` disables the update() function for performance.
    this.active = noteStyle.isNoteAnimated();
  }

  /**
   * Retrieve the value of the param with the given name
   * @param name Name of the param
   * @return Null<Dynamic>
   */
  public function getParam(name:String):Null<Dynamic>
  {
    for (param in params)
    {
      if (param.name == name)
      {
        return param.value;
      }
    }
    return null;
  }

  #if FLX_DEBUG
  /**
   * Call this to override how debug bounding boxes are drawn for this sprite.
   */
  public override function drawDebugOnCamera(camera:flixel.FlxCamera):Void
  {
    if (!camera.visible || !camera.exists || !isOnScreen(camera)) return;

    var gfx = beginDrawDebug(camera);

    var rect = getBoundingBox(camera);
    trace('note sprite bounding box: ' + rect.x + ', ' + rect.y + ', ' + rect.width + ', ' + rect.height);

    gfx.lineStyle(2, 0xFFFF66FF, 0.5); // thickness, color, alpha
    gfx.drawRect(rect.x, rect.y, rect.width, rect.height);

    gfx.lineStyle(2, 0xFFFFFF66, 0.5); // thickness, color, alpha
    gfx.drawRect(rect.x, rect.y + rect.height / 2, rect.width, 1);

    endDrawDebug(camera);
  }
  #end

  function playNoteAnimation(value:Int):Void
  {
    animation.play(DIRECTION_COLORS[value] + 'Scroll');
  }

  public function desaturate():Void
  {
    this.hsvShader.saturation = 0.2;
  }

  public function setHue(hue:Float):Void
  {
    this.hsvShader.hue = hue;
  }

  public override function revive():Void
  {
    super.revive();
    this.visible = true;
    this.alpha = 1.0;
    this.active = false;
    this.tooEarly = false;
    this.hasBeenHit = false;
    this.mayHit = false;
    this.hasMissed = false;
    vwooshing = false;

    this.hsvShader.hue = 1.0;
    this.hsvShader.saturation = 1.0;
    this.hsvShader.value = 1.0;

    if (mesh != null) mesh.updateCol();

    resetStealthGlow();
  }

  // call this to reset stealthGlow back to default values
  public function resetStealthGlow(skipUpdate:Bool = false):Void
  {
    this.stealthGlow = 0.0;
    this.stealthGlowBlue = 1.0;
    this.stealthGlowGreen = 1.0;
    this.stealthGlowRed = 1.0;
    if (!skipUpdate) updateStealthGlow();
  }

  // call this to update the stealthglow on the hsv shader
  public function updateStealthGlow():Void
  {
    this.hsvShader.stealthGlow = stealthGlow;
    this.hsvShader.stealthGlowBlue = stealthGlowBlue;
    this.hsvShader.stealthGlowGreen = stealthGlowGreen;
    this.hsvShader.stealthGlowRed = stealthGlowRed;
  }

  public override function kill():Void
  {
    super.kill();
    vwooshing = false;
  }

  public override function destroy():Void
  {
    // This function should ONLY get called as you leave PlayState entirely.
    // Otherwise, we want the game to keep reusing note sprites to save memory.
    super.destroy();
  }
}
