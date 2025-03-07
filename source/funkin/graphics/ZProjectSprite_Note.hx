package funkin.graphics;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModConstants;
import lime.math.Vector2;
import openfl.geom.Matrix;
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;
import flixel.util.FlxColor;
import funkin.play.PlayState;

class ZProjectSprite_Note extends FlxSprite
{
  // Makes the mesh all wobbly!
  public var vibrateEffect:Float = 0.0;

  public var vertOffsetX:Array<Float> = [];
  public var vertOffsetY:Array<Float> = [];
  public var vertOffsetZ:Array<Float> = [];

  public var z:Float = 0.0;

  // If set, will reference this sprites graphic! Very useful for animations!
  public var spriteGraphic(default, set):FlxSprite;

  var precacheSpriteGraphic:Bool = true;

  function set_spriteGraphic(value:FlxSprite):FlxSprite
  {
    spriteGraphic = value;
    if (value != null)
    {
      this.antialiasing = spriteGraphic.antialiasing;
      // SCAN THROUGH ALL THE ANIMATIONS OF THIS GRAPHIC AND CACHE EVERY ANIMATION FRAME!
      if (precacheSpriteGraphic)
      {
        ZProjectSprite_Note.precacheSpriteAnims(spriteGraphic, graphicCacheSuffix);
      }
    }
    return spriteGraphic;
  }

  public static function precacheSpriteAnims(s:FlxSprite, suffix:String)
  {
    var allFrames = s.frames;
    for (i in 0...allFrames.frames.length)
    {
      var frame = allFrames.frames[i];
      var animFrameName:String = frame.name + " - " + suffix;

      // trace(animFrameName);

      // check to see if we have this frame of animation saved
      if (ZProjectSprite_Note.graphicCache3D.exists(animFrameName))
      {
        continue; // already cached...
      }
      else
      {
        trace("PRECACHE -> New frame for: " + animFrameName);
        var graphicToUse:FlxGraphic;

        // grab the bitmap
        // grab only
        graphicToUse = FlxGraphic.fromFrame(frame, true, animFrameName);
        ZProjectSprite_Note.graphicCache3D.set(animFrameName, graphicToUse);
      }
    }
  }

  public var projectionEnabled:Bool = true;
  public var autoOffset:Bool = false;

  public var originalWidthHeight:Vector2;

  public var angleX:Float = 0;
  public var angleY:Float = 0;
  public var angleZ:Float = 0;

  public var scaleX:Float = 1;
  public var scaleY:Float = 1;
  public var scaleZ:Float = 1;

  public var skewX:Float = 0;
  public var skewY:Float = 0;
  public var skewZ:Float = 0;

  // in %
  public var skewX_offset:Float = 0.5;
  public var skewY_offset:Float = 0.5;
  public var skewZ_offset:Float = 0.5;

  // Playfield Skewing
  public var skewX_playfield:Float = 0;
  public var skewY_playfield:Float = 0;
  public var skewZ_playfield:Float = 0;

  // in pixels
  public var playfieldSkewCenterX:Float = FlxG.width / 2;
  public var playfieldSkewCenterY:Float = FlxG.height / 2;
  public var playfieldSkewCenterZ:Float = 0;

  public var moveX:Float = 0;
  public var moveY:Float = 0;
  public var moveZ:Float = 0;

  public var fovOffsetX:Float = 0;
  public var fovOffsetY:Float = 0;
  // public var fovOffsetZ:Float = 0;
  public var pivotOffsetX:Float = 0;
  public var pivotOffsetY:Float = 0;
  public var pivotOffsetZ:Float = 0;

  public var fov:Float = 90;

  /**
   * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
   */
  public var vertices:DrawData<Float> = new DrawData<Float>();

  /**
   * A `Vector` of integers or indexes, where every three indexes define a triangle.
   */
  public var indices:DrawData<Int> = new DrawData<Int>();

  /**
   * A `Vector` of normalized coordinates used to apply texture mapping.
   */
  public var uvtData:DrawData<Float> = new DrawData<Float>();

  // custom setter to prevent values below 0, cuz otherwise we'll devide by 0!
  public var subdivisions(default, set):Int = 3;

  function set_subdivisions(value:Int):Int
  {
    if (subdivisions == value) return subdivisions;

    if (value < 0) value = 0;
    subdivisions = value;
    return subdivisions;
  }

