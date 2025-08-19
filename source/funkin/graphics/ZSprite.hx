package funkin.graphics;

import lime.math.Vector2;
import openfl.geom.Vector3D;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import funkin.play.modchartSystem.ModConstants;

class ZSprite extends FunkinSkewedSprite
{
  // This sprites z position. Used for perspective math.
  public var z:Float = 0.0;

  // helpful additives for x,y,z
  public var z2:Float = 0.0;
  public var y2:Float = 0.0;
  public var x2:Float = 0.0;

  // Used for orient mod, but could be useful to use?
  public var lastKnownPosition:Vector3D;

  // Use this to get the current z value of this sprite!
  public function getZ():Float
  {
    return z + z2;
  }

  override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
  {
    var output:FlxPoint = super.getScreenPosition(result, camera);
    output.x += this.x2;
    output.y += this.y2;
    return output;
  }

  // Was a test so that when Z-Sort mod gets disabled, everything can get returned to their proper strums.
  public var weBelongTo:Strumline = null;

  // some extra variables for stealthGlow
  public var stealthGlow:Float; // 0 = not applied. 1 = fully lit.
  // the white glow of stealth's RED color value
  public var stealthGlowRed:Float;
  // the white glow of stealth's GREEN color value
  public var stealthGlowGreen:Float;
  // the white glow of stealth's BLUE color value
  public var stealthGlowBlue:Float;

  public var hueShift:Float;

  public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset)
  {
    super(x, y);
    if (simpleGraphic != null) loadGraphic(simpleGraphic);
    lastKnownPosition = new Vector3D(x, y, z);
    stealthGlow = 0.0;
    stealthGlowRed = 1.0;
    stealthGlowGreen = 1.0;
    stealthGlowBlue = 1.0;
  }

  // Offset the perspective math center by this amount!
  public var perspectiveCenterOffset:Vector2 = new Vector2(0, 0);

  // The value provided to the applyPerspective function for noteWidth parameter.
  public var perspectiveWidth:Null<Float> = null;
  // The value provided to the applyPerspective function for noteHeight parameter.
  public var perspectiveHeight:Null<Float> = null;

  // If set to true, will automatically calculate this sprites perspective to emulate 3D in every draw() call
  public var autoCalculatePerspective:Bool = true;

  override public function draw():Void
  {
    if (!autoCalculatePerspective || getZ() == 0) // Draw like a regular sprite if the z value is 0, or we have autoCalculate disabled
    {
      super.draw();
    }
    else
    {
      var wasScaleX:Float = scale.x;
      var wasScaleY:Float = scale.y;
      var wasX:Float = this.x;
      var wasY:Float = this.y;
      var wasX2:Float = this.x2;
      var wasY2:Float = this.y2;

      this.x = this.x + this.x2;
      this.y = this.y + this.y2;
      this.x2 = 0;
      this.y2 = 0;

      ModConstants.applyPerspective(this, perspectiveWidth, perspectiveHeight, perspectiveCenterOffset);
      super.draw();

      this.x = wasX;
      this.y = wasY;
      this.x2 = wasX2;
      this.y2 = wasY2;
      this.scale.x = wasScaleX;
      this.scale.y = wasScaleY;
    }
  }

  // Feed a noteData into this function to apply all of it's parameters to this sprite!
  public function applyNoteData(data:NoteData, applyFake3D:Bool = false):Void
  {
    this.x = data.x;
    this.y = data.y;
    this.z = data.z;

    this.angle = data.angleZ;

    this.scale.x = data.scaleX;
    this.scale.y = data.scaleY;

    this.perspectiveCenterOffset = data.perspectiveOffset;

    if (applyFake3D || data.whichStrumNote?.strumExtraModData?.threeD ?? false == false)
    {
      this.scale.x *= FlxMath.fastCos(data.angleY * (Math.PI / 180));
      this.scale.y *= FlxMath.fastCos(data.angleX * (Math.PI / 180));
    }

    this.alpha = data.alpha;

    this.stealthGlow = data.stealth;
    this.stealthGlowRed = data.stealthGlowRed;
    this.stealthGlowGreen = data.stealthGlowGreen;
    this.stealthGlowBlue = data.stealthGlowBlue;

    this.skew.x = data.skewX;
    this.skew.y = data.skewY;

    this.color.redFloat = data.red;
    this.color.greenFloat = data.green;
    this.color.blueFloat = data.blue;

    this.hueShift = data.hueShift;

    this.lastKnownPosition = data.lastKnownPosition;
  }

  // Call this to update the last known position variable
  public function updateLastKnownPos():Void
  {
    if (lastKnownPosition == null) lastKnownPosition = new Vector3D(this.x, this.y, this.z);
    else
    {
      lastKnownPosition.x = this.x + this.x2;
      lastKnownPosition.y = this.y + this.y2;
      lastKnownPosition.z = this.z + this.z2;
    }
  }

  // Dumb silly way of identifying whether this is a holdCover or not as holdCovers don't use a special class
  public var isHoldCover:Bool = false;

  // ditto but for whether it's meant to be behind strums (for zsort)
  public var coverBehindStrums:Bool = false;
}
