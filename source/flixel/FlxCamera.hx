package flixel;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.Vector;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.display.TriangleCulling;

using flixel.util.FlxColorTransformUtil;

private typedef FlxDrawItem = flixel.graphics.tile.FlxDrawQuadsItem;

/**
 * The camera class is used to display the game's visuals.
 * By default one camera is created automatically, that is the same size as window.
 * You can add more cameras or even replace the main camera using utilities in `FlxG.cameras`.
 *
 * Every camera has following display list:
 * `flashSprite:Sprite` (which is a container for everything else in the camera, it's added to FlxG.game sprite)
 *     |-> `_scrollRect:Sprite` (which is used for cropping camera's graphic, mostly in tile render mode)
 *         |-> `_flashBitmap:Bitmap`  (its bitmapData property is buffer BitmapData, this var is used in blit render mode.
 *                                    Everything is rendered on buffer in blit render mode)
 *         |-> `canvas:Sprite`        (its graphics is used for rendering objects in tile render mode)
 *         |-> `debugLayer:Sprite`    (this sprite is used in tile render mode for rendering debug info, like bounding boxes)
 *
 * Edited by Hazard24 to include: CullMode and Repeat for drawTriangles, as well as a scuffed fix for shaders breaking on game resize
 */
class FlxCamera extends FlxBasic
{
  /**
   * Any `FlxCamera` with a zoom of 0 (the default value) will have this zoom value.
   */
  public static var defaultZoom:Float = 1.0;

  /**
   * Used behind-the-scenes during the draw phase so that members use the same default
   * cameras as their parent.
   *
   * This is the non-deprecated list that the public `defaultCameras` proxies. Allows flixel classes
   * to use it without warning.
   */
  @:allow(flixel.FlxBasic.get_cameras)
  @:allow(flixel.FlxBasic.get_camera)
  @:allow(flixel.system.frontEnds.CameraFrontEnd)
  @:allow(flixel.group.FlxTypedGroup.draw)
  static var _defaultCameras:Array<FlxCamera>;

  /**
   * The X position of this camera's display. `zoom` does NOT affect this number.
   * Measured in pixels from the left side of the window.
   * You might be interested in using camera's `scroll.x` instead.
   */
  public var x(default, set):Float = 0;

  /**
   * The Y position of this camera's display. `zoom` does NOT affect this number.
   * Measured in pixels from the top of the window.
   * You might be interested in using camera's `scroll.y` instead.
   */
  public var y(default, set):Float = 0;

  /**
   * The scaling on horizontal axis for this camera.
   * Setting `scaleX` changes `scaleX` and x coordinate of camera's internal display objects.
   */
  public var scaleX(default, null):Float = 0;

  /**
   * The scaling on vertical axis for this camera.
   * Setting `scaleY` changes `scaleY` and y coordinate of camera's internal display objects.
   */
  public var scaleY(default, null):Float = 0;

  /**
   * Product of camera's `scaleX` and game's scale mode `scale.x` multiplication.
   */
  public var totalScaleX(default, null):Float;

  /**
   * Product of camera's scaleY and game's scale mode scale.y multiplication.
   */
  public var totalScaleY(default, null):Float;

  /**
   * Tells the camera to use this following style.
   */
  public var style:FlxCameraFollowStyle;

  /**
   * Tells the camera to follow this FlxObject object around.
   */
  public var target:FlxObject;

  /**
   * Offset the camera target.
   */
  public var targetOffset(default, null):FlxPoint = FlxPoint.get();

  /**
   * The ratio of the distance to the follow `target` the camera moves per 1/60 sec.
   * Valid values range from `0.0` to `1.0`. `1.0` means the camera always snaps to its target
   * position. `0.5` means the camera always travels halfway to the target position, `0.0` means
   * the camera does not move. Generally, the lower the value, the more smooth.
   */
  public var followLerp:Float = 1.0;

  /**
   * You can assign a "dead zone" to the camera in order to better control its movement.
   * The camera will always keep the focus object inside the dead zone, unless it is bumping up against
   * the camera bounds. The `deadzone`'s coordinates are measured from the camera's upper left corner in game pixels.
   * For rapid prototyping, you can use the preset deadzones (e.g. `PLATFORMER`) with `follow()`.
   */
  public var deadzone:FlxRect;

  /**
   * Lower bound of the camera's `scroll` on the x axis.
   */
  public var minScrollX:Null<Float>;

  /**
   * Upper bound of the camera's `scroll` on the x axis.
   */
  public var maxScrollX:Null<Float>;

  /**
   * Lower bound of the camera's `scroll` on the y axis.
   */
  public var minScrollY:Null<Float>;

  /**
   * Upper bound of the camera's `scroll` on the y axis.
   */
  public var maxScrollY:Null<Float>;

  /**
   * Stores the basic parallax scrolling values.
   * This is basically the camera's top-left corner position in world coordinates.
   * There is also `focusOn(point:FlxPoint)` which you can use to
   * make the camera look at specified point in world coordinates.
   */
  public var scroll:FlxPoint = FlxPoint.get();

  /**
   * The actual `BitmapData` of the camera display itself.
   * Used in blit render mode, where you can manipulate its pixels for achieving some visual effects.
   */
  public var buffer:BitmapData;

  /**
   * The natural background color of the camera, in `AARRGGBB` format. Defaults to `FlxG.cameras.bgColor`.
   * On Flash, transparent backgrounds can be used in conjunction with `useBgAlphaBlending`.
   */
  public var bgColor:FlxColor;

  /**
   * Sometimes it's easier to just work with a `FlxSprite`, than it is to work directly with the `BitmapData` buffer.
   * This sprite reference will allow you to do exactly that.
   * Basically, this sprite's `pixels` property is the camera's `BitmapData` buffer.
   *
   * **NOTE:** This field is only used in blit render mode.
   */
  public var screen:FlxSprite;

  /**
   * Whether to use alpha blending for the camera's background fill or not.
   * If `true`, then the previously drawn graphics won't be erased,
   * and if the camera's `bgColor` is transparent/semitransparent, then you
   * will be able to see the graphics of the previous frame.
   *
   * This is Useful for blit render mode (and only works in this mode).
   * Default value is `false`.
   */
  public var useBgAlphaBlending:Bool = false;

  /**
   * Used to render buffer to screen space.
   * NOTE: We don't recommend modifying this directly unless you are fairly experienced.
   * Uses include 3D projection, advanced display list modification, and more.
   * This is container for everything else that is used by camera and rendered to the camera.
   *
   * Its position is modified by `updateFlashSpritePosition()` which is called every frame.
   */
  public var flashSprite:Sprite = new Sprite();

  /**
   * Whether the positions of the objects rendered on this camera are rounded.
   * If set on individual objects, they ignore the global camera setting.
   * Defaults to `false` with `FlxG.renderTile` and to `true` with `FlxG.renderBlit`.
   * WARNING: setting this to `false` on blitting targets is very expensive.
   */
  public var pixelPerfectRender:Bool;

  /**
   * If true, screen shake will be rounded to game pixels. If null, pixelPerfectRender is used.
   * @since 5.4.0
   */
  public var pixelPerfectShake:Null<Bool> = null;

  /**
   * How wide the camera display is, in game pixels.
   */
  public var width(default, set):Int = 0;

  /**
   * How tall the camera display is, in game pixels.
   */
  public var height(default, set):Int = 0;

