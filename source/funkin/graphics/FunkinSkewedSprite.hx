package funkin.graphics;

import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxVelocity;
import flixel.graphics.frames.FlxFrame;
import animate.FlxAnimate;

/**
 * A FunkinSprite which implements FlxSkewedSprite, allowing this sprite to skew!
 * Also introduces Spin and Scale 2 variables and a tag you can use to easily assign a name to the sprite -Hazard
 * Original author of FlxSkewedSprite: Zaphod
 */
class FunkinSkewedSprite extends FunkinSprite
{
  /**
   * A handy string that can be used to 'tag' a sprite.
   */
  public var tag:Null<String> = null;

  // I dont think theres a way to override the matrix without needing to do this lol
  #if (flixel >= "6.1.0")
  override function drawFrameComplex(frame:FlxFrame, camera:FlxCamera):Void
  #else
  override function drawComplex(camera:FlxCamera):Void
  #end
  {
    #if (flixel < "6.1.0") final frame = this._frame; #end
    final matrix = this._matrix; // TODO: Just use local?

    frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    matrix.translate(-origin.x, -origin.y);
    _matrix.rotate(spinAngle * Math.PI / 180);
    matrix.scale(scale.x, scale.y);
    if (bakedRotationAngle <= 0)
    {
      updateTrig();
      if (angle != 0) matrix.rotateWithTrig(_cosAngle, _sinAngle);
    }
    if (skew.x != 0 || skew.y != 0)
    {
      updateSkew();
      _matrix.concat(FlxAnimate._skewMatrix);
      // _matrix.concat(_skewMatrix);
    }
    _matrix.scale(scaleX2, scaleY2);
    getScreenPosition(_point, camera);
    _point.x += origin.x - offset.x;
    _point.y += origin.y - offset.y;
    matrix.translate(_point.x, _point.y);
    if (isPixelPerfectRender(camera)) preparePixelPerfectMatrix(matrix);
    camera.drawPixels(frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
  }

  // Eh fuck it, throw this in here as well to avoid copying the draw code for zSprites (all this just for hurt notes to rotate properly lol)
  // ------------------------------------------------
  // A copy of scale which is applied AFTER rotation.
  // Used by certain modifiers like zoomX to mimick the effect of stretching the playfield on the x-axis WITHOUT being affected by the sprite angle
  public var scaleX2:Float = 1;
  public var scaleY2:Float = 1;

  // The velocity of the spin angle variable!
  public var spinVelocity:Float = 0;

  /**
   * The angle this sprite will be rotated by BEFORE any other transformations.
   */
  public var spinAngle:Float = 0.0;

  override function updateMotion(elapsed:Float):Void
  {
    var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(spinVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - spinVelocity);
    spinVelocity += velocityDelta;
    spinAngle += spinVelocity * elapsed;
    spinVelocity += velocityDelta;
    super.updateMotion(elapsed);
  }
}
