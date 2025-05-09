package funkin.graphics;

import openfl.geom.Vector3D;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxSprite;
import lime.math.Vector2;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import funkin.play.modchartSystem.ModConstants;
import funkin.graphics.ZSprite;
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;
import flixel.util.FlxColor;

class ZProjectSprite extends ZSprite
{
  // Makes the mesh all wobbly!
  public var vibrateEffect:Float = 0.0;

  // If set, will reference this sprites graphic! Very useful for animations!
  public var spriteGraphic(default, set):FlxSprite;

  function set_spriteGraphic(value:FlxSprite):FlxSprite
  {
    spriteGraphic = value;
    if (spriteGraphic != null)
    {
      loadGraphic(spriteGraphic.updateFramePixels());
      // setUp();
    }
    return spriteGraphic;
  }

  public var originalWidthHeight:Vector2;
  public var projectionEnabled:Bool = true;
  public var autoOffset:Bool = false;

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

  public var moveX:Float = 0;
  public var moveY:Float = 0;
  public var moveZ:Float = 0;

  public var fovOffsetX:Float = 0;
  public var fovOffsetY:Float = 0;
  // public var fovOffsetZ:Float = 0;
  public var pivotOffsetX:Float = 0;
  public var pivotOffsetY:Float = 0;
  public var pivotOffsetZ:Float = 0;

  // public var topleft:Vector3D = new Vector3D(-1, -1, 0);
  // public var topright:Vector3D = new Vector3D(1, -1, 0);
  // public var bottomleft:Vector3D = new Vector3D(-1, 1, 0);
  // public var bottomright:Vector3D = new Vector3D(1, 1, 0);
  // public var middlePoint:Vector3D = new Vector3D(0.5, 0.5, 0);
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

  private var processedGraphic:FlxGraphic;

  // custom setter to prevent values below 0, cuz otherwise we'll devide by 0!
  public var subdivisions(default, set):Int = 2;

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

  public function setUp():Void
  {
    this.x = 0;
    this.y = 0;
    this.z = 0;

    if (spriteGraphic != null)
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

    updateUV();
    updateTris();
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

  public function updateTris(debugTrace:Bool = false):Void
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    culled = false;

    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        var point2D:Vector2;
        var point3D:Vector3D = new Vector3D(0, 0, 0);
        point3D.x = (w / (subdivisions + 1)) * x;
        point3D.y = (h / (subdivisions + 1)) * y;

        // skew funny
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);
        // For some reason, we need a 0.5 offset for this???????????????????
        var xPercent_SkewOffset:Float = xPercent - skewY_offset - 0.5;
        var yPercent_SkewOffset:Float = yPercent - skewX_offset - 0.5;
        // Keep math the same as skewedsprite for parity reasons.
        if (skewX != 0) // Small performance boost from this if check to avoid the tan math lol?
          point3D.x += yPercent_SkewOffset * Math.tan(skewX * FlxAngle.TO_RAD) * h;
        if (skewY != 0) //
          point3D.y += xPercent_SkewOffset * Math.tan(skewY * FlxAngle.TO_RAD) * w;
        if (skewZ != 0) //
          point3D.z += yPercent_SkewOffset * Math.tan(skewZ * FlxAngle.TO_RAD) * h;

        if (vibrateEffect != 0)
        {
          point3D.x += FlxG.random.float(-1, 1) * vibrateEffect;
          point3D.y += FlxG.random.float(-1, 1) * vibrateEffect;
          point3D.z += FlxG.random.float(-1, 1) * vibrateEffect;
        }

        // scale
        var newWidth:Float = (scaleX - 1) * (xPercent - 0.5);
        point3D.x += (newWidth) * w;
        newWidth = (scaleY - 1) * (yPercent - 0.5);
        point3D.y += (newWidth) * h;

        point2D = applyPerspective(point3D, xPercent, yPercent);

        if (originalWidthHeight != null && autoOffset)
        {
          point2D.x += (originalWidthHeight.x - spriteGraphic?.frameWidth ?? frameWidth) / 2;
          point2D.y += (originalWidthHeight.y - spriteGraphic?.frameHeight ?? frameHeight) / 2;
        }

