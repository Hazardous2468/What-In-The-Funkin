package funkin.graphics.shaders;

class HSVNotesShader extends HSVShader
{
  public var stealthGlow(default, set):Float;
  public var stealthGlowRed(default, set):Float;
  public var stealthGlowGreen(default, set):Float;
  public var stealthGlowBlue(default, set):Float;

  public function new(h:Float = 1, s:Float = 1, v:Float = 1, g:Float = 0)
  {
    super(h, s, v, true);
    FlxG.debugger.addTrackerProfile(new TrackerProfile(HSVShader, ['hue', 'saturation', 'value', 'stealthGlow']));
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
}