  public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset)
  {
    super(x, y, simpleGraphic);
    if (simpleGraphic != null) setUp();
  }

  public function setUp(moveSprGraph:Bool = true):Void
  {
    this.x = 0;
    this.y = 0;
    this.z = 0;

    if (spriteGraphic != null && moveSprGraph)
    {
      spriteGraphic.x = 0;
      spriteGraphic.y = 0;
    }

    var nextRow:Int = (subdivisions + 1 + 1);

    this.active = true; // This NEEDS to be true for the note to be drawn!
    updateColorTransform();
    var noteIndices:Array<Int> = [];
    for (x in 0...subdivisions + 1)
    {
      for (y in 0...subdivisions + 1)
      {
        // indices are created from top to bottom, going along the x axis each cycle.
        var funny:Int = y + (x * nextRow);
        noteIndices.push(0 + funny);
        noteIndices.push(nextRow + funny);
        noteIndices.push(1 + funny);

        noteIndices.push(nextRow + funny);
        noteIndices.push(nextRow + 1 + funny);
        noteIndices.push(1 + funny);
      }
    }
    indices = new DrawData<Int>(noteIndices.length, true, noteIndices);

    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        vertOffsetX.push(0);
        vertOffsetY.push(0);
        vertOffsetZ.push(0);
      }
    }
    updateUV();
    updateTris(true);
  }

  // V0.8.0a -> Can now modify UV's!
  public function updateUV():Void
  {
    // UV coordinates are normalized, so they range from 0 to 1.
    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        // the %
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);

        var uvX:Float = xPercent;
        var uvY:Float = yPercent;

        // uv scale
        uvX -= uvScaleOffset.x;
        uvY -= uvScaleOffset.y;

        uvX *= uvScale.x;
        uvY *= uvScale.y;

        uvX += uvScaleOffset.x;
        uvY += uvScaleOffset.y;

        // uv offset
        uvX += uvOffset.x;
        uvY += uvOffset.y;

        // map it
        uvtData[i * 2] = uvX;
        uvtData[i * 2 + 1] = uvY;
        i++;
      }
    }
  }

  public var uvScale:Vector2 = new Vector2(1.0, 1.0);
  public var uvScaleOffset:Vector2 = new Vector2(0.5, 0.5); // scale from center
  public var uvOffset:Vector2 = new Vector2(0.0, 0.0);

  // For checking if values have changed as to prevent constantly updating the tris constantly
  private var old_vertOffsetX:Array<Float> = [];
  private var old_vertOffsetY:Array<Float> = [];
  private var old_vertOffsetZ:Array<Float> = [];

  private var oldX:Float = 0;
  private var oldY:Float = 0;
  private var oldZ:Float = 0;
  private var oldAngleX:Float = 0;
  private var oldAngleY:Float = 0;
  private var oldAngleZ:Float = 0;
  private var oldScaleX:Float = 0;
  private var oldScaleY:Float = 0;
  private var oldScaleZ:Float = 0;
  private var oldMoveX:Float = 0;
  private var oldMoveY:Float = 0;
  private var oldMoveZ:Float = 0;
  private var oldSkewX:Float = 0;
  private var oldSkewY:Float = 0;
  private var oldSkewZ:Float = 0;
  private var oldSkewX_playfield:Float = 0;
  private var oldSkewY_playfield:Float = 0;
  private var oldSkewZ_playfield:Float = 0;
  private var oldSkewX_offset:Float = 0;
  private var oldSkewY_offset:Float = 0;
  private var oldSkewZ_offset:Float = 0;
  private var oldFovOffsetX:Float = 0;
  private var oldFovOffsetY:Float = 0;
  private var oldPivotOffsetX:Float = 0;
  private var oldPivotOffsetY:Float = 0;
  private var oldPivotOffsetZ:Float = 0;
  private var oldOffset:FlxPoint;
  private var oldFrameName:String = "";

  public function updateOldVars()
  {
    old_vertOffsetX = this.vertOffsetX.copy();
    old_vertOffsetY = this.vertOffsetY.copy();
    old_vertOffsetZ = this.vertOffsetZ.copy();

    oldOffset = this.offset;
    oldX = this.x;
    oldY = this.y;
    oldZ = this.z;
    oldScaleX = this.scaleX;
    oldScaleY = this.scaleY;
    oldScaleZ = this.scaleZ;
    oldAngleY = this.angleY;
    oldAngleX = this.angleX;
    oldAngleZ = this.angleZ;
    oldMoveX = this.moveX;
    oldMoveY = this.moveY;
    oldMoveZ = this.moveZ;
    oldFovOffsetX = this.fovOffsetX;
    oldFovOffsetY = this.fovOffsetY;
    oldPivotOffsetX = this.pivotOffsetX;
    oldPivotOffsetZ = this.pivotOffsetZ;
    oldPivotOffsetY = this.pivotOffsetY;
    oldSkewX_offset = this.skewX_offset;
    oldSkewY_offset = this.skewY_offset;
    oldSkewZ_offset = this.skewZ_offset;
    oldSkewX = this.skewX;
    oldSkewY = this.skewY;
    oldSkewZ = this.skewZ;
    oldSkewX_playfield = this.skewX_playfield;
    oldSkewY_playfield = this.skewY_playfield;
    oldSkewZ_playfield = this.skewZ_playfield;
    if (spriteGraphic != null)
    {
      oldFrameName = spriteGraphic.animation.frameName;
    }
  }

  public var alwaysUpdate:Bool = false;

  public function trisNeedUpdate():Bool
  {
    if (PlayState.instance != null)
    {
      @:privateAccess
      if (PlayState.instance.isGamePaused)
      {
        return false; // Never update if paused!
      }
    }

    if (vibrateEffect != 0 || alwaysUpdate)
    {
      return true; // Since this effect needs to be updated constantly!
    }

    // animation changed?
    if (spriteGraphic != null)
    {
      if (spriteGraphic.animation.frameName != oldFrameName) return true;
    }

    if (oldOffset != this.offset) return true;

    if (oldX != this.x) return true;
    if (oldY != this.y) return true;
    if (oldZ != this.z) return true;

    if (oldAngleX != this.angleX) return true;
    if (oldAngleY != this.angleY) return true;
    if (oldAngleZ != this.angleZ) return true;

    if (oldScaleX != this.scaleX) return true;
    if (oldScaleY != this.scaleY) return true;
    if (oldScaleZ != this.scaleZ) return true;

    if (oldSkewX != this.skewX) return true;
    if (oldSkewY != this.skewY) return true;
    if (oldSkewZ != this.skewZ) return true;

    if (oldSkewX_offset != this.skewX_offset) return true;
    if (oldSkewY_offset != this.skewY_offset) return true;
    if (oldSkewZ_offset != this.skewZ_offset) return true;

    if (oldSkewX_playfield != this.skewX_playfield) return true;
    if (oldSkewY_playfield != this.skewY_playfield) return true;
    if (oldSkewZ_playfield != this.skewZ_playfield) return true;

    if (oldFovOffsetX != this.fovOffsetX) return true;
    if (oldFovOffsetY != this.fovOffsetY) return true;

    if (oldPivotOffsetX != this.pivotOffsetX) return true;
    if (oldPivotOffsetY != this.pivotOffsetY) return true;
    if (oldPivotOffsetZ != this.pivotOffsetZ) return true;

    if (oldMoveX != this.moveX) return true;
    if (oldMoveY != this.moveY) return true;
    if (oldMoveZ != this.moveZ) return true;

    if (old_vertOffsetX != vertOffsetX) return true;
    if (old_vertOffsetY != vertOffsetY) return true;
    if (old_vertOffsetZ != vertOffsetZ) return true;

    // All the variables are the same, return false as we don't need to update!
    return false;
  }

  public function updateTris(forceUpdate:Bool = false, debugTrace:Bool = false):Void
  {
    if (!trisNeedUpdate() && !forceUpdate)
    {
      return;
    }
    var wasAlreadyFlipped_X:Bool = flipX;
    var wasAlreadyFlipped_Y:Bool = flipY;

    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    culled = false;
    // var cullCheckX:Float = 0;
    // var cullCheckY:Float = 0;

    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        // Setup point
        var point2D:Vector2;
        var point3D:Vector3D = new Vector3D(0, 0, 0);
        point3D.x = (w / (subdivisions + 1)) * x;
        point3D.y = (h / (subdivisions + 1)) * y;

        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);

        var newWidth:Float = (scaleX - 1) * (xPercent - 0.5);
        var newHeight:Float = (scaleY - 1) * (yPercent - 0.5);

        // Apply vibrate effect
        if (vibrateEffect != 0)
        {
          point3D.x += FlxG.random.float(-1, 1) * vibrateEffect;
          point3D.y += FlxG.random.float(-1, 1) * vibrateEffect;
          point3D.z += FlxG.random.float(-1, 1) * vibrateEffect;
        }

        // Apply curVertOffsets
        var curVertOffsetX:Float = 0;
        var curVertOffsetY:Float = 0;
        var curVertOffsetZ:Float = 0;

        if (i < vertOffsetX.length)
        {
          curVertOffsetX = vertOffsetX[i];
        }
        if (i < vertOffsetY.length)
        {
          curVertOffsetY = vertOffsetY[i];
        }
        if (i < vertOffsetZ.length)
        {
          curVertOffsetZ = vertOffsetZ[i];
        }

        point3D.x += curVertOffsetX;
        point3D.y += curVertOffsetY;
        point3D.z += curVertOffsetZ;

        // scale
        point3D.x += (newWidth) * w;
        point3D.y += (newHeight) * h;

        point3D = applyRotation(point3D, xPercent, yPercent);

        point3D.x += moveX;
        point3D.y += moveY;
        point3D.z += moveZ;

        point3D = applySkew(point3D, xPercent, yPercent, w, h);

        // Apply offset here before it gets affected by z projection!
        point3D.x -= offset.x;
        point3D.y -= offset.y;

        point2D = applyPerspective(point3D, xPercent, yPercent);

        /* Commented out for now cuz... it don't work / is worse then the current cull method
          if (i > 0)
          {
            if (point2D.x < cullCheckX)
            {
              culled = !culled;
            }
            if (point2D.y < cullCheckY)
            {
              culled = !culled;
            }
          }


          cullCheckX = point2D.x;
          cullCheckY = point2D.y;

          if (culled) break; // Don't bother with any more vert updates, we already know the rest will be culled...
         */

        if (originalWidthHeight != null && autoOffset)
        {
          point2D.x += (originalWidthHeight.x - spriteGraphic.frameWidth) / 2;
          point2D.y += (originalWidthHeight.y - spriteGraphic.frameHeight) / 2;
        }

        vertices[i * 2] = point2D.x;
        vertices[i * 2 + 1] = point2D.y;
        i++;
      }
    }

    // if (debugTrace) trace("\nverts: \n" + vertices + "\n");

    flipX = false;
    flipY = false;

    // TODO -> change this so that it instead just breaks out of the function if it detects a difference between two points as being negative!
    switch (cullMode)
    {
      case "always_positive" | "always_negative":
        flipX = cullMode == "always_positive" ? true : false;
        flipY = cullMode == "always_positive" ? true : false;

        var xFlipCheck_vertTopLeftX = vertices[0];
        var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
        if (!wasAlreadyFlipped_X)
        {
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
          {
            flipX = !flipX;
          }
        }
        else
        {
          if (xFlipCheck_vertTopLeftX < xFlipCheck_vertBottomRightX)
          {
            flipX = !flipX;
          }
        }
        // y check
        if (!wasAlreadyFlipped_Y)
        {
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
          {
            flipY = !flipY;
          }
        }
        else
        {
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX < xFlipCheck_vertBottomRightX)
          {
            flipY = !flipY;
          }
        }
    }
    updateOldVars();
  }

  public var cullMode:String = "none";

  var culled:Bool = false;

  // Default to true for when players create their own ZProjectSprites!
  public var doDraw:Bool = true;
  public var copySpriteGraphic:Bool = true;

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (doDraw)
    {
      if (spriteGraphic == null)
      {
        doDraw = false;
        if (PlayState.instance != null) PlayState.instance.modDebugNotif("spriteGraphic variable needs to be set!", 0xFFFF0000);
        return;
      }
      else
      {
        if (copySpriteGraphic)
        {
          this.x = spriteGraphic.x;
          this.y = spriteGraphic.y;
          // this.z = spriteGraphic.z;

          this.scaleX = spriteGraphic.scale.x;
          this.scaleY = spriteGraphic.scale.y;

          this.angleZ = spriteGraphic.angle;

          this.offset = spriteGraphic.offset;
          this.cameras = spriteGraphic.cameras;
        }
        updateTris();
        drawManual(spriteGraphic?.graphic ?? null);
      }
    }
    else
    {
      return; // do nothing lmfao, moved to drawManual just to be safe cuz idk if it will double draw or not (I doubt but, you never know with Flixel)
    }
  }

  public var textureRepeat:Bool = false;

  public var debugTesting:Bool = false;

  // public var graphicAnimMap:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
  public static var graphicCache3D:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

  public var graphicCacheSuffix:String = "";

  public function drawManual(graphicToUse:FlxGraphic = null):Void
  {
    var c = TriangleCulling.NONE;
    switch (cullMode)
    {
      case "positive" | "front":
        c = TriangleCulling.POSITIVE;
      case "negative" | "back":
        c = TriangleCulling.NEGATIVE;
      case "always":
        culled = true;
    }

    if (culled || alpha < 0 || vertices == null || indices == null || graphicToUse == null || uvtData == null || _point == null || offset == null)
    {
      return;
    }

    if (spriteGraphic != null)
    {
      this.antialiasing = spriteGraphic.antialiasing;

      // var animFrameName:String = "ligma";

      // var animFrameName:String = spriteGraphic.animation.frameName + " - " + noteStyleName + (spriteGraphic.flipX ? " - flipX" : "")
      //  + (spriteGraphic.flipY ? " - flipY" : "");

      var animFrameName:String = spriteGraphic.animation.frameName + " - " + graphicCacheSuffix;

      // check to see if we have this frame of animation saved
      if (ZProjectSprite_Note.graphicCache3D.exists(animFrameName))
      {
        graphicToUse = ZProjectSprite_Note.graphicCache3D.get(animFrameName);
        // if (debugTesting) trace("got: " + animFrameName);
      }
      else
      {
        // TODO: MAKE IT SO IT AUTOMATICALLY PRECACHES ALL THE ANIMATION FRAMES BEFORE THE SONG STARTS TO AVOID MID-SONG LAGSPIKES AS IT CACHES NEW ANIMATIONS!

        var prevAlpha:Float = spriteGraphic.alpha;
        var prevCol:FlxColor = spriteGraphic.color;
        // var prevSkewX:Float = spriteGraphic.skewY;
        // var prevSkewY:Float = spriteGraphic.skewX;
        var prevAngle:Float = spriteGraphic.angle;

        spriteGraphic.alpha = 1; // Make sure the graphic alpha is 1!
        spriteGraphic.color = 0xFFFFFFFF;
        spriteGraphic.angle = 0;

        // if (debugTesting)
        trace("New frame for: " + animFrameName);
        // if not, we create it and add it to the map.
        spriteGraphic.updateFramePixels();
        graphicToUse = FlxGraphic.fromBitmapData(spriteGraphic.framePixels, true, animFrameName);
        // graphicToUse.bitmap.colorTransform(graphicToUse.bitmap.rect, colorTransform);

        ZProjectSprite_Note.graphicCache3D.set(animFrameName, graphicToUse);
        spriteGraphic.alpha = prevAlpha;
        spriteGraphic.angle = prevAngle;
        spriteGraphic.color = prevCol;
      }
      // graphicToUse.bitmap.colorTransform(graphicToUse.bitmap.rect, colorTransform);
      // graphicToUse.bitmap.colorTransform(graphicToUse.bitmap.rect, spriteGraphic.colorTransform);

      //  var cTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0 - alphaMod);

      // if (debugTesting)
      // trace("map: " + graphicCache3D);
    }
    else
    {
      return; // fuck
    }

    if (alpha < 0 || graphicToUse == null || _point == null || offset == null)
    {
      return;
    }

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      // memory leak with drawTriangles :c

      // getScreenPosition(_point, camera).subtractPoint(offset);
      getScreenPosition(_point, camera);
      camera.drawTriangles(graphicToUse, vertices, indices, uvtData, null, _point, blend, textureRepeat, antialiasing,
        spriteGraphic?.colorTransform ?? colorTransform, spriteGraphic?.shader ?? null, c);
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  public static function clearOutCache():Void
  {
    ZProjectSprite_Note.graphicCache3D = new Map<String, FlxGraphic>();
    trace("3D animation graphics cache cleared!");
  }

  override public function destroy():Void
  {
    vertices = null;
    indices = null;
    uvtData = null;
    spriteGraphic = null;
    super.destroy();
  }

  // since updateColorTransform isn't public lol?
  public function updateCol():Void
  {
    updateColorTransform();
  }

  // Call this when updating the animation! This is because different animations can have different sprite sizes!
  override function updateColorTransform():Void
  {
    super.updateColorTransform();

    if (originalWidthHeight == null && spriteGraphic != null)
    {
      originalWidthHeight = new Vector2(spriteGraphic.frameWidth, spriteGraphic.frameHeight);
    }
  }

  public var offsetBeforeRotation:FlxPoint = new FlxPoint(0, 0);

  public var preRotationMoveX:Float = 0;
  public var preRotationMoveY:Float = 0;
  public var preRotationMoveZ:Float = 0;

  var skewOffsetFix:Float = 0.5;

  public function applySkew(pos:Vector3D, xPercent:Float, yPercent:Float, w:Float, h:Float):Vector3D
  {
    var point3D:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    var skewPosX:Float = this.x + moveX - offset.x;
    var skewPosY:Float = this.y + moveY - offset.y;

    skewPosX += (w) / 2;
    skewPosY += (h) / 2;

    var rotateModPivotPoint:Vector2 = new Vector2(0.5, 0.5); // to skew from center
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(xPercent, yPercent), angleZ); // to fix incorrect skew when rotated

    // For some reason, we need a 0.5 offset for this for it to be centered???????????????????
    var xPercent_SkewOffset:Float = thing.x - skewY_offset - skewOffsetFix;
    var yPercent_SkewOffset:Float = thing.y - skewX_offset - skewOffsetFix;
    // Keep math the same as skewedsprite for parity reasons.
    if (skewX != 0) // Small performance boost from this if check to avoid the tan math lol?
      point3D.x += yPercent_SkewOffset * Math.tan(skewX * FlxAngle.TO_RAD) * h * scaleY;
    if (skewY != 0) //
      point3D.y += xPercent_SkewOffset * Math.tan(skewY * FlxAngle.TO_RAD) * w * scaleX;

    // the %, followed by the position moved to the center of the sprite, then moved based off screen center (playfield center in future)
    var playfieldSkewOffset_Y:Float = ((thing.x - 0.5) * (h * scaleY)) + skewPosX - (playfieldSkewCenterX);
    var playfieldSkewOffset_X:Float = ((thing.y - 0.5) * (w * scaleX)) + skewPosY - (playfieldSkewCenterY);

    if (skewX_playfield != 0) point3D.x += playfieldSkewOffset_X * Math.tan(skewX_playfield * FlxAngle.TO_RAD);
    if (skewY_playfield != 0) point3D.y += playfieldSkewOffset_Y * Math.tan(skewY_playfield * FlxAngle.TO_RAD);

    // z SKEW ?

    if (skewZ != 0) point3D.z += yPercent_SkewOffset * Math.tan(skewZ * FlxAngle.TO_RAD) * h * scaleY;
    var playfieldSkewOffset_Z:Float = ((thing.y - 0.5) * (w * scaleX)) + skewPosY - (playfieldSkewCenterY);
    if (skewZ_playfield != 0) point3D.z += playfieldSkewOffset_Z * Math.tan(skewZ_playfield * FlxAngle.TO_RAD);

    return point3D;
  }

  function applyRotX(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, includeFlip:Bool = true):Vector3D
  {
    var rotateModPivotPoint:Vector2 = new Vector2(0, h / 2);
    rotateModPivotPoint.x += pivotOffsetZ;
    rotateModPivotPoint.y += pivotOffsetY;
    var angleX_withFlip:Float = angleX + (includeFlip ? (flipY ? 180 : 0) : 0);
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos.z, pos.y), angleX_withFlip);
    pos.z = thing.x;
    pos.y = thing.y;
    return pos;
  }

  function applyRotY(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, includeFlip:Bool = true):Vector3D
  {
    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, 0);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetZ;
    var angleY_withFlip:Float = angleY + (flipX ? 180 : 0);
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos.x, pos.z), angleY_withFlip);
    pos.x = thing.x;
    pos.z = thing.y;
    return pos;
  }

  function applyRotZ(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, includeFlip:Bool = true):Vector3D
  {
    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, h / 2);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetY;
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos.x, pos.y), angleZ);
    pos.x = thing.x;
    pos.y = thing.y;
    return pos;
  }

  // EDIT THIS ARRAY TO CHANGE HOW ROTATION IS APPLIED!
  public var rotationOrder:Array<String> = ["z", "y", "x"];

  public function applyRotation(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector3D
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    pos_modified.x -= offsetBeforeRotation.x;
    pos_modified.y -= offsetBeforeRotation.y;
    pos_modified.x += preRotationMoveX;
    pos_modified.y += preRotationMoveY;
    pos_modified.z += preRotationMoveZ;

    for (i in 0...rotationOrder.length)
    {
      switch (rotationOrder[i])
      {
        case "x":
          pos_modified = applyRotX(pos_modified, xPercent, yPercent, w, h);
        case "y":
          pos_modified = applyRotY(pos_modified, xPercent, yPercent, w, h);
        case "z":
          pos_modified = applyRotZ(pos_modified, xPercent, yPercent, w, h);
      }
    }

    //  pos_modified = applyRotZ(pos_modified, xPercent, yPercent, w, h);
    // pos_modified = applyRotY(pos_modified, xPercent, yPercent, w, h);
    // pos_modified = applyRotX(pos_modified, xPercent, yPercent, w, h);

    return pos_modified;
  }

  public function applyPerspective(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector2
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    if (projectionEnabled)
    {
      pos_modified.x += this.x;
      pos_modified.y += this.y;
      pos_modified.z += this.z; // ?????

      pos_modified.x += fovOffsetX;
      pos_modified.y += fovOffsetY;
      pos_modified.z *= 0.001;

      pos_modified = perspectiveMath_OLD(pos_modified, 0, 0);

      pos_modified.x -= this.x;
      pos_modified.y -= this.y;
      pos_modified.z -= this.z * 0.001; // ?????

      pos_modified.x -= fovOffsetX;
      pos_modified.y -= fovOffsetY;
    }
    return new Vector2(pos_modified.x, pos_modified.y);
  }

  public var zNear:Float = 0.0;
  public var zFar:Float = 100.0;

  // https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/ModchartUtil.hx
  public function perspectiveMath_OLD(pos:Vector3D, offsetX:Float = 0, offsetY:Float = 0):Vector3D
  {
    try
    {
      var _FOV:Float = this.fov;

      _FOV *= (Math.PI / 180.0);

      var newz:Float = pos.z;
      // Too close to camera!
      if (newz > zNear + ModConstants.tooCloseToCameraFix)
      {
        newz = zNear + ModConstants.tooCloseToCameraFix;
      }
      else if (newz < (zFar * -1)) // To far from camera!
      {
        culled = true;
      }

      newz = newz - 1;
      var zRange:Float = zNear - zFar;
      var tanHalfFOV:Float = 1;
      tanHalfFOV = FlxMath.fastSin(_FOV * 0.5) / FlxMath.fastCos(_FOV * 0.5);

      var xOffsetToCenter:Float = pos.x - (FlxG.width * 0.5);
      var yOffsetToCenter:Float = pos.y - (FlxG.height * 0.5);

      var zPerspectiveOffset:Float = (newz + (2 * zFar * zNear / zRange));

      // divide by zero check
      if (zPerspectiveOffset == 0) zPerspectiveOffset = 0.001;

      xOffsetToCenter += (offsetX * -zPerspectiveOffset);
      yOffsetToCenter += (offsetY * -zPerspectiveOffset);

      xOffsetToCenter += (0 * -zPerspectiveOffset);
      yOffsetToCenter += (0 * -zPerspectiveOffset);

      var xPerspective:Float = xOffsetToCenter * (1 / tanHalfFOV);
      var yPerspective:Float = yOffsetToCenter * tanHalfFOV;
      xPerspective /= -zPerspectiveOffset;
      yPerspective /= -zPerspectiveOffset;

      pos.x = xPerspective + (FlxG.width * 0.5);
      pos.y = yPerspective + (FlxG.height * 0.5);
      pos.z = zPerspectiveOffset;
      return pos;
    }
    catch (e)
    {
      trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: \n" + e.toString());
      culled = true;
      return pos;
    }
  }
}