        vertices[i * 2] = point2D.x;
        vertices[i * 2 + 1] = point2D.y;
        i++;
      }
    }

    // if (debugTrace) trace("\nverts: \n" + vertices + "\n");

    // temp fix for now I guess lol?
    if (spriteGraphic != null)
    {
      spriteGraphic.flipX = false;
      spriteGraphic.flipY = false;
    }

    // TODO -> Swap this so that it instead just breaks out of the function if it detects a difference between two points as being negative!
    switch (cullMode)
    {
      case "always_positive" | "always_negative":
        if (spriteGraphic != null)
        {
          spriteGraphic.flipX = cullMode == "always_negative" ? true : false;
          spriteGraphic.flipY = cullMode == "always_negative" ? true : false;
        }

        var xFlipCheck_vertTopLeftX = vertices[0];
        var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
        if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
        {
          if (spriteGraphic != null)
          {
            spriteGraphic.flipX = !spriteGraphic.flipX;
          }
          else
          {
            culled = true;
          }
        }
        else
        { // y check
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
          {
            if (spriteGraphic != null)
            {
              spriteGraphic.flipY = !spriteGraphic.flipY;
            }
            else
            {
              culled = true;
            }
          }
        }
    }
  }

  public var cullMode:String = "none";

  var culled:Bool = false;

  @:access(flixel.FlxCamera)
  override public function draw():Void
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
    if (culled || alpha == 0 || graphic == null || vertices == null || indices == null || processedGraphic == null)
    {
      return;
    }

    var graphicToUse:FlxGraphic;
    if (doUpdateColorTransform)
    {
      graphicToUse = processedGraphic;
    }
    else
    {
      graphicToUse = this.graphic;
    }

    if (spriteGraphic != null) spriteGraphic.updateFramePixels();

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      getScreenPosition(_point, camera).subtractPoint(offset);
      // camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing, spriteGraphic?.shader ?? null, c);

      camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, textureRepeat, antialiasing,
        spriteGraphic?.colorTransform ?? this.colorTransform, spriteGraphic?.shader ?? null, c);

      // camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing);
      // trace("we do be drawin... something?\n verts: \n" + vertices);
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  public var textureRepeat:Bool = false;

  override public function destroy():Void
  {
    vertices = null;
    indices = null;
    uvtData = null;
    spriteGraphic = null;
    if (processedGraphic != null) processedGraphic.destroy();

    super.destroy();
  }

  public var doUpdateColorTransform:Bool = false;

  // DON'T UPDATE THIS SHIT
  override function updateColorTransform():Void
  {
    super.updateColorTransform();
    if (!doUpdateColorTransform && processedGraphic != null) return;

    if (processedGraphic != null) processedGraphic.destroy();
    if (spriteGraphic != null)
    {
      spriteGraphic.updateFramePixels();
      // processedGraphic = spriteGraphic._frameGraphic;
      processedGraphic = FlxGraphic.fromBitmapData(spriteGraphic.framePixels, true);
      processedGraphic.bitmap.colorTransform(processedGraphic.bitmap.rect, colorTransform);
    }
    else if (graphic != null)
    {
      processedGraphic = FlxGraphic.fromGraphic(graphic, true);
      processedGraphic.bitmap.colorTransform(processedGraphic.bitmap.rect, colorTransform);
    }
  }

  public function applyPerspective(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector2
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, h / 2);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetY;
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.y), angleZ);
    pos_modified.x = thing.x;
    pos_modified.y = thing.y;

    rotateModPivotPoint = new Vector2(w / 2, 0);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetZ;
    thing = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.z), angleY);
    pos_modified.x = thing.x;
    pos_modified.z = thing.y;

    rotateModPivotPoint = new Vector2(0, h / 2);
    rotateModPivotPoint.x += pivotOffsetZ;
    rotateModPivotPoint.y += pivotOffsetY;
    thing = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.z, pos_modified.y), angleX);
    pos_modified.z = thing.x;
    pos_modified.y = thing.y;

    // Apply offset here before it gets affected by z projection!
    pos_modified.x -= offset.x;
    pos_modified.y -= offset.y;

    pos_modified.x += moveX;
    pos_modified.y += moveY;
    pos_modified.z += moveZ;

    if (projectionEnabled)
    {
      pos_modified.x += this.x;
      pos_modified.y += this.y;
      pos_modified.z += this.z; // ?????

      pos_modified.x += fovOffsetX;
      pos_modified.y += fovOffsetY;
      pos_modified.z *= 0.001;

      pos_modified = ModConstants.perspectiveMath(pos_modified, 0, 0);

      pos_modified.x -= this.x;
      pos_modified.y -= this.y;
      pos_modified.z -= this.z * 0.001; // ?????

      pos_modified.x -= fovOffsetX;
      pos_modified.y -= fovOffsetY;
      return new Vector2(pos_modified.x, pos_modified.y);
    }
    else
    {
      return new Vector2(pos_modified.x, pos_modified.y);
    }
  }
}