  /**
   * The zoom level of this camera. `1` = 1:1, `2` = 2x zoom, etc.
   * Indicates how far the camera is zoomed in.
   * Note: Changing this property from it's initial value will change properties like:
   * `viewX`, `viewY`, `viewWidth`, `viewHeight` and many others. Cameras always zoom in to
   * their center, meaning as you zoom in, the view is cut off on all sides.
   */
  public var zoom(default, set):Float;

  /**
   * The margin cut off on the left and right by the camera zooming in (or out), in world space.
   * @since 5.2.0
   */
  public var viewMarginX(default, null):Float;

  /**
   * The margin cut off on the top and bottom by the camera zooming in (or out), in world space.
   * @since 5.2.0
   */
  public var viewMarginY(default, null):Float;

  // delegates

  /**
   * The margin cut off on the left by the camera zooming in (or out), in world space.
   * @since 5.2.0
   */
  public var viewMarginLeft(get, never):Float;

  /**
   * The margin cut off on the top by the camera zooming in (or out), in world space
   * @since 5.2.0
   */
  public var viewMarginTop(get, never):Float;

  /**
   * The margin cut off on the right by the camera zooming in (or out), in world space
   * @since 5.2.0
   */
  public var viewMarginRight(get, never):Float;

  /**
   * The margin cut off on the bottom by the camera zooming in (or out), in world space
   * @since 5.2.0
   */
  public var viewMarginBottom(get, never):Float;

  /**
   * The size of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewWidth(get, never):Float;

  /**
   * The size of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewHeight(get, never):Float;

  /**
   * The left of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewX(get, never):Float;

  /**
   * The top of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewY(get, never):Float;

  /**
   * The left of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewLeft(get, never):Float;

  /**
   * The top of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewTop(get, never):Float;

  /**
   * The right side of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewRight(get, never):Float;

  /**
   * The bottom side of the camera's view, in world space.
   * @since 5.2.0
   */
  public var viewBottom(get, never):Float;

  /**
   * Helper matrix object. Used in blit render mode when camera's zoom is less than initialZoom
   * (it is applied to all objects rendered on the camera at such circumstances).
   */
  var _blitMatrix:FlxMatrix = new FlxMatrix();

  /**
   * Logical flag for tracking whether to apply _blitMatrix transformation to objects or not.
   */
  var _useBlitMatrix:Bool = false;

  /**
   * The alpha value of this camera display (a number between `0.0` and `1.0`).
   */
  public var alpha(default, set):Float = 1;

  /**
   * The angle of the camera display (in degrees).
   */
  public var angle(default, set):Float = 0;

  /**
   * The color tint of the camera display.
   */
  public var color(default, set):FlxColor = FlxColor.WHITE;

  /**
   * Whether the camera display is smooth and filtered, or chunky and pixelated.
   * Default behavior is chunky-style.
   */
  public var antialiasing(default, set):Bool = false;

  /**
   * Used to force the camera to look ahead of the target.
   */
  public var followLead(default, null):FlxPoint = FlxPoint.get();

  /**
   * Enables or disables the filters set via `setFilters()`.
   */
  public var filtersEnabled:Bool = true;

  /**
   * Internal, used in blit render mode in camera's `fill()` method for less garbage creation.
   * It represents the size of buffer `BitmapData`
   * (the area of camera's buffer which should be filled with `bgColor`).
   * Do not modify it unless you know what are you doing.
   */
  var _flashRect:Rectangle;

  /**
   * Internal, used in blit render mode in camera's `fill()` method for less garbage creation:
   * Its coordinates are always `(0,0)`, where camera's buffer filling should start.
   * Do not modify it unless you know what are you doing.
   */
  var _flashPoint:Point = new Point();

  /**
   * Internal, used for positioning camera's `flashSprite` on screen.
   * Basically it represents position of camera's center point in game sprite.
   * It's recalculated every time you resize game or camera.
   * Its value depends on camera's size (`width` and `height`), game's `scale` and camera's initial zoom factor.
   * Do not modify it unless you know what are you doing.
   */
  var _flashOffset:FlxPoint = FlxPoint.get();

  /**
   * Internal, represents the color of `flash()` special effect.
   */
  var _fxFlashColor:FlxColor = FlxColor.TRANSPARENT;

  /**
   * Internal, stores `flash()` special effect duration.
   */
  var _fxFlashDuration:Float = 0;

  /**
   * Internal, camera's `flash()` complete callback.
   */
  var _fxFlashComplete:Void->Void = null;

  /**
   * Internal, used to control the `flash()` special effect.
   */
  var _fxFlashAlpha:Float = 0;

  /**
   * Internal, color of fading special effect.
   */
  var _fxFadeColor:FlxColor = FlxColor.TRANSPARENT;

  /**
   * Used to calculate the following target current velocity.
   */
  var _lastTargetPosition:FlxPoint;

  /**
   * Helper to calculate follow target current scroll.
   */
  var _scrollTarget:FlxPoint = FlxPoint.get();

  /**
   * Internal, `fade()` special effect duration.
   */
  var _fxFadeDuration:Float = 0;

  /**
   * Internal, "direction" of the `fade()` effect.
   * `true` means that camera fades from a color, `false` - camera fades to it.
   */
  var _fxFadeIn:Bool = false;

  /**
   * Internal, used to control the `fade()` special effect complete callback.
   */
  var _fxFadeComplete:Void->Void = null;

  /**
   * Internal, alpha component of fade color.
   * Changes from 0 to 1 or from 1 to 0 as the effect continues.
   */
  var _fxFadeAlpha:Float = 0;

  /**
   * Internal, percentage of screen size representing the maximum distance that the screen can move while shaking.
   */
  var _fxShakeIntensity:Float = 0;

  /**
   * Internal, duration of the `shake()` effect.
   */
  var _fxShakeDuration:Float = 0;

  /**
   * Internal, `shake()` effect complete callback.
   */
  var _fxShakeComplete:Void->Void;

  /**
   * Internal, defines on what axes to `shake()`. Default value is `XY` / both.
   */
  var _fxShakeAxes:FlxAxes = XY;

  /**
   * Internal, used for repetitive calculations and added to help avoid costly allocations.
   */
  var _point:FlxPoint = FlxPoint.get();

  /**
   * The filters array to be applied to the camera.
   */
  public var filters:Null<Array<BitmapFilter>> = null;

  /**
   * Camera's initial zoom value. Used for camera's scale handling.
   */
  public var initialZoom(default, null):Float = 1;

  /**
   * Internal helper variable for doing better wipes/fills between renders.
   * Used it blit render mode only (in `fill()` method).
   */
  var _fill:BitmapData;

  /**
   * Internal, used to render buffer to screen space. Used it blit render mode only.
   * This Bitmap used for rendering camera's buffer (`_flashBitmap.bitmapData = buffer;`)
   * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
   * It is a child of the `_scrollRect` `Sprite`.
   */
  var _flashBitmap:Bitmap;

  /**
   * Internal sprite, used for correct trimming of camera viewport.
   * It is a child of `flashSprite`.
   * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
   */
  var _scrollRect:Sprite = new Sprite();

  /**
   * Helper rect for `drawTriangles()` visibility checks
   */
  var _bounds:FlxRect = FlxRect.get();

  /**
   * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
   * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
   * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
   * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
   */
  public var canvas:Sprite;

  #if FLX_DEBUG
  /**
   * Sprite for visual effects (flash and fade) and drawDebug information
   * (bounding boxes are drawn on it) for tile render mode.
   * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
   * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
   */
  public var debugLayer:Sprite;
  #end

