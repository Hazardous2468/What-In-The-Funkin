package funkin.play.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.notes.notestyle.NoteStyle;
import funkin.util.assets.FlxAnimationUtil;
import funkin.graphics.shaders.HSVShader;

class NoteHoldCover extends FlxTypedSpriteGroup<ZSprite>
{
  static final FRAMERATE_DEFAULT:Int = 24;

  public var holdNote:SustainTrail;

  public var glow:ZSprite;
  public var sparks:ZSprite;

  public var holdNoteDir:Int = 0;

  var hsvShader:HSVShader;

  public function new(noteStyle:NoteStyle)
  {
    super(0, 0);

    setupHoldNoteCover(noteStyle);
    this.hsvShader = new HSVShader();
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
    glow = new ZSprite();
    add(glow);

    // TODO: null check here like how NoteSplash does
    noteStyle.buildHoldCoverSprite(this);

    glow.animation.onFinish.add(this.onAnimationFinished);

    if (glow.animation.getAnimationList().length < 3 * 4)
    {
      trace('WARNING: NoteHoldCover failed to initialize all animations.');
    }

    glow.origin.set(160.5, 150); // Magic numbers which make it rotate from the center properly!
    glow.offset.set(13.375, -47.575); // Offset correction
  }

  public override function update(elapsed):Void
  {
    super.update(elapsed);
  }

  public function applyPerspective()
  {
    if (glow != null) ModConstants.applyPerspective(glow);
    if (sparks != null) ModConstants.applyPerspective(sparks);
  }

  public function playStart():Void
  {
    var direction:NoteDirection = holdNote.noteDirection;
    holdNoteDir = holdNote.noteDirection;
    glow.animation.play('holdCoverStart${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public function playContinue():Void
  {
    var direction:NoteDirection = holdNote.noteDirection;
    holdNoteDir = holdNote.noteDirection;
    glow.animation.play('holdCover${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public function playEnd():Void
  {
    var direction:NoteDirection = holdNote.noteDirection;
    holdNoteDir = holdNote.noteDirection;
    glow.animation.play('holdCoverEnd${direction.colorName.toTitleCase()}');
    glow.shader = hsvShader;
  }

  public override function kill():Void
  {
    super.kill();

    this.visible = false;

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
