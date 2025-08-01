package funkin.play.modchartSystem;

import flixel.FlxG;
import funkin.play.modchartSystem.ModHandler;
import flixel.util.FlxColor;

class ModTimeEvent
{
  // ModHandler to target (or player to target lol)
  public var target:ModHandler = null;

  // Has this been already triggered?
  public var hasTriggered:Bool = false;

  // name of mod to tween / modify
  public var modName:String = "drunk";

  // what type of event is this?
  public var style:String = "tween"; // tween, add, set, func, func_tween, perframe, reset, resort

  // perframe not added yet!
  public var startValue:Float = 0.0; // only used for func_tweens.   v0.7.7a -> Now also used for value tweens
  public var gotoValue:Float = 1.0; // val to tween or set val to!

  // Ease to use for tweens
  public var easeToUse:Null<Float->Float>;

  // How long the tween should be in beats
  public var timeInBeats:Float = 1.0;

  // Time to trigger this event
  public var startingBeat:Float = 4.0;

  // If skipping past the event trigger time, should it stil activate?
  public var persist:Bool = true;

  // Function to trigger for func events.
  public var funcToCall:Void->Void = null;

  // Function to trigger for funcTween events.
  public var funcTween = function(a:Float) {
    return a;
  }

  public function new()
  {
    // super("eventHandle");
  }

  public function tweenFunky(val:Float)
  {
    if (funcTween == null) return;

    try
    {
      funcTween(val);
    }
    catch (e:Dynamic)
    {
      PlayState.instance.modDebugNotif(e, FlxColor.RED);
    }
  }

  public function triggerFunction()
  {
    if (funcToCall == null) return;

    try
    {
      funcToCall();
    }
    catch (e:Dynamic)
    {
      PlayState.instance.modDebugNotif(e, FlxColor.RED);
    }
  }
}
