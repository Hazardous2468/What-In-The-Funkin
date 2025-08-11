package funkin.graphics;

import flixel.FlxSprite;
import lime.math.Vector2;
import openfl.geom.Vector3D;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class ZSprite extends FunkinSkewedSprite
{
  // This sprites z position. Used for perspective math.
  public var z:Float = 0.0;

  // lol?
  public var z2:Float = 0.0;
  public var y2:Float = 0.0;
  public var x2:Float = 0.0;

  // Used for orient mod, but could be useful to use?
  // public var lastKnownPosition:Vector2;
  public var lastKnownPosition:Vector3D;

  // Was a test so that when Z-Sort mod gets disabled, everything can get returned to their proper strums.
  public var weBelongTo:Strumline = null;

  // some extra variables for stealthGlow
  // jank way of doing it but, too bad
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
  public var perspectiveOffset:Vector2 = new Vector2(0, 0);

  // Feed a noteData into this function to apply all of it's parameters to this sprite!
  public function applyNoteData(data:NoteData, applyFake3D:Bool = false):Void
  {
    this.x = data.x + x2;
    this.y = data.y + y2;
    this.z = data.z + z2;

    this.angle = data.angleZ;

    this.scale.x = data.scaleX;
    this.scale.y = data.scaleY;

    this.perspectiveOffset = data.perspectiveOffset;

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

  // Call this to update last known position... lol?
  public function updateLastKnownPos():Void
  {
    if (lastKnownPosition == null) lastKnownPosition = new Vector3D(this.x, this.y, this.z);
    else
    {
      lastKnownPosition.x = this.x;
      lastKnownPosition.y = this.y;
      lastKnownPosition.z = this.z;
    }
  }
}