  var _helperMatrix:FlxMatrix = new FlxMatrix();

  var _helperPoint:Point = new Point();

  /**
   * Currently used draw stack item
   */
  var _currentDrawItem:FlxDrawBaseItem<Dynamic>;

  /**
   * Pointer to head of stack with draw items
   */
  var _headOfDrawStack:FlxDrawBaseItem<Dynamic>;

  /**
   * Last draw tiles item
   */
  var _headTiles:FlxDrawItem;

  /**
   * Last draw triangles item
   */
  var _headTriangles:FlxDrawTrianglesItem;

  /**
   * Draw tiles stack items that can be reused
   */
  static var _storageTilesHead:FlxDrawItem;

  /**
   * Draw triangles stack items that can be reused
   */
  static var _storageTrianglesHead:FlxDrawTrianglesItem;

  /**
   * Internal variable, used for visibility checks to minimize `drawTriangles()` calls.
   */
  static var drawVertices:Vector<Float> = new Vector<Float>();

  /**
   * Internal variable, used in blit render mode to render triangles (`drawTriangles()`) on camera's buffer.
   */
  static var trianglesSprite:Sprite = new Sprite();

  /**
   * Internal variables, used in blit render mode to draw trianglesSprite on camera's buffer.
   * Added for less garbage creation.
   */
  static var renderPoint:FlxPoint = FlxPoint.get();

  static var renderRect:FlxRect = FlxRect.get();

  @:noCompletion
  public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false, ?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
  {
    #if FLX_RENDER_TRIANGLE
    return startTrianglesBatch(graphic, smooth, colored, blend);
    #else
    var itemToReturn = null;
    var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);

    if (_currentDrawItem != null
      && _currentDrawItem.type == FlxDrawItemType.TILES
      && _headTiles.graphics == graphic
      && _headTiles.colored == colored
      && _headTiles.hasColorOffsets == hasColorOffsets
      && _headTiles.blending == blendInt
      && _headTiles.blend == blend
      && _headTiles.antialiasing == smooth
      && _headTiles.shader == shader)
    {
      return _headTiles;
    }

    if (_storageTilesHead != null)
    {
      itemToReturn = _storageTilesHead;
      var newHead = _storageTilesHead.nextTyped;
      itemToReturn.reset();
      _storageTilesHead = newHead;
    }
    else
    {
      itemToReturn = new FlxDrawItem();
    }

    // TODO: catch this error when the dev actually messes up, not in the draw phase
    if (graphic.isDestroyed) throw 'Attempted to queue an invalid FlxDrawItem, did you destroy a cached sprite?';

    itemToReturn.graphics = graphic;
    itemToReturn.antialiasing = smooth;
    itemToReturn.colored = colored;
    itemToReturn.hasColorOffsets = hasColorOffsets;
    itemToReturn.blending = blendInt;
    itemToReturn.blend = blend;
    itemToReturn.shader = shader;

    itemToReturn.nextTyped = _headTiles;
    _headTiles = itemToReturn;

    if (_headOfDrawStack == null)
    {
      _headOfDrawStack = itemToReturn;
    }

    if (_currentDrawItem != null)
    {
      _currentDrawItem.next = itemToReturn;
    }

    _currentDrawItem = itemToReturn;

