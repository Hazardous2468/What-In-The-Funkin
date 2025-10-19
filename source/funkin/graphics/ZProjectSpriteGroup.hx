package funkin.graphics;

import flixel.FlxG;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import funkin.Paths;
import funkin.util.SortUtil;
import flixel.system.FlxAssets.FlxGraphicAsset;
import lime.math.Vector2;
import funkin.play.modchartSystem.ModConstants;
import openfl.geom.Vector3D;

/**
 * A group for ZSpriteProjected which contains helper functions for creating 3D shapes. Automatically sorts the sprites based on their z posiiton plus z index!
 * Currently experimental / WIP
 */
class ZProjectSpriteGroup extends FlxTypedSpriteGroup<ZSpriteProjected>
{
  public function new()
  {
    super();
  }

  public var z(default, set):Float = 0;

  function set_z(Value:Float):Float
  {
    if (exists && z != Value)
    {
      // transformChildren(zTransform, Value - z); // offset

      for (sprite in this)
      {
        if (sprite != null)
        {
          sprite.z += Value - z;
        }
      }
    }
    return z = Value;
  }

  var pivot:Vector2 = new Vector2(0, 0);
  var pivotOffset:Vector3D = new Vector3D(0, 0, 0);

  var tempVec2:Vector2 = new Vector2(0, 0);

  var curRotX:Float = 0;
  var curRotY:Float = 0;
  var curRotZ:Float = 0;

  // Rotates all the sprites on the x axis
  public function rotateX(rotation:Float):Void
  {
    curRotX += rotation;
    pivot.setTo(this.z + pivotOffset.z, this.y + pivotOffset.y);
    for (spr in this)
    {
      if (spr == null) continue;
      tempVec2.setTo(spr.z + ((spr.depth ?? 0) / 2), spr.y + (spr.height / 2));
      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, curRotX);
      tempVec2.y -= (spr.height / 2);
      tempVec2.x -= ((spr.depth ?? 0) / 2);

      spr.z2 = tempVec2.x - spr.z;
      spr.y2 = tempVec2.y - spr.y;
      spr.angleX2 = curRotX;
    }
  }

  // Rotates all the sprites on the y axis
  public function rotateY(rotation:Float):Void
  {
    curRotY += rotation;
    pivot.setTo(this.x + pivotOffset.x, this.z + pivotOffset.z);
    for (spr in this)
    {
      if (spr == null) continue;
      tempVec2.setTo(spr.x + (spr.width / 2), spr.z + ((spr.depth ?? 0) / 2));
      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, curRotY);
      tempVec2.x -= (spr.width / 2);
      tempVec2.y -= ((spr.depth ?? 0) / 2);

      spr.x2 = tempVec2.x - spr.x;
      spr.z2 = tempVec2.y - spr.z;
      spr.angleY2 = curRotY;
    }
  }

  // Rotates all the sprites on the z axis
  public function rotateZ(rotation:Float):Void
  {
    curRotZ += rotation;
    pivot.setTo(this.x + pivotOffset.x, this.y + pivotOffset.y);
    for (spr in this)
    {
      if (spr == null) continue;
      tempVec2.setTo(spr.x + (spr.width / 2), spr.y + (spr.height / 2));
      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, curRotZ);
      tempVec2.x -= (spr.width / 2);
      tempVec2.y -= (spr.height / 2);

      spr.x2 = tempVec2.x - spr.x;
      spr.y2 = tempVec2.y - spr.y;
      spr.angleZ2 = curRotZ;
    }
  }

  /**
   * Refresh the group, sorting its children by z.
   */
  public function refresh():Void
  {
    // sort(SortUtil.byZIndex, FlxSort.ASCENDING);
    sort(sortLogic, FlxSort.ASCENDING);
    // insertionSort(sortByZ.bind(FlxSort.ASCENDING));
  }

  // If set to true, will constantly call the "refresh()" function which will resort all the sprites in this group.
  public var autoRefresh:Bool = true;

  var sortExperimentAngleY:Bool = false;
  var sortExperimentAngleX:Bool = false;

  // Also takes into account the zIndex!
  function sortLogic(order:Int, a:ZSpriteProjected, b:ZSpriteProjected):Int
  {
    var aX:Float = (a?.x ?? 0) + (a?.x2 ?? 0);
    var bX:Float = (b?.x ?? 0) + (b?.x2 ?? 0);

    var aY:Float = (a?.y ?? 0) + (a?.y2 ?? 0);
    var bY:Float = (b?.y ?? 0) + (b?.y2 ?? 0);

    var aZ:Float = (a?.z ?? 0) + (a?.z2 ?? 0);
    var bZ:Float = (b?.z ?? 0) + (b?.z2 ?? 0);

    var val1:Float = aZ;
    var val2:Float = bZ;

    // y rotation test thing
    if (sortExperimentAngleY && curRotY % 180 >= 45 && curRotY % 180 < 135)
    {
      val1 = aX;
      val2 = bX;
    }

    val1 += a?.zIndex ?? 0;
    val2 += b?.zIndex ?? 0;

    return FlxSort.byValues(order, val1, val2);
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (this.length > 1 && this.visible && autoRefresh)
    {
      refresh();
    }
  }

  public var rotationOrder:Array<String> = ["z2", "y2", "x2"];

  override function preAdd(sprite:ZSpriteProjected):Void
  {
    super.preAdd(sprite);
    // check if the sprite has the ang2 rot vars
    for (rot2 in rotationOrder)
    {
      if (!sprite.rotationOrder.contains(rot2))
      {
        sprite.rotationOrder.push(rot2);
      }
    }
  }

  // Temp function. Creates 6 sprites in the shape of a cube and adds it to this group. Returns the created cube.
  public function createCube(imageTexture:FlxGraphicAsset, width:Float = 1, height:Float = 1, depth:Float = 1):CubeSpriteGroup
  {
    var cube = new CubeSpriteGroup(imageTexture, width, height, depth);
    for (spr in cube.getFaceSprites())
    {
      this.add(spr);
    }
    // this.add(cube);
    return cube;
  }

  // Easy helper function for creating a ZSpriteProjected. Automatically adds it to this group. Returns the ZSpriteProjected
  public function createPlane():ZSpriteProjected
  {
    var p = new ZSpriteProjected();
    this.add(p);
    return p;
  }

  // Creates a triangle. Automatically adds it to this group and returns the created tri.
  public function createTri() {}

  // WITF Draw Function logic
  public var drawFunc:Null<Void->Void>;

  private var doingDrawFunc:Bool = false;

  override public function draw():Void
  {
    if (drawFunc != null && !doingDrawFunc)
    {
      doingDrawFunc = true;
      drawFunc();
      doingDrawFunc = false;
    }
    else
    {
      super.draw();
    }
  }
}

class CubeSpriteGroup extends FlxTypedSpriteGroup<ZSpriteProjected>
{
  var frontFace:ZSpriteProjected;
  var backFace:ZSpriteProjected;
  var topFace:ZSpriteProjected;
  var bottomFace:ZSpriteProjected;
  var leftFace:ZSpriteProjected;
  var rightFace:ZSpriteProjected;

  public function getFaceSprites():Array<ZSpriteProjected>
  {
    return [frontFace, backFace, topFace, bottomFace, leftFace, rightFace];
  }

  public function new(imageTexture:FlxGraphicAsset, width:Float = 1, height:Float = 1, depth:Float = 1)
  {
    super();
  }
}
