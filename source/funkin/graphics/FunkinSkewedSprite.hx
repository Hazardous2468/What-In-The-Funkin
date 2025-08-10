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

/**
 * A FunkinSprite which implements FlxSkewedSprite, allowing this sprite to skew!
 * Original author of FlxSkewedSprite: Zaphod
 */
class FunkinSkewedSprite extends FunkinSprite
{
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
    super.destroy();
  }

  override function drawComplex(camera:FlxCamera):Void
  {
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    _matrix.translate(-origin.x, -origin.y);
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
}