    return itemToReturn;
    #end
  }

  @:noCompletion
  public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool,
      ?shader:FlxShader, ?cullMode:TriangleCulling, repeat:Bool = true):FlxDrawTrianglesItem
  {
    var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);

    if (_currentDrawItem != null
      && _currentDrawItem.type == FlxDrawItemType.TRIANGLES
      && _headTriangles.graphics == graphic
      && _headTriangles.antialiasing == smoothing
      && _headTriangles.colored == isColored
      && _headTriangles.cullMode == cullMode
      && _headTriangles.blending == blendInt
      && _headTriangles.blend == blend #if !flash
      && _headTriangles.hasColorOffsets == hasColorOffsets
      && _headTriangles.shader == shader #end
    )
    {
      return _headTriangles;
    }

    return getNewDrawTrianglesItem(graphic, smoothing, isColored, blend, hasColorOffsets, shader, cullMode, repeat);
  }

  @:noCompletion
  public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool,
      ?shader:FlxShader, ?cullMode:TriangleCulling, repeat:Bool = true):FlxDrawTrianglesItem
  {
    var itemToReturn:FlxDrawTrianglesItem = null;
    var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);

    if (_storageTrianglesHead != null)
    {
      itemToReturn = _storageTrianglesHead;
      var newHead:FlxDrawTrianglesItem = _storageTrianglesHead.nextTyped;
      itemToReturn.reset();
      _storageTrianglesHead = newHead;
    }
    else
    {
      itemToReturn = new FlxDrawTrianglesItem();
    }

    itemToReturn.graphics = graphic;
    itemToReturn.antialiasing = smoothing;
    itemToReturn.colored = isColored;
    itemToReturn.cullMode = cullMode;
    itemToReturn.repeat = repeat;
    itemToReturn.blending = blendInt;
    itemToReturn.blend = blend;
    #if !flash
    itemToReturn.hasColorOffsets = hasColorOffsets;
    itemToReturn.shader = shader;
    #end

    itemToReturn.nextTyped = _headTriangles;
    _headTriangles = itemToReturn;

    if (_headOfDrawStack == null)
    {
      _headOfDrawStack = itemToReturn;
    }

    if (_currentDrawItem != null)
    {
      _currentDrawItem.next = itemToReturn;
    }

    _currentDrawItem = itemToReturn;

    return itemToReturn;
  }

  @:allow(flixel.system.frontEnds.CameraFrontEnd)
  function clearDrawStack():Void
  {
    var currTiles = _headTiles;
    var newTilesHead;

    while (currTiles != null)
    {
      newTilesHead = currTiles.nextTyped;
      currTiles.reset();
      currTiles.nextTyped = _storageTilesHead;
      _storageTilesHead = currTiles;
      currTiles = newTilesHead;
    }

    var currTriangles:FlxDrawTrianglesItem = _headTriangles;
    var newTrianglesHead:FlxDrawTrianglesItem;

    while (currTriangles != null)
    {
      newTrianglesHead = currTriangles.nextTyped;
      currTriangles.reset();
      currTriangles.nextTyped = _storageTrianglesHead;
      _storageTrianglesHead = currTriangles;
      currTriangles = newTrianglesHead;
    }

    _currentDrawItem = null;
    _headOfDrawStack = null;
    _headTiles = null;
    _headTriangles = null;
  }

  @:allow(flixel.system.frontEnds.CameraFrontEnd)
  function render():Void
  {
    var currItem:FlxDrawBaseItem<Dynamic> = _headOfDrawStack;
    while (currItem != null)
    {
      currItem.render(this);
      currItem = currItem.next;
    }
  }

  public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
      ?shader:FlxShader):Void
  {
    if (FlxG.renderBlit)
    {
      _helperMatrix.copyFrom(matrix);

      if (_useBlitMatrix)
      {
        _helperMatrix.concat(_blitMatrix);
        buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
      }
      else
      {
        _helperMatrix.translate(-viewMarginLeft, -viewMarginTop);
        buffer.draw(pixels, _helperMatrix, null, blend, null, (smoothing || antialiasing));
      }
    }
    else
    {
      var isColored = (transform != null && transform.hasRGBMultipliers());
      var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());

      #if FLX_RENDER_TRIANGLE
      var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
      #else
      var drawItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
      #end
      drawItem.addQuad(frame, matrix, transform);
    }
  }

  public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
      ?smoothing:Bool = false, ?shader:FlxShader):Void
  {
    if (FlxG.renderBlit)
    {
      if (pixels != null)
      {
        if (_useBlitMatrix)
        {
          _helperMatrix.identity();
          _helperMatrix.translate(destPoint.x, destPoint.y);
          _helperMatrix.concat(_blitMatrix);
          buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
        }
        else
        {
          _helperPoint.x = destPoint.x - Std.int(viewMarginLeft);
          _helperPoint.y = destPoint.y - Std.int(viewMarginTop);
          buffer.copyPixels(pixels, sourceRect, _helperPoint, null, null, true);
        }
      }
      else if (frame != null)
      {
        // TODO: fix this case for zoom less than initial zoom...
        frame.paint(buffer, destPoint, true);
      }
    }
    else
    {
      _helperMatrix.identity();
      _helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);

      var isColored = (transform != null && transform.hasRGBMultipliers());
      var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());

      #if !FLX_RENDER_TRIANGLE
      var drawItem = startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
      #else
      var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(frame.parent, smoothing, isColored, blend);
      #end
      drawItem.addQuad(frame, _helperMatrix, transform);
    }
  }

  public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
      ?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader,
      ?cullMode:TriangleCulling):Void
  {
    if (FlxG.renderBlit)
    {
      if (position == null) position = renderPoint.set();

      _bounds.set(0, 0, width, height);

      var verticesLength:Int = vertices.length;
      var currentVertexPosition:Int = 0;

      var tempX:Float, tempY:Float;
      var i:Int = 0;
      var bounds = renderRect.set();
      drawVertices.splice(0, drawVertices.length);

      while (i < verticesLength)
      {
        tempX = position.x + vertices[i];
        tempY = position.y + vertices[i + 1];

        drawVertices[currentVertexPosition++] = tempX;
        drawVertices[currentVertexPosition++] = tempY;

        if (i == 0)
        {
          bounds.set(tempX, tempY, 0, 0);
        }
        else
        {
          FlxDrawTrianglesItem.inflateBounds(bounds, tempX, tempY);
        }

        i += 2;
      }

      position.putWeak();

      if (!_bounds.overlaps(bounds))
      {
        drawVertices.splice(drawVertices.length - verticesLength, verticesLength);
      }
      else
      {
        trianglesSprite.graphics.clear();
        trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, repeat, smoothing);
        trianglesSprite.graphics.drawTriangles(drawVertices, indices, uvtData);
        trianglesSprite.graphics.endFill();

        // TODO: check this block of code for cases, when zoom < 1 (or initial zoom?)...
        if (_useBlitMatrix) _helperMatrix.copyFrom(_blitMatrix);
        else
        {
          _helperMatrix.identity();
          _helperMatrix.translate(-viewMarginLeft, -viewMarginTop);
        }

        buffer.draw(trianglesSprite, _helperMatrix);
        #if FLX_DEBUG
        if (FlxG.debugger.drawDebug)
        {
          var gfx:Graphics = FlxSpriteUtil.flashGfx;
          gfx.clear();
          gfx.lineStyle(1, FlxColor.BLUE, 0.5);
          gfx.drawTriangles(drawVertices, indices);
          buffer.draw(FlxSpriteUtil.flashGfxSprite, _helperMatrix);
        }
        #end
        // End of TODO...
      }

      bounds.put();
    }
    else
    {
      _bounds.set(0, 0, width, height);
      var isColored:Bool = (colors != null && colors.length != 0);

      #if !flash
      var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
      isColored = isColored || (transform != null && transform.hasRGBMultipliers());
      var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader, cullMode, repeat);
      drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds, transform);
      #else
      var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend, cullMode, repeat);
      drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds);
      #end
    }
  }

  /**
   * Helper method preparing debug rectangle for rendering in blit render mode
   * @param	rect	rectangle to prepare for rendering
   * @return	transformed rectangle with respect to camera's zoom factor
   */
  function transformRect(rect:FlxRect):FlxRect
  {
    if (FlxG.renderBlit)
    {
      rect.offset(-viewMarginLeft, -viewMarginTop);

      if (_useBlitMatrix)
      {
        rect.x *= zoom;
        rect.y *= zoom;
        rect.width *= zoom;
        rect.height *= zoom;
      }
    }

    return rect;
  }

  /**
   * Helper method preparing debug point for rendering in blit render mode (for debug path rendering, for example)
   * @param	point		point to prepare for rendering
   * @return	transformed point with respect to camera's zoom factor
   */
  function transformPoint(point:FlxPoint):FlxPoint
  {
    if (FlxG.renderBlit)
    {
      point.subtract(viewMarginLeft, viewMarginTop);

      if (_useBlitMatrix) point.scale(zoom);
    }

    return point;
  }

  /**
   * Helper method preparing debug vectors (relative positions) for rendering in blit render mode
   * @param	vector	relative position to prepare for rendering
   * @return	transformed vector with respect to camera's zoom factor
   */
  inline function transformVector(vector:FlxPoint):FlxPoint
  {
    if (FlxG.renderBlit && _useBlitMatrix) vector.scale(zoom);

    return vector;
  }

  /**
   * Helper method for applying transformations (scaling and offsets)
   * to specified display objects which has been added to the camera display list.
   * For example, debug sprite for nape debug rendering.
   * @param	object	display object to apply transformations to.
   * @return	transformed object.
   */
  function transformObject(object:DisplayObject):DisplayObject
  {
    object.scaleX *= totalScaleX;
    object.scaleY *= totalScaleY;

    object.x -= scroll.x * totalScaleX;
    object.y -= scroll.y * totalScaleY;

    object.x -= 0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
    object.y -= 0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;

    return object;
  }

  /**
   * Instantiates a new camera at the specified location, with the specified size and zoom level.
   *
   * @param   x       X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
   * @param   y       Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
   * @param   width   The width of the camera display in pixels.
   * @param   height  The height of the camera display in pixels.
   * @param   zoom    The initial zoom level of the camera.
   *                  A zoom level of 2 will make all pixels display at 2x resolution.
   */
  public function new(x = 0.0, y = 0.0, width = 0, height = 0, zoom = 0.0)
  {
    super();

    this.x = x;
    this.y = y;

    if (zoom == 0) zoom = defaultZoom;

    // Use the game dimensions if width / height are <= 0
    this.width = width <= 0 ? Math.ceil(FlxG.width / zoom) : width;
    this.height = height <= 0 ? Math.ceil(FlxG.height / zoom) : height;
    _flashRect = new Rectangle(0, 0, width, height);

    flashSprite.addChild(_scrollRect);
    _scrollRect.scrollRect = new Rectangle();

    pixelPerfectRender = FlxG.renderBlit;

    if (FlxG.renderBlit)
    {
      screen = new FlxSprite();
      buffer = new BitmapData(width, height, true, 0);
      screen.pixels = buffer;
      screen.origin.set();
      _flashBitmap = new Bitmap(buffer);
      _scrollRect.addChild(_flashBitmap);
      _fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
    }
    else
    {
      canvas = new Sprite();
      _scrollRect.addChild(canvas);

      #if FLX_DEBUG
      debugLayer = new Sprite();
      _scrollRect.addChild(debugLayer);
      #end
    }

    set_color(FlxColor.WHITE);

    // sets the scale of flash sprite, which in turn loads flashOffset values
    this.zoom = initialZoom = zoom;

    updateScrollRect();
    updateFlashOffset();
    updateFlashSpritePosition();
    updateInternalSpritePositions();

    bgColor = FlxG.cameras.bgColor;
  }

  /**
   * Clean up memory.
   */
  override public function destroy():Void
  {
    FlxDestroyUtil.removeChild(flashSprite, _scrollRect);

    if (FlxG.renderBlit)
    {
      FlxDestroyUtil.removeChild(_scrollRect, _flashBitmap);
      screen = FlxDestroyUtil.destroy(screen);
      buffer = null;
      _flashBitmap = null;
      _fill = FlxDestroyUtil.dispose(_fill);
    }
    else
    {
      #if FLX_DEBUG
      FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
      debugLayer = null;
      #end

      FlxDestroyUtil.removeChild(_scrollRect, canvas);
      if (canvas != null)
      {
        for (i in 0...canvas.numChildren)
        {
          canvas.removeChildAt(0);
        }
        canvas = null;
      }

      if (_headOfDrawStack != null)
      {
        clearDrawStack();
      }

      _blitMatrix = null;
      _helperMatrix = null;
      _helperPoint = null;
    }

    _bounds = null;
    scroll = FlxDestroyUtil.put(scroll);
    targetOffset = FlxDestroyUtil.put(targetOffset);
    deadzone = FlxDestroyUtil.put(deadzone);

    target = null;
    flashSprite = null;
    _scrollRect = null;
    _flashRect = null;
    _flashPoint = null;
    _fxFlashComplete = null;
    _fxFadeComplete = null;
    _fxShakeComplete = null;

    super.destroy();
  }

  /**
   * Sets the filter array to be applied to the camera.
   */
  @:deprecated("setFilters() is deprecated, use the filters array instead")
  public function setFilters(filters:Array<BitmapFilter>):Void
  {
    this.filters = filters;
  }

  // When set to true, will instantly remove all filters and reapply them 1 frame later.
  public var filterRefresh:Bool = false;

  /**
   * Updates the camera scroll as well as special effects like screen-shake or fades.
   */
  override public function update(elapsed:Float):Void
  {
    // follow the target, if there is one
    if (target != null)
    {
      updateFollow();
      updateLerp(elapsed);
    }

    updateScroll();
    updateFlash(elapsed);
    updateFade(elapsed);

    if (filterRefresh)
    {
      // trace("Window resized, reapplying shaders!");
      flashSprite.filters = [];
      filterRefresh = false;
    }
    else
    {
      flashSprite.filters = filtersEnabled ? filters : null;
    }

    updateFlashSpritePosition();
    updateShake(elapsed);
  }

  /**
   * Updates (bounds) the camera scroll.
   * Called every frame by camera's `update()` method.
   */
  public function updateScroll():Void
  {
    // Make sure we didn't go outside the camera's bounds
    bindScrollPos(scroll);
  }

  /**
   * Takes the desired scroll position and restricts it to the camera's min/max scroll properties.
   * This modifies the given point.
   *
   * @param   scrollPos  The scroll position
   * @return  The same point passed in, moved within the scroll bounds
   * @since 5.4.0
   */
  public function bindScrollPos(scrollPos:FlxPoint)
  {
    final minX:Null<Float> = minScrollX == null ? null : minScrollX - viewMarginLeft;
    final maxX:Null<Float> = maxScrollX == null ? null : maxScrollX - viewMarginRight;
    final minY:Null<Float> = minScrollY == null ? null : minScrollY - viewMarginTop;
    final maxY:Null<Float> = maxScrollY == null ? null : maxScrollY - viewMarginBottom;

    // keep point within bounds
    scrollPos.x = FlxMath.bound(scrollPos.x, minX, maxX);
    scrollPos.y = FlxMath.bound(scrollPos.y, minY, maxY);
    return scrollPos;
  }

  /**
   * Updates camera's scroll.
   * Called every frame by camera's `update()` method (if camera's `target` isn't `null`).
   */
  function updateFollow():Void
  {
    // Either follow the object closely,
    // or double check our deadzone and update accordingly.
    if (deadzone == null)
    {
      target.getMidpoint(_point);
      _point.add(targetOffset);
      _scrollTarget.set(_point.x - width * 0.5, _point.y - height * 0.5);
    }
    else
    {
      var edge:Float;
      var targetX:Float = target.x + targetOffset.x;
      var targetY:Float = target.y + targetOffset.y;

      if (style == SCREEN_BY_SCREEN)
      {
        if (targetX >= viewRight)
        {
          _scrollTarget.x += viewWidth;
        }
        else if (targetX + target.width < viewLeft)
        {
          _scrollTarget.x -= viewWidth;
        }

        if (targetY >= viewBottom)
        {
          _scrollTarget.y += viewHeight;
        }
        else if (targetY + target.height < viewTop)
        {
          _scrollTarget.y -= viewHeight;
        }

        // without this we see weird behavior when switching to SCREEN_BY_SCREEN at arbitrary scroll positions
        bindScrollPos(_scrollTarget);
      }
      else
      {
        edge = targetX - deadzone.x;
        if (_scrollTarget.x > edge)
        {
          _scrollTarget.x = edge;
        }
        edge = targetX + target.width - deadzone.x - deadzone.width;
        if (_scrollTarget.x < edge)
        {
          _scrollTarget.x = edge;
        }

        edge = targetY - deadzone.y;
        if (_scrollTarget.y > edge)
        {
          _scrollTarget.y = edge;
        }
        edge = targetY + target.height - deadzone.y - deadzone.height;
        if (_scrollTarget.y < edge)
        {
          _scrollTarget.y = edge;
        }
      }

      if ((target is FlxSprite))
      {
        if (_lastTargetPosition == null)
        {
          _lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
        }
        _scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
        _scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

        _lastTargetPosition.x = target.x;
        _lastTargetPosition.y = target.y;
      }
    }
  }

  function updateLerp(elapsed:Float)
  {
    if (followLerp >= 1.0)
    {
      scroll.copyFrom(_scrollTarget); // no easing
    }
    else if (followLerp > 0.0)
    {
      // Adjust lerp based on the current frame rate so lerp is less framerate dependant
      final adjustedLerp = 1.0 - Math.pow(1.0 - followLerp, elapsed * 60);

      scroll.x += (_scrollTarget.x - scroll.x) * adjustedLerp;
      scroll.y += (_scrollTarget.y - scroll.y) * adjustedLerp;
    }
  }

  function updateFlash(elapsed:Float):Void
  {
    // Update the "flash" special effect
    if (_fxFlashAlpha > 0.0)
    {
      _fxFlashAlpha -= elapsed / _fxFlashDuration;
      if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
      {
        _fxFlashComplete();
      }
    }
  }

  function updateFade(elapsed:Float):Void
  {
    if (_fxFadeDuration == 0.0) return;

    if (_fxFadeIn)
    {
      _fxFadeAlpha -= elapsed / _fxFadeDuration;
      if (_fxFadeAlpha <= 0.0)
      {
        _fxFadeAlpha = 0.0;
        completeFade();
      }
    }
    else
    {
      _fxFadeAlpha += elapsed / _fxFadeDuration;
      if (_fxFadeAlpha >= 1.0)
      {
        _fxFadeAlpha = 1.0;
        completeFade();
      }
    }
  }

  function completeFade()
  {
    _fxFadeDuration = 0.0;
    if (_fxFadeComplete != null) _fxFadeComplete();
  }

  function updateShake(elapsed:Float):Void
  {
    if (_fxShakeDuration > 0)
    {
      _fxShakeDuration -= elapsed;
      if (_fxShakeDuration <= 0)
      {
        if (_fxShakeComplete != null)
        {
          _fxShakeComplete();
        }
      }
      else
      {
        final pixelPerfect = pixelPerfectShake == null ? pixelPerfectRender : pixelPerfectShake;
        if (_fxShakeAxes.x)
        {
          var shakePixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * width;
          if (pixelPerfect) shakePixels = Math.round(shakePixels);

          flashSprite.x += shakePixels * zoom * FlxG.scaleMode.scale.x;
        }

        if (_fxShakeAxes.y)
        {
          var shakePixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * height;
          if (pixelPerfect) shakePixels = Math.round(shakePixels);

          flashSprite.y += shakePixels * zoom * FlxG.scaleMode.scale.y;
        }
      }
    }
  }

  /**
   * Recalculates `flashSprite` position.
   * Called every frame by camera's `update()` method and every time you change camera's position.
   */
  function updateFlashSpritePosition():Void
  {
    if (flashSprite != null)
    {
      flashSprite.x = x * FlxG.scaleMode.scale.x + _flashOffset.x;
      flashSprite.y = y * FlxG.scaleMode.scale.y + _flashOffset.y;
    }
  }

  /**
   * Recalculates `_flashOffset` point, which is used for positioning flashSprite in the game.
   * It's called every time you resize the camera or the game.
   */
  function updateFlashOffset():Void
  {
    _flashOffset.x = width * 0.5 * FlxG.scaleMode.scale.x * initialZoom;
    _flashOffset.y = height * 0.5 * FlxG.scaleMode.scale.y * initialZoom;
  }

  /**
   * Updates `_scrollRect` sprite to crop graphics of the camera:
   * 1) `scrollRect` property of this sprite
   * 2) position of this sprite inside `flashSprite`
   *
   * It takes camera's size and game's scale into account.
   * It's called every time you resize the camera or the game.
   */
  function updateScrollRect():Void
  {
    var rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;

    if (rect != null)
    {
      rect.x = rect.y = 0;

      rect.width = width * initialZoom * FlxG.scaleMode.scale.x;
      rect.height = height * initialZoom * FlxG.scaleMode.scale.y;

      _scrollRect.scrollRect = rect;

      _scrollRect.x = -0.5 * rect.width;
      _scrollRect.y = -0.5 * rect.height;
    }
  }

  /**
   * Modifies position of `_flashBitmap` in blit render mode and `canvas` and `debugSprite`
   * in tile render mode (these objects are children of `_scrollRect` sprite).
   * It takes camera's size and game's scale into account.
   * It's called every time you resize the camera or the game.
   */
  function updateInternalSpritePositions():Void
  {
    if (FlxG.renderBlit)
    {
      if (_flashBitmap != null)
      {
        _flashBitmap.x = 0;
        _flashBitmap.y = 0;
      }
    }
    else
    {
      if (canvas != null)
      {
        canvas.x = -0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
        canvas.y = -0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;

        canvas.scaleX = totalScaleX;
        canvas.scaleY = totalScaleY;

        #if FLX_DEBUG
        if (debugLayer != null)
        {
          debugLayer.x = canvas.x;
          debugLayer.y = canvas.y;

          debugLayer.scaleX = totalScaleX;
          debugLayer.scaleY = totalScaleY;
        }
        #end
      }
    }
  }

  /**
   * Tells this camera object what `FlxObject` to track.
   *
   * @param   target   The object you want the camera to track. Set to `null` to not follow anything.
   * @param   style    Leverage one of the existing "deadzone" presets. Default is `LOCKON`.
   *                   If you use a custom deadzone, ignore this parameter and
   *                   manually specify the deadzone after calling `follow()`.
   * @param   lerp     How much lag the camera should have (can help smooth out the camera movement).
   */
  public function follow(target:FlxObject, style = LOCKON, lerp = 1.0):Void
  {
    this.style = style;
    this.target = target;
    followLerp = lerp;
    _lastTargetPosition = FlxDestroyUtil.put(_lastTargetPosition);
    deadzone = FlxDestroyUtil.put(deadzone);

    switch (style)
    {
      case LOCKON:
        var w:Float = 0;
        var h:Float = 0;
        if (target != null)
        {
          w = target.width;
          h = target.height;
        }
        deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);

      case PLATFORMER:
        final w:Float = (width / 8);
        final h:Float = (height / 3);
        deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);

      case TOPDOWN:
        final helper = Math.max(width, height) / 4;
        deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);

      case TOPDOWN_TIGHT:
        final helper = Math.max(width, height) / 8;
        deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);

      case SCREEN_BY_SCREEN:
        deadzone = FlxRect.get(0, 0, width, height);

      case NO_DEAD_ZONE:
        deadzone = null;
    }
  }

  /**
   * Snaps the camera to the current `target`. Useful to move the camera without
   * any easing when the `target` position changes and there is a `followLerp`.
   */
  public function snapToTarget():Void
  {
    updateFollow();
    scroll.copyFrom(_scrollTarget);
  }

  /**
   * Move the camera focus to this location instantly.
   *
   * @param   Point   Where you want the camera to focus.
   */
  public inline function focusOn(point:FlxPoint):Void
  {
    scroll.set(point.x - width * 0.5, point.y - height * 0.5);
    point.putWeak();
  }

  /**
   * The screen is filled with this color and gradually returns to normal.
   *
   * @param   Color        The color you want to use.
   * @param   Duration     How long it takes for the flash to fade.
   * @param   OnComplete   A function you want to run when the flash finishes.
   * @param   Force        Force the effect to reset.
   */
  public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
  {
    if (!Force && (_fxFlashAlpha > 0.0)) return;

    _fxFlashColor = Color;
    if (Duration <= 0) Duration = 0.000001;
    _fxFlashDuration = Duration;
    _fxFlashComplete = OnComplete;
    _fxFlashAlpha = 1.0;
  }

  /**
   * The screen is gradually filled with this color.
   *
   * @param   Color        The color you want to use.
   * @param   Duration     How long it takes for the fade to finish.
   * @param   FadeIn       `true` fades from a color, `false` fades to it.
   * @param   OnComplete   A function you want to run when the fade finishes.
   * @param   Force        Force the effect to reset.
   */
  public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
  {
    if (_fxFadeDuration > 0 && !Force) return;

    _fxFadeColor = Color;
    if (Duration <= 0) Duration = 0.000001;

    _fxFadeIn = FadeIn;
    _fxFadeDuration = Duration;
    _fxFadeComplete = OnComplete;

    _fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
  }

  /**
   * A simple screen-shake effect.
   *
   * @param   Intensity    Percentage of screen size representing the maximum distance
   *                       that the screen can move while shaking.
   * @param   Duration     The length in seconds that the shaking effect should last.
   * @param   OnComplete   A function you want to run when the shake effect finishes.
   * @param   Force        Force the effect to reset (default = `true`, unlike `flash()` and `fade()`!).
   * @param   Axes         On what axes to shake. Default value is `FlxAxes.XY` / both.
   */
  public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Axes:FlxAxes):Void
  {
    if (Axes == null) Axes = XY;

    if (!Force && _fxShakeDuration > 0) return;

    _fxShakeIntensity = Intensity;
    _fxShakeDuration = Duration;
    _fxShakeComplete = OnComplete;
    _fxShakeAxes = Axes;
  }

  /**
   * Stops the fade effect on `this` camera.
   */
  public function stopFade():Void
  {
    _fxFadeAlpha = 0.0;
    _fxFadeDuration = 0.0;
  }

  /**
   * Stops the flash effect on `this` camera.
   */
  public function stopFlash():Void
  {
    _fxFlashAlpha = 0.0;
    updateFlashSpritePosition();
  }

  /**
   * Stops the shake effect on `this` camera.
   */
  public function stopShake():Void
  {
    _fxShakeDuration = 0.0;
  }

  /**
   * Stops all effects on `this` camera.
   */
  public function stopFX():Void
  {
    _fxFadeAlpha = 0.0;
    _fxFadeDuration = 0.0;
    _fxFlashAlpha = 0.0;
    updateFlashSpritePosition();
    _fxShakeDuration = 0.0;
  }

  /**
   * Copy the bounds, focus object, and `deadzone` info from an existing camera.
   *
   * @param   Camera  The camera you want to copy from.
   * @return  A reference to this `FlxCamera` object.
   */
  public function copyFrom(Camera:FlxCamera):FlxCamera
  {
    setScrollBounds(Camera.minScrollX, Camera.maxScrollX, Camera.minScrollY, Camera.maxScrollY);

    target = Camera.target;

    if (target != null)
    {
      if (Camera.deadzone == null)
      {
        deadzone = null;
      }
      else
      {
        if (deadzone == null)
        {
          deadzone = FlxRect.get();
        }
        deadzone.copyFrom(Camera.deadzone);
      }
    }
    return this;
  }

  /**
   * Fill the camera with the specified color.
   *
   * @param   Color        The color to fill with in `0xAARRGGBB` hex format.
   * @param   BlendAlpha   Whether to blend the alpha value or just wipe the previous contents. Default is `true`.
   */
  public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, ?graphics:Graphics):Void
  {
    if (FlxG.renderBlit)
    {
      if (BlendAlpha)
      {
        _fill.fillRect(_flashRect, Color);
        buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
      }
      else
      {
        buffer.fillRect(_flashRect, Color);
      }
    }
    else
    {
      if (FxAlpha == 0) return;

      final targetGraphics = (graphics == null) ? canvas.graphics : graphics;

      targetGraphics.overrideBlendMode(null);
      targetGraphics.beginFill(Color, FxAlpha);
      // i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
      // which could appear while cameras fading
      targetGraphics.drawRect(viewMarginLeft - 1, viewMarginTop - 1, viewWidth + 2, viewHeight + 2);
      targetGraphics.endFill();
    }
  }

  /**
   * Internal helper function, handles the actual drawing of all the special effects.
   */
  @:allow(flixel.system.frontEnds.CameraFrontEnd)
  function drawFX():Void
  {
    // Draw the "flash" special effect onto the buffer
    if (_fxFlashAlpha > 0.0)
    {
      if (FlxG.renderBlit)
      {
        var color = _fxFlashColor;
        color.alphaFloat *= _fxFlashAlpha;
        fill(color);
      }
      else
      {
        final alpha = color.alphaFloat * _fxFlashAlpha;
        fill(_fxFlashColor.rgb, true, alpha, canvas.graphics);
      }
    }

    // Draw the "fade" special effect onto the buffer
    if (_fxFadeAlpha > 0.0)
    {
      if (FlxG.renderBlit)
      {
        var color = _fxFadeColor;
        color.alphaFloat *= _fxFadeAlpha;
        fill(color);
      }
      else
      {
        final alpha = _fxFadeColor.alphaFloat * _fxFadeAlpha;
        fill(_fxFadeColor.rgb, true, alpha, canvas.graphics);
      }
    }
  }

  @:allow(flixel.system.frontEnds.CameraFrontEnd)
  function checkResize():Void
  {
    if (FlxG.renderBlit)
    {
      if (width != buffer.width || height != buffer.height)
      {
        var oldBuffer:FlxGraphic = screen.graphic;
        buffer = new BitmapData(width, height, true, 0);
        screen.pixels = buffer;
        screen.origin.set();
        _flashBitmap.bitmapData = buffer;
        _flashRect.width = width;
        _flashRect.height = height;
        _fill = FlxDestroyUtil.dispose(_fill);
        _fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
        FlxG.bitmap.removeIfNoUse(oldBuffer);
      }

      updateBlitMatrix();
    }
  }

  inline function updateBlitMatrix():Void
  {
    _blitMatrix.identity();
    _blitMatrix.translate(-viewMarginLeft, -viewMarginTop);
    _blitMatrix.scale(scaleX, scaleY);

    _useBlitMatrix = (scaleX < initialZoom) || (scaleY < initialZoom);
  }

  /**
   * Shortcut for setting both `width` and `height`.
   *
   * @param   Width    The new camera width.
   * @param   Height   The new camera height.
   */
  public inline function setSize(Width:Int, Height:Int)
  {
    width = Width;
    height = Height;
  }

  /**
   * Helper function to set the coordinates of this camera.
   * Handy since it only requires one line of code.
   *
   * @param   X   The new x position.
   * @param   Y   The new y position.
   */
  public inline function setPosition(X:Float = 0, Y:Float = 0):Void
  {
    x = X;
    y = Y;
  }

  /**
   * Specify the bounding rectangle of where the camera is allowed to move.
   *
   * @param   X             The smallest X value of your level (usually `0`).
   * @param   Y             The smallest Y value of your level (usually `0`).
   * @param   Width         The largest X value of your level (usually the level width).
   * @param   Height        The largest Y value of your level (usually the level height).
   * @param   UpdateWorld   Whether the global quad-tree's dimensions should be updated to match (default: `false`).
   */
  public function setScrollBoundsRect(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, UpdateWorld:Bool = false):Void
  {
    if (UpdateWorld)
    {
      FlxG.worldBounds.set(X, Y, Width, Height);
    }

    setScrollBounds(X, X + Width, Y, Y + Height);
  }

  /**
   * Specify the bounds of where the camera is allowed to move.
   * Set the boundary of a side to `null` to leave that side unbounded.
   *
   * @param   MinX   The minimum X value the camera can scroll to
   * @param   MaxX   The maximum X value the camera can scroll to
   * @param   MinY   The minimum Y value the camera can scroll to
   * @param   MaxY   The maximum Y value the camera can scroll to
   */
  public function setScrollBounds(MinX:Null<Float>, MaxX:Null<Float>, MinY:Null<Float>, MaxY:Null<Float>):Void
  {
    minScrollX = MinX;
    maxScrollX = MaxX;
    minScrollY = MinY;
    maxScrollY = MaxY;
    updateScroll();
  }

  /**
   * Helper function to set the scale of this camera.
   * Handy since it only requires one line of code.
   *
   * @param   X   The new scale on x axis
   * @param   Y   The new scale of y axis
   */
  public function setScale(X:Float, Y:Float):Void
  {
    scaleX = X;
    scaleY = Y;

    totalScaleX = scaleX * FlxG.scaleMode.scale.x;
    totalScaleY = scaleY * FlxG.scaleMode.scale.y;

    if (FlxG.renderBlit)
    {
      updateBlitMatrix();

      if (_useBlitMatrix)
      {
        _flashBitmap.scaleX = initialZoom * FlxG.scaleMode.scale.x;
        _flashBitmap.scaleY = initialZoom * FlxG.scaleMode.scale.y;
      }
      else
      {
        _flashBitmap.scaleX = totalScaleX;
        _flashBitmap.scaleY = totalScaleY;
      }
    }

    calcMarginX();
    calcMarginY();

    updateScrollRect();
    updateInternalSpritePositions();

    FlxG.cameras.cameraResized.dispatch(this);
  }

  /**
   * Called by camera front end every time you resize the game.
   * It triggers reposition of camera's internal display objects.
   */
  public function onResize():Void
  {
    filterRefresh = true;
    updateFlashOffset();
    setScale(scaleX, scaleY);
  }

  /**
   * The size and position of this camera's margins, via `viewMarginLeft`, `viewMarginTop`, `viewWidth`
   * and `viewHeight`.
   * @since 5.2.0
   */
  public function getViewMarginRect(?rect:FlxRect)
  {
    if (rect == null) rect = FlxRect.get();

    return rect.set(viewMarginLeft, viewMarginTop, viewWidth, viewHeight);
  }

  /**
   * Checks whether this camera contains a given point or rectangle, in
   * screen coordinates.
   * @since 4.3.0
   */
  public inline function containsPoint(point:FlxPoint, width:Float = 0, height:Float = 0):Bool
  {
    var contained = (point.x + width > viewMarginLeft) && (point.x < viewMarginRight) && (point.y + height > viewMarginTop) && (point.y < viewMarginBottom);
    point.putWeak();
    return contained;
  }

  /**
   * Checks whether this camera contains a given rectangle, in screen coordinates.
   * @since 4.11.0
   */
  public inline function containsRect(rect:FlxRect):Bool
  {
    var contained = (rect.right > viewMarginLeft) && (rect.x < viewMarginRight) && (rect.bottom > viewMarginTop) && (rect.y < viewMarginBottom);
    rect.putWeak();
    return contained;
  }

  function set_width(Value:Int):Int
  {
    if (width != Value && Value > 0)
    {
      width = Value;
      calcMarginX();
      updateFlashOffset();
      updateScrollRect();
      updateInternalSpritePositions();

      FlxG.cameras.cameraResized.dispatch(this);
    }
    return Value;
  }

  function set_height(Value:Int):Int
  {
    if (height != Value && Value > 0)
    {
      height = Value;
      calcMarginY();
      updateFlashOffset();
      updateScrollRect();
      updateInternalSpritePositions();

      FlxG.cameras.cameraResized.dispatch(this);
    }
    return Value;
  }

  function set_zoom(Zoom:Float):Float
  {
    zoom = (Zoom == 0) ? defaultZoom : Zoom;
    setScale(zoom, zoom);
    return zoom;
  }

  function set_alpha(Alpha:Float):Float
  {
    alpha = FlxMath.bound(Alpha, 0, 1);
    if (FlxG.renderBlit)
    {
      _flashBitmap.alpha = Alpha;
    }
    else
    {
      canvas.alpha = Alpha;
    }
    return Alpha;
  }

  function set_angle(Angle:Float):Float
  {
    angle = Angle;
    flashSprite.rotation = Angle;
    return Angle;
  }

  function set_color(Color:FlxColor):FlxColor
  {
    color = Color;
    var colorTransform:ColorTransform;

    if (FlxG.renderBlit)
    {
      if (_flashBitmap == null)
      {
        return Color;
      }
      colorTransform = _flashBitmap.transform.colorTransform;
    }
    else
    {
      colorTransform = canvas.transform.colorTransform;
    }

    colorTransform.redMultiplier = color.redFloat;
    colorTransform.greenMultiplier = color.greenFloat;
    colorTransform.blueMultiplier = color.blueFloat;

    if (FlxG.renderBlit)
    {
      _flashBitmap.transform.colorTransform = colorTransform;
    }
    else
    {
      canvas.transform.colorTransform = colorTransform;
    }

    return Color;
  }

  function set_antialiasing(Antialiasing:Bool):Bool
  {
    antialiasing = Antialiasing;
    if (FlxG.renderBlit)
    {
      _flashBitmap.smoothing = Antialiasing;
    }
    return Antialiasing;
  }

  function set_x(x:Float):Float
  {
    this.x = x;
    updateFlashSpritePosition();
    return x;
  }

  function set_y(y:Float):Float
  {
    this.y = y;
    updateFlashSpritePosition();
    return y;
  }

  override function set_visible(visible:Bool):Bool
  {
    if (flashSprite != null)
    {
      flashSprite.visible = visible;
    }
    return this.visible = visible;
  }

  inline function calcMarginX():Void
  {
    viewMarginX = 0.5 * width * (scaleX - initialZoom) / scaleX;
  }

  inline function calcMarginY():Void
  {
    viewMarginY = 0.5 * height * (scaleY - initialZoom) / scaleY;
  }

  static inline function get_defaultCameras():Array<FlxCamera>
  {
    return _defaultCameras;
  }

  static inline function set_defaultCameras(value:Array<FlxCamera>):Array<FlxCamera>
  {
    return _defaultCameras = value;
  }

  inline function get_viewMarginLeft():Float
  {
    return viewMarginX;
  }

  inline function get_viewMarginTop():Float
  {
    return viewMarginY;
  }

  inline function get_viewMarginRight():Float
  {
    return width - viewMarginX;
  }

  inline function get_viewMarginBottom():Float
  {
    return height - viewMarginY;
  }

  inline function get_viewWidth():Float
  {
    return width - viewMarginX * 2;
  }

  inline function get_viewHeight():Float
  {
    return height - viewMarginY * 2;
  }

  inline function get_viewX():Float
  {
    return scroll.x + viewMarginX;
  }

  inline function get_viewY():Float
  {
    return scroll.y + viewMarginY;
  }

  inline function get_viewLeft():Float
  {
    return viewX;
  }

  inline function get_viewTop():Float
  {
    return viewY;
  }

  inline function get_viewRight():Float
  {
    return scroll.x + viewMarginRight;
  }

  inline function get_viewBottom():Float
  {
    return scroll.y + viewMarginBottom;
  }

  /**
   * Do not use the following fields! They only exists because FlxCamera extends FlxBasic,
   * we're hiding them because they've only caused confusion.
   */
  @:deprecated("don't reference camera.camera")
  @:noCompletion
  override function get_camera():FlxCamera
    throw "don't reference camera.camera";

  @:deprecated("don't reference camera.camera")
  @:noCompletion
  override function set_camera(value:FlxCamera):FlxCamera
    throw "don't reference camera.camera";

  @:deprecated("don't reference camera.cameras")
  @:noCompletion
  override function get_cameras():Array<FlxCamera>
    throw "don't reference camera.cameras";

  @:deprecated("don't reference camera.cameras")
  @:noCompletion
  override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera>
    throw "don't reference camera.cameras";
}

enum FlxCameraFollowStyle
{
  /**
   * Camera has no deadzone, just tracks the focus object directly.
   */
  LOCKON;

  /**
   * Camera's deadzone is narrow but tall.
   */
  PLATFORMER;

  /**
   * Camera's deadzone is a medium-size square around the focus object.
   */
  TOPDOWN;

  /**
   * Camera's deadzone is a small square around the focus object.
   */
  TOPDOWN_TIGHT;

  /**
   * Camera will move screenwise.
   */
  SCREEN_BY_SCREEN;

  /**
   * Camera has no deadzone, just tracks the focus object directly and centers it.
   */
  NO_DEAD_ZONE;
}
