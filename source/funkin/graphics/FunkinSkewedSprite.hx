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

  /**
   * This sprites current skew!
   * Set with skew.x or skew.y
   */
  public var skew(default, null):FlxPoint = FlxPoint.get();

  /**
   * Tranformation matrix for this sprite.
   * Used only when matrixExposed is set to true
   */
  public var transformMatrix(default, null):Matrix = new Matrix();

  /**
   * Bool flag showing whether transformMatrix is used for rendering or not.
   * False by default, which means that transformMatrix isn't used for rendering
   */
  public var matrixExposed:Bool = false;

  /**
   * Internal helper matrix object. Used for rendering calculations when matrixExposed is set to false
   */
  var _skewMatrix:Matrix = new Matrix();

  override public function destroy():Void
  {
    skew = FlxDestroyUtil.put(skew);
    _skewMatrix = null;
    transformMatrix = null;
    tag = null;
    super.destroy();
  }

  override function drawComplex(camera:FlxCamera):Void
  {
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    _matrix.translate(-origin.x, -origin.y);
    _matrix.rotate(spinAngle * Math.PI / 180);
    _matrix.scale(scale.x, scale.y);

    if (matrixExposed)
    {
      _matrix.concat(transformMatrix);
    }
    else
    {
      if (bakedRotationAngle <= 0)
      {
        updateTrig();

        if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
      }

      updateSkewMatrix();
      _matrix.concat(_skewMatrix);
    }

    _matrix.scale(scaleX2, scaleY2);

    getScreenPosition(_point, camera).subtractPoint(offset);
    _point.add(origin.x, origin.y);
    _matrix.translate(_point.x, _point.y);
    if (isPixelPerfectRender(camera))
    {
      _matrix.tx = Math.round(_matrix.tx / this.scale.x) * this.scale.x;
      _matrix.ty = Math.round(_matrix.ty / this.scale.y) * this.scale.y;
    }
    camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
  }

  function updateSkewMatrix():Void
  {
    _skewMatrix.identity();

    if (skew.x != 0 || skew.y != 0)
    {
      _skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
      _skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
    }
  }

  override public function isSimpleRender(?camera:FlxCamera):Bool
  {
    if (FlxG.renderBlit)
    {
      return super.isSimpleRender(camera) && (skew.x == 0) && (skew.y == 0) && !matrixExposed;
    }
    else
    {
      return false;
    }
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
