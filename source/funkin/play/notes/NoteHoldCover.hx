package funkin.play.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.notes.notestyle.NoteStyle;
import funkin.util.assets.FlxAnimationUtil;
import funkin.graphics.shaders.HSVNotesShader;

class NoteHoldCover extends FlxTypedSpriteGroup<ZSprite>
{
  static final FRAMERATE_DEFAULT:Int = 24;

  public var holdNote:SustainTrail;

  public var glow:ZSprite;
  public var sparks:ZSprite;

  public var holdNoteDir:Int = 0;

  var hsvShader:HSVNotesShader;

  var noteStyle:NoteStyle;

  // Custom position logic added by WITF that positions holdCovers at the ends of holds (where they get clipped) instead of at the strumNote.
  public var holdPositioned(default, set):Bool;

  function set_holdPositioned(value:Bool):Bool
  {
    if (glow != null) glow.autoCalculatePerspective = !value;
    holdPositioned = value;
    return holdPositioned;
  }

  public function new(noteStyle:NoteStyle)
  {
    super(0, 0);
    setupHoldNoteCover(noteStyle);
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
  function setupHoldNoteCover(noteStyle:NoteStyle):Void
  {
    this.noteStyle = noteStyle;

    glow = new ZSprite();
    glow.isHoldCover = true;
    glow.coverBehindStrums = noteStyle.holdCoversBehindStrums();
    add(glow);
    glow.applyAngularVelocityOffset = true;

    // TODO: null check here like how NoteSplash does
    noteStyle.buildHoldCoverSprite(this);

    glow.animation.onFinish.add(this.onAnimationFinished);

    if (glow.animation.getAnimationList().length < 3 * 4)
    {
      trace('WARNING: NoteHoldCover failed to initialize all animations.');
    }

    var holdOrigin = noteStyle.getHoldCoverOrigin();
    if (holdOrigin == null)
    {
      autoOrigin = true;
    }
    else
    {
      if (holdOrigin.length >= 2 && holdOrigin[2] >= 1)
      {
        autoOrigin = true;
      }
      else
      {
        autoOrigin = false;
        this.glow.origin.set(holdOrigin[0], holdOrigin[1]); // Magic numbers which make it rotate from the center properly!
      }
    }
  }

  public var autoOrigin:Bool = false;

  public override function update(elapsed):Void
  {
    if (autoOrigin) glow.centerOrigin();
    if (!holdPositioned)
    {
      var o = noteStyle.getHoldCoverZCalcOffsetMultipliers();
      glow.perspectiveWidth = glow.width * o[0];
      glow.perspectiveHeight = glow.height * o[1];
    }
    super.update(elapsed);
  }

  public function playStart():Void
  {
    var direction:NoteDirection = holdNote.noteDirection;
    holdNoteDir = direction;
    glow.animation.play('holdCoverStart${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public function playContinue():Void
  {
    var direction:NoteDirection = holdNote?.noteDirection ?? holdNoteDir;
    glow.animation.play('holdCover${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public function playEnd():Void
  {
    var direction:NoteDirection = holdNote?.noteDirection ?? holdNoteDir;
    glow.animation.play('holdCoverEnd${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public override function kill():Void
  {
    super.kill();

    this.visible = false;

    if (holdNote != null) holdNote.cover = null;

    if (glow != null) glow.visible = false;
    if (sparks != null) sparks.visible = false;
  }

  public override function revive():Void
  {
    super.revive();

    this.visible = true;
    this.alpha = 1.0;

    if (glow != null) glow.visible = true;
    if (sparks != null) sparks.visible = true;
  }

  public function onAnimationFinished(animationName:String):Void
  {
    if (animationName.startsWith('holdCoverStart'))
    {
      playContinue();
    }
    if (animationName.startsWith('holdCoverEnd'))
    {
      // *lightning* *zap* *crackle*
      this.visible = false;
      this.kill();
    }
  }
}
