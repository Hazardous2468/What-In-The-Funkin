package funkin.graphics.shaders;

class HSVNotesShader extends HSVShader
{
  public var redMult(default, set):Float = 1;

  function set_redMult(value:Float):Float
  {
    this.setFloat('_redMult', value);
    this.redMult = value;
    return this.redMult;
  }

  public var greenMult(default, set):Float = 1;

  function set_greenMult(value:Float):Float
  {
    this.setFloat('_greenMult', value);
    this.greenMult = value;
    return this.greenMult;
  }

  public var blueMult(default, set):Float = 1;

  function set_blueMult(value:Float):Float
  {
    this.setFloat('_blueMult', value);
    this.blueMult = value;
    return this.blueMult;
  }

  public var stealthGlow(default, set):Float;
  public var stealthGlowRed(default, set):Float;
  public var stealthGlowGreen(default, set):Float;
  public var stealthGlowBlue(default, set):Float;
  public var hue2(default, set):Float = 0;
  public var saturation2(default, set):Float = 1;
  public var value2(default, set):Float = 1;

  function set_hue2(value:Float):Float
  {
    this.setFloat('_hue2', value);
    this.hue2 = value;

    return this.hue2;
  }

  function set_saturation2(value:Float):Float
  {
    this.setFloat('_sat2', value);
    this.saturation2 = value;

    return this.saturation2;
  }

  function set_value2(value:Float):Float
  {
    this.setFloat('_val2', value);
    this.value2 = value;

    return this.value2;
  }

  public function new(h:Float = 1, s:Float = 1, v:Float = 1, g:Float = 0, shaderPath:String = "hsv_WITF")
  {
    super(h, s, v, shaderPath);
    FlxG.debugger.addTrackerProfile(new TrackerProfile(HSVShader, ['hue', 'saturation', 'value', 'stealthGlow']));
    hue = h;
    saturation = s;
    value = v;

    hue2 = 0;
    saturation2 = 1;
    value2 = 1;

    redMult = 1;
    greenMult = 1;
    blueMult = 1;

    stealthGlow = g;

    this.setBool('_isHold', false);
  }

  function set_stealthGlowRed(value:Float):Float
  {
    this.setFloat('_stealthR', value);
    this.stealthGlowRed = value;
    return this.stealthGlowRed;
  }

  function set_stealthGlowGreen(value:Float):Float
  {
    this.setFloat('_stealthG', value);
    this.stealthGlowGreen = value;

    return this.stealthGlowGreen;
  }

  function set_stealthGlowBlue(value:Float):Float
  {
    this.setFloat('_stealthB', value);
    this.stealthGlowBlue = value;

    return this.stealthGlowBlue;
  }

  function set_stealthGlow(value:Float):Float
  {
    this.setFloat('_stealthGlow', value);
    this.stealthGlow = value;

    return this.stealthGlow;
  }
}
