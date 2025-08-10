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

/**
 * A group for ZProjectSprites which contains helper functions for creating 3D shapes. Automatically sorts the sprites based on their z posiiton plus z index!
 * Currently experimental / WIP
 */
class ZProjectSpriteGroup extends FlxTypedSpriteGroup<ZProjectSprite>
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

  // inline function zTransform(Sprite:ZProjectSprite, Z:Float)
  //  Sprite.z += Z; // addition
  var pivot:Vector2 = new Vector2(0, 0);

  var tempVec2:Vector2 = new Vector2(0, 0);

  var curRotX:Float = 0;
  var curRotY:Float = 0;
  var curRotZ:Float = 0;

  // Rotates all the sprites on the x axis
  public function rotateX(rotation:Float):Void
  {
    // var rotationRaw:Float = rotation;
    rotation += curRotX;
    curRotX = rotation;
    pivot.setTo(this.z, this.y);
    for (spr in this)
    {
      tempVec2.setTo(spr.z + ((spr.depth ?? 0) / 2), spr.y + (spr.height / 2));
      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, rotation);
      tempVec2.y -= (spr.height / 2);
      tempVec2.x -= ((spr.depth ?? 0) / 2);

      spr.moveY = tempVec2.y - spr.y; // use move variable, otherwise drift occurs?
      spr.moveZ = tempVec2.x - spr.z;

      // spr.z = tempVec2.x;
      // spr.y = tempVec2.y;
      spr.angleX2 = rotation;
      spr.updateTris();
    }
  }

  // Rotates all the sprites on the y axis
  public function rotateY(rotation:Float):Void
  {
    // var rotationRaw:Float = rotation;
    rotation += curRotY;
    curRotY = rotation;
    pivot.setTo(this.x, this.z);

    for (spr in this)
    {
      tempVec2.setTo(spr.x + (spr.width / 2), spr.z + ((spr.depth ?? 0) / 2));
      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, rotation);
      tempVec2.x -= (spr.width / 2);
      tempVec2.y -= ((spr.depth ?? 0) / 2);

      spr.moveX = tempVec2.x - spr.x; // use move variable, otherwise drift occurs?
      spr.moveZ = tempVec2.y - spr.z;
      // spr.x = tempVec2.x;
      // spr.z = tempVec2.y;
      spr.angleY2 = rotation;
      spr.updateTris();
    }
  }

  // Rotates all the sprites on the z axis
  public function rotateZ(rotation:Float):Void
  {
    // var rotationRaw:Float = rotation;
    rotation += curRotZ;
    curRotZ = rotation;
    pivot.setTo(this.x, this.y);
    for (spr in this)
    {
      tempVec2.setTo(spr.x + (spr.width / 2), spr.y + (spr.height / 2));

      tempVec2 = ModConstants.rotateAround(pivot, tempVec2, rotation);
      tempVec2.x -= (spr.width / 2);
      tempVec2.y -= (spr.height / 2);

      spr.moveX = tempVec2.x - spr.x; // use move variable, otherwise drift occurs?
      spr.moveY = tempVec2.y - spr.y;
      // spr.x = tempVec2.x;
      // spr.y = tempVec2.y;
      spr.angleZ2 = rotation;
      spr.updateTris();
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

  var sortExperimentAngleY:Bool = false;
  var sortExperimentAngleX:Bool = false;

  // Also takes into account the zIndex!
  function sortLogic(order:Int, a:ZProjectSprite, b:ZProjectSprite):Int
  {
    var aX:Float = (a?.x ?? 0) + (a?.moveX ?? 0);
    var bX:Float = (b?.x ?? 0) + (b?.moveX ?? 0);

    var aY:Float = (a?.y ?? 0) + (a?.moveY ?? 0);
    var bY:Float = (b?.y ?? 0) + (b?.moveY ?? 0);

    var aZ:Float = (a?.z ?? 0) + (a?.moveZ ?? 0);
    var bZ:Float = (b?.z ?? 0) + (b?.moveZ ?? 0);

    var val1:Float = aZ;
    var val2:Float = bZ;

    // y rotation test thing
    if (sortExperimentAngleY && curRotY % 180 >= 45 && curRotY % 180 < 135)
    {
      val1 = aX;
      val2 = bX;
    }

    val1 += a.zIndex;
    val2 += b.zIndex;

    return FlxSort.byValues(order, val1, val2);
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (this.length > 1 && this.visible)
    {
      refresh();
    }
  }

  // Temp function. Creates 6 sprites in the shape of a cube and adds it to this group. Returns the created cube.
  public function createCube(imageTexture:FlxGraphicAsset, width:Float = 1, height:Float = 1, depth:Float = 1):CubeSpriteGroup
  {
    var cube = new CubeSpriteGroup(imageTexture, width, height, depth);
    return cube;
  }

  // Easy helper function for creating a zProjectSprite. Automatically adds it to this group. Returns the zProjectSprite
  public function createPlane():ZProjectSprite
  {
    var p = new ZProjectSprite();
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

class CubeSpriteGroup extends FlxTypedSpriteGroup<ZProjectSprite>
{
  var frontFace:ZProjectSprite;
  var backFace:ZProjectSprite;
  var topFace:ZProjectSprite;
  var bottomFace:ZProjectSprite;
  var leftFace:ZProjectSprite;
  var sideFace:ZProjectSprite;

  public function new(imageTexture:FlxGraphicAsset, width:Float = 1, height:Float = 1, depth:Float = 1)
  {
    super();
  }
}
