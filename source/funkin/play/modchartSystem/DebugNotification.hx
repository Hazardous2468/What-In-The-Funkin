package funkin.play.modchartSystem;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class DebugNotification extends FlxText
{
  public var alphaTween:FlxTween;
  public var timer:FlxTimer;
  public var age:Float = 0;

  public function new()
  {
    super(0, 0, FlxG.width / 4, '', 20);
    this.scrollFactor.set();
    this.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
  }

  // Call this function to trigger the process of showing and hiding the debug notification text!
  public function displayText(txtToShow:String = "", color:FlxColor = FlxColor.WHITE, howManySeconds:Float = 5, fadeInSeconds:Float = 0.25,
      fadeOutSeconds:Float = 1):Void
  {
    if (destroying) return;
    this.text = txtToShow;
    this.color = color;

    if (fadeInSeconds == 0)
    {
      this.alpha = 1;
    }
    else
    {
      alphaTween = FlxTween.tween(this, {alpha: 1}, fadeInSeconds, {ease: FlxEase.linear});
    }
    timer = new FlxTimer().start(howManySeconds + fadeInSeconds, function(tmr) {
      if (alphaTween != null) alphaTween.cancel();
      this.alpha = 1;
      timer = null;
      if (fadeOutSeconds <= 0)
      {
        alphaTween = null;
        this.kill(); // KILL YOURSELF
      }
      else
      {
        alphaTween = FlxTween.tween(this, {alpha: 0}, fadeOutSeconds,
          {
            ease: FlxEase.linear,
            onComplete: function(_) {
              alphaTween = null;
              this.kill(); // KILL YOURSELF
            }
          });
      }
    });
  }

  public override function update(elapsed:Float):Void
  {
    if (destroying) return;
    super.update(elapsed);
    age += elapsed;
  }

  public override function kill():Void
  {
    age = 0;
    if (alphaTween != null) alphaTween.cancel();
    if (timer != null) timer.cancel();
    timer = null;
    alphaTween = null;
    alpha = 0;
    super.kill();
  }

  public override function revive():Void
  {
    super.revive();
    age = 0;
  }

  var destroying:Bool = false;

  public override function destroy():Void
  {
    destroying = true;
    if (alphaTween != null) alphaTween.cancel();
    if (timer != null) timer.cancel();
    timer = null;
    alphaTween = null;
    super.destroy();
  }
}
