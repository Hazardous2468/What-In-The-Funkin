package funkin.play.modchartSystem;

import flixel.FlxG;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import lime.graphics.Image;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import flixel.FlxCamera;
import flixel.util.FlxColor;

class HazardAFT
{
  // Set to true if you want it to not clear out the old bitmap data
  public var recursive:Bool = true;

  // The camera to target (copy the pixels from)
  // TODO -> CHANGE THIS TO BE AN ARRAY OF CAMERAS?
  public var targetCAM:FlxCamera = null;

  // The actual bitmap data
  public var bitmap:BitmapData;

  // For limiting the AFT update rate. Useful to make it less framerate dependent.
  public var updateTimer:Float = 0.0;
  public var updateRate:Float = 1 / 60; // default to 60fps

  // The blend mode to use when drawing the camera onto the bitmap.
  public var blendMode:String = "normal";

  // The colour transform of the bitmap when drawing the camera.
  public var colTransf:ColorTransform;

  // If true, will attempt to copy the filters (shaders) applied to the camera
  public var copyFilters:Bool = false;

  public function updateAFT():Void
  {
    bitmap.lock();

    if (!recursive)
    {
      clearAFT();
    }

    // This line causes a memory leak!
    // My guess is that during the process of drawing the sprite onto the bitmap, it creates some form of cache which is then discarded next garbage collection cycle, which results in memory issues.
    bitmap.draw(targetCAM.canvas, colTransf, blendMode, rec, false);

    // Don't work, probably cuz of that DAMN DISPOSEIMAGE!
    if (copyFilters && targetCAM.filtersEnabled)
    {
      for (f in targetCAM.filters)
      {
        bitmap.applyFilter(bitmap, rec, null, f);
      }
    }

    bitmap.unlock();
  }

  // clear out the old bitmap data
  public function clearAFT():Void
  {
    bitmap.fillRect(rec, 0);
  }

  public function targetFps(fps:Float = 60):Void
  {
    if (fps <= 0)
    {
      updateRate = 0;
    }
    else
    {
      updateRate = 1 / fps;
    }
  }

  public function update(elapsed:Float = 0.0):Void
  {
    if (targetCAM != null && bitmap != null)
    {
      if (updateTimer >= 0 && updateRate != 0)
      {
        updateTimer -= (elapsed / FlxG.timeScale);
      }
      else if (updateTimer < 0 || updateRate == 0)
      {
        updateTimer = updateRate;
        updateAFT();
      }
    }
  }

  // Just a basic rectangle which fills the entire bitmap when clearing out the old pixel data
  var rec:Rectangle;

  // width of bitmap
  public var w:Int = 0;
  // height of bitmap
  public var h:Int = 0;

  public function new(cameraTarget:FlxCamera, ?width:Int = -1, ?height:Int = -1, dispose:Bool = true)
  {
    if (width == -1 || height == -1)
    {
      width = FlxG.width;
      height = FlxG.height;
    }
    this.targetCAM = cameraTarget;
    bitmap = new BitmapData(width, height, true, 0);

    // So, by doing this, the bitmap 'readable' var gets set to false
    // This means no more transformations can be applied to the bitmap (like the apply shaders, colour transforms, etc)
    // BUT, it means that the memory doesn't fucking get nuked when doing the draw() function.
    // BUT BUT, the memory still gets fucked over anyway via the draw(cam.canvas) part.
    if (dispose)
    {
      bitmap.disposeImage();
    }

    rec = new Rectangle(0, 0, width, height);
    colTransf = new ColorTransform();
    w = width;
    h = height;
  }
}
