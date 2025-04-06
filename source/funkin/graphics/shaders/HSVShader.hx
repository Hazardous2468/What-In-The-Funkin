package funkin.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

class HSVShader extends FlxRuntimeShader
{
  public var hue(default, set):Float;
  public var saturation(default, set):Float;
  public var value(default, set):Float;

  public var stealthGlow(default, set):Float;
  public var stealthGlowRed(default, set):Float;
  public var stealthGlowGreen(default, set):Float;
  public var stealthGlowBlue(default, set):Float;

  public function new(h:Float = 1, s:Float = 1, v:Float = 1, g:Float = 0)
  {
    super(Assets.getText(Paths.frag('hsv')));
    FlxG.debugger.addTrackerProfile(new TrackerProfile(HSVShader, ['hue', 'saturation', 'value']));
    hue = h;
    saturation = s;
    value = v;
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

  function set_hue(value:Float):Float
  {
    this.setFloat('_hue', value);
    this.hue = value;

    return this.hue;
  }

  function set_saturation(value:Float):Float
  {
    this.setFloat('_sat', value);
    this.saturation = value;

    return this.saturation;
  }

  function set_value(value:Float):Float
  {
    this.setFloat('_val', value);
    this.value = value;

    return this.value;
  }
}
