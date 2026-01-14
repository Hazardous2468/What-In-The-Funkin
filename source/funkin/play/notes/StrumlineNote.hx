package funkin.play.notes;

import funkin.play.notes.notestyle.NoteStyle;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.graphics.FunkinSprite;
import funkin.play.notes.NoteSprite;
import funkin.graphics.ZSprite;
import funkin.graphics.ZSpriteProjected;
import funkin.graphics.shaders.HSVNotesShader;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.StrumExtraData;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxBasic;
import lime.math.Vector2;

/**
 * The actual receptor that you see on screen.
 */
class StrumlineNote extends ZSpriteProjected
{
  var hsvShader:HSVNotesShader;

  public var noteModData:NoteData;
  public var strumExtraModData:StrumExtraData;
  public var strumDistance(default, set):Float;

  function set_strumDistance(value:Float):Float
  {
    this.strumDistance = value;
    if (noteModData != null) noteModData.strumPosition = this.strumDistance;
    return this.strumDistance;
  }

  /**
   * Whether this strumline note is on the player's side or the opponent's side.
   */
  public var isPlayer(default, null):Bool;

  /**
   * The direction which this strumline note is facing.
   */
  public var direction(default, set):NoteDirection;

  function set_direction(value:NoteDirection):NoteDirection
  {
    this.direction = value;
    return this.direction;
  }

  // for identifying what noteStyle this notesprite is using in hxScript or even lua
  public var noteStyleName:String = "funkin";

  /**
   * The Y Offset of the note.
   */
  public var yOffset:Float = 0.0;

  /**
   * Set this flag to `true` to disable performance optimizations that cause
   * the Strumline note sprite to ignore `velocity` and `acceleration`.
   */
  public var forceActive:Bool = false;

  /**
   * How long to continue the hold note animation after a note is pressed.
   */
  static final CONFIRM_HOLD_TIME:Float = 0.15;

  /**
   * How long the hold note animation has been playing after a note is pressed.
   */
  var confirmHoldTimer:Float = -1;

  public function new(noteStyle:NoteStyle, isPlayer:Bool, direction:NoteDirection)
  {
    super(0, 0);

    this.isPlayer = isPlayer;

    this.direction = direction;

    noteStyleName = noteStyle.id;
    setup(noteStyle);

    this.animation.onFrameChange.add(onAnimationFrame);
    this.animation.onFinish.add(onAnimationFinished);

    // Must be true for animations to play.
    this.active = true;

    noteModData = new NoteData();
    strumExtraModData = new StrumExtraData(this);

    this.hsvShader = new HSVNotesShader();
    this.shader = hsvShader;
    updateStealthGlow();

    this.applyAngularVelocityOffset = true;
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (this.alpha <= 0 || !this.visible || !this.alive)
    {
      return;
    }

    this.playfieldSkewCenterX = strumExtraModData.playfieldX;
    this.playfieldSkewCenterY = strumExtraModData.playfieldY;
    this.playfieldSkewCenterZ = strumExtraModData.playfieldZ;

    projectionEnabled = strumExtraModData?.threeD ?? false;
    super.draw();
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

  function onAnimationFrame(name:String, frameNumber:Int, frameIndex:Int):Void
  {
    // Do nothing.
  }

  function onAnimationFinished(name:String):Void
  {
    // Run a timer before we stop playing the confirm animation.
    // On player, this allows holding the confirm key to fall back to press.
    if (isPlayer && name == 'confirm')
    {
      confirmHoldTimer = 0;
    }
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    centerOrigin();

    if (confirmHoldTimer >= 0)
    {
      confirmHoldTimer += elapsed;

      // Ensure the opponent stops holding the key after a certain amount of time.
      if (confirmHoldTimer >= CONFIRM_HOLD_TIME)
      {
        confirmHoldTimer = -1;
        playStatic();
      }
    }
  }

  public var targetScale:Float = 0.7;

  function setup(noteStyle:NoteStyle):Void
  {
    if (noteStyle == null)
    {
      // If you get an exception on this line, check the debug console.
      // You probably have a parsing error in your note style's JSON file.
      throw "FATAL ERROR: Attempted to initialize PlayState with an invalid NoteStyle.";
    }

    noteStyle.applyStrumlineFrames(this);
    noteStyle.applyStrumlineAnimations(this, this.direction);

    var scale = noteStyle.getStrumlineScale();
    this.scale.set(scale, scale);
    this.updateHitbox();
    noteStyle.applyStrumlineOffsets(this);

    this.playStatic();
    targetScale = this.scale.x;
  }

  public function playAnimation(name:String = 'static', force:Bool = false, reversed:Bool = false, startFrame:Int = 0):Void
  {
    this.animation.play(name, force, reversed, startFrame);

    centerOffsets();
    centerOrigin();
  }

  public function playStatic():Void
  {
    this.active = (forceActive || isAnimationDynamic('static'));
    this.playAnimation('static', true);
  }

  public function playPress():Void
  {
    this.active = (forceActive || isAnimationDynamic('press'));
    this.playAnimation('press', true);
  }

  public function playConfirm():Void
  {
    this.active = (forceActive || isAnimationDynamic('confirm'));
    this.playAnimation('confirm', true);

    // On opponent, run a timer to stop playing the confirm animation.
    // On player, stop the timer to avoid stopping the confirm animation earlier.
    confirmHoldTimer = isPlayer ? -1 : 0;
  }

  public function isConfirm():Bool
  {
    return getCurrentAnimation().startsWith('confirm');
  }

  public function holdConfirm():Void
  {
    this.active = true;

    if (getCurrentAnimation() == "confirm-hold")
    {
      return;
    }
    else if (getCurrentAnimation() == "confirm")
    {
      if (isAnimationFinished())
      {
        this.confirmHoldTimer = -1;
        this.playAnimation('confirm-hold', false, false);
      }
    }
    else
    {
      this.playAnimation('confirm', false, false);
    }
  }

  static final DEFAULT_OFFSET:Int = 13;

  /**
   * Adjusts the position of the sprite's graphic relative to the hitbox.
   */
  function fixOffsets():Void
  {
    // Automatically center the bounding box within the graphic.
    this.centerOffsets();

    if (getCurrentAnimation() == "confirm")
    {
      // Move the graphic down and to the right to compensate for
      // the "glow" effect on the strumline note.
      this.offset.x -= DEFAULT_OFFSET;
      this.offset.y -= DEFAULT_OFFSET;
    }
    else
    {
      this.centerOrigin();
    }
  }
}
