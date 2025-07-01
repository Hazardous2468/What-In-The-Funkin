package funkin.play.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.graphics.ZSprite;
import funkin.play.notes.notestyle.NoteStyle;
import funkin.graphics.shaders.HSVNotesShader;

class NoteSplash extends ZSprite
{
  public var splashFramerate:Int = 24;
  public var splashFramerateVariance:Int = 2;

  static var frameCollection:FlxFramesCollection;

  public var DIRECTION:Int = 0;

  // If set to true, will copy the HSV values from the note that triggered this notesplash. Unique to v0.8.0 (WITF)
  public var copyHSV:Bool = false;

  var hsvShader:HSVNotesShader;

  var noteStyle:NoteStyle = null;

  public function new(noteStyle:NoteStyle)
  {
    super(0, 0);
    this.noteStyle = noteStyle;

    setupSplashGraphic(noteStyle);

    this.animation.onFinish.add(this.onAnimationFinished);

    this.hsvShader = new HSVNotesShader();
    this.shader = hsvShader;
  }

  public function setHSV(hue:Float, sat:Float, val:Float):Void
  {
    if (hsvShader != null)
    {
      this.hsvShader.hue = hue;
      this.hsvShader.saturation = sat;
      this.hsvShader.value = val;
    }
  }

  /**
   * Add ALL the animations to this sprite. We will recycle and reuse the FlxSprite multiple times.
   */
  function setupSplashGraphic(noteStyle:NoteStyle):Void
  {
    if (frames == null) noteStyle.buildSplashSprite(this);

    if (this.animation.getAnimationList().length < 8)
    {
      trace('WARNING: NoteSplash failed to initialize all animations.');
    }
  }

  public function playAnimation(name:String, force:Bool = false, reversed:Bool = false, startFrame:Int = 0):Void
  {
    this.animation.play(name, force, reversed, startFrame);
  }

  public function play(direction:NoteDirection, variant:Int = null):Void
  {
    this.DIRECTION = direction;
    if (variant == null)
    {
      var animationAmount:Int = this.animation.getAnimationList().filter(function(anim) return anim.name.startsWith('splash${direction.nameUpper}')).length
        - 1;
      variant = FlxG.random.int(0, animationAmount);
    }

    // splashUP0, splashUP1, splashRIGHT0, etc.
    // the animations are processed via `NoteStyle.fetchSplashAnimationData()` in this format
    this.playAnimation('splash${direction.nameUpper}${variant}');

    if (animation.curAnim == null) return;

    // Vary the speed of the animation a bit.
    animation.curAnim.frameRate = splashFramerate + FlxG.random.int(-splashFramerateVariance, splashFramerateVariance);

    // Center the animation on the note splash.
    offset.set(width * 0.3, height * 0.3);
  }

  public function onAnimationFinished(animationName:String):Void
  {
    // *lightning* *zap* *crackle*
    this.kill();
  }
}
