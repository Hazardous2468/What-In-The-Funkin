package funkin.play.modchartSystem;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import openfl.display.TriangleCulling;
import lime.math.Vector4;

// A custom class which contains additional information for special mods such as spiral holds, long holds, mathcutoff, etc
// Done so that it's tied to the strumNote itself as opposed to an arbitrary array somewhere (and so it can work if multiple strums are added like for 7K lol)
class StrumExtraData
{
  // If true, will make the sprites render in 3D space, kind of.
  public var threeD:Bool = false;
  public var cullMode(default, set):String = "none";

  function set_cullMode(value:String):String
  {
    if (whichStrumNote != null)
    {
      whichStrumNote.cullMode = value;
    }
    this.cullMode = value;
    return this.cullMode;
  }

  public var cullModeNotes(default, set):String = "none";

  function set_cullModeNotes(value:String):String
  {
    // if value changed...
    if (value != this.cullModeNotes && whichStrumNote != null)
    {
      this.cullModeNotes = value;
      whichStrumNote.weBelongTo.requestMeshCullUpdateForNotes(true);
    }
    else
    {
      this.cullModeNotes = value;
    }
    return this.cullModeNotes;
  }

  public var cullModeSustain(default, set):String = "none";

  function set_cullModeSustain(value:String):String
  {
    // if value changed...
    if (value != this.cullModeSustain && whichStrumNote != null)
    {
      this.cullModeSustain = value;
      whichStrumNote.weBelongTo.requestMeshCullUpdateForNotes(false);
    }
    else
    {
      this.cullModeSustain = value;
    }

    return this.cullModeSustain;
  }

  public var cullModeArrowpath(default, set):String = "none";

  function set_cullModeArrowpath(value:String):String
  {
    // if value changed...
    if (value != this.cullModeArrowpath && whichStrumNote != null)
    {
      this.cullModeArrowpath = value;
      whichStrumNote.weBelongTo.requestMeshCullUpdateForPaths();
    }
    else
    {
      this.cullModeArrowpath = value;
    }

    return this.cullModeArrowpath;
  }

  public var inDrive2Pass:Bool = false;
  public var noteStyleOffsetX:Float = 0.0;
  public var noteStyleOffsetY:Float = 0.0;
  // Who we belong too, in case we need to reference it
  public var whichStrumNote:StrumlineNote;
  // multiplier on the drawdistance! Note that it acts like NotITG where 0 is default, 1 is double, -1 is mutliplied by 0 (no draw distance)
  public var drawdistanceForward:Float = 0;
  // multiplier on the drawdistance! Note that it acts like NotITG where 0 is default, 1 is double, -1 is mutliplied by 0 (no draw distance)
  public var drawdistanceBack:Float = 0;
  // If distance is equal or greater then the value set, then skip doing mod math! 0 or below means don't use this mod!
  public var mathCutOff:Float = 0;
  // If set to higher then 0, then disables a small hold optimisation.
  public var noHoldMathShortcut:Float = 0;
  // If not zero, will make the strums do the orient math pass. orient, orientx, orienty, orient2, orientx2, orienty2
  public var orientExtraMath:Array<Float> = [
    0,
    0,
    0,
    0,
    0,
    0
  ];
  // so the angle can get undone for regular notes
  public var orientStrumAngle:Array<Float> = [
    0,
    0,
    0,
    0,
    0,
    0
  ];
  // Goes from 0 -> 1 during the arrow fade in tween
  public var introTweenPercentage:Float = 0;
  // I errr, forgot. I think it's like strum curpos for drive2?
  public var strumPos:Float = 0;
  // The alpha of this lane's arrowpath. This is used so that at 0 or lower alpha, it doesn't do any math for optimisation
  public var arrowPathAlpha:Float = 0;
  // Length of the arrowpath
  public var arrowpathLength:Float = 1500;
  // Length of the arrowpath going backwards (behind the receptors)
  public var arrowpathBackwardsLength:Float = 400;
  // The alpha of the note splashes
  public var alphaSplashMod:Float = 0;
  // The alpha of the hold covers
  public var alphaHoldCoverMod:Float = 0;
  // Dumb stupid shit for skew shit
  public var skewMovedX:Float = 0;
  public var skewMovedY:Float = 0;
  // For centered modifier? Also just useful info
  public var reverseMod:Float = 0;
  public var reverseModLane:Float = 0;
  public var playfieldX:Float = 0;
  public var playfieldY:Float = 0;
  public var playfieldZ:Float = 0;
  // scaleChange memory to be applied to noteSplashes and hold covers
  public var splashCopyStrumScale:Bool = true;
  public var holdCoverCopyStrumScale:Bool = true;
  public var strumScaleDifX:Float = 0;
  public var strumScaleDifY:Float = 0;
  // For hold hidden / sudden shader to work
  public var suddenModAmount:Float = 0;
  public var suddenStart:Float = 500;
  public var suddenEnd:Float = 300;
  public var sudden_noGlow:Float = 0;
  public var hiddenModAmount:Float = 0;
  public var hiddenStart:Float = 500;
  public var hiddenEnd:Float = 300;
  public var hidden_noGlow:Float = 0;
  public var vanishModAmount:Float = 0;
  public var vanish_noGlow:Float = 0;
  public var vanish_HiddenStart:Float = 475;
  public var vanish_HiddenEnd:Float = 397.5;
  public var vanish_SuddenStart:Float = 202.5;
  public var vanish_SuddenEnd:Float = 125;
  public var useOldStealthGlowStyle:Bool = false;

  public function new(who:StrumlineNote)
  {
    whichStrumNote = who;
    reset();
  }

  public function reset():Void
  {
    inDrive2Pass = false;

    cullMode = "none";
    cullModeNotes = "none";
    cullModeSustain = "none";
    cullModeArrowpath = "none";

    splashCopyStrumScale = true;
    holdCoverCopyStrumScale = true;
    strumScaleDifX = 0;
    strumScaleDifY = 0;

    useOldStealthGlowStyle = false;
    suddenModAmount = 0;
    suddenStart = 500;
    suddenEnd = 300;
    hiddenModAmount = 0;
    hiddenStart = 500;
    hiddenEnd = 300;

    sudden_noGlow = 0;
    hidden_noGlow = 0;
    vanish_noGlow = 0;

    vanishModAmount = 0;
    vanish_HiddenStart = 475;
    vanish_HiddenEnd = 397.5;
    vanish_SuddenStart = 202.5;
    vanish_SuddenEnd = 125;

    mathCutOff = 0;
    drawdistanceForward = 0;
    drawdistanceBack = 0;

    noHoldMathShortcut = 0;

    arrowPathAlpha = 0;
    arrowpathLength = 1500;
    arrowpathBackwardsLength = 400;

    orientStrumAngle = [
      0,
      0,
      0,
      0,
      0,
      0
    ];
    orientExtraMath = [
      0,
      0,
      0,
      0,
      0,
      0
    ];

    strumPos = 0;

    alphaHoldCoverMod = 0;
    alphaSplashMod = 0;

    reverseMod = 0;
    reverseModLane = 0;

    playfieldX = FlxG.width / 2;
    playfieldY = FlxG.height / 2;
    playfieldZ = 0;
  }
}
