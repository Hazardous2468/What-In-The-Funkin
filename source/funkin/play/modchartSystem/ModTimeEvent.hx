package funkin.play.modchartSystem;

import flixel.FlxG;
import funkin.play.modchartSystem.ModHandler;
import flixel.util.FlxColor;

class ModTimeEvent
{
  /**
   * The ModHandler this event should target.
   */
  public var target:ModHandler = null;

  /**
   * Has this event already been triggered?
   * Obviously used to prevent triggering an event that's already been triggered.
   */
  public var hasTriggered:Bool = false;

  /**
   * The name of the modifier to tween.
   * Also includes the lane and submod information, such as tipsy__speed, reverse--1, drunk--3__speed, etc
   */
  public var modName:String = "drunk";

  /**
   * What type of event are we? This will determine what logic will be ran when this event gets triggered.
   * Valid types: tween, add, set, func, func_tween, perframe, reset, resort.
   * Note that perframes are not implemented yet.
   */
  public var style:String = "tween";

  /**
   * The starting point of this tween.
   * Used only by func_tweens and value tweens.
   */
  public var startValue:Float = 0.0;

  /**
   * The value this tween will go to.
   * Also used by the additive tweens to add this value onto the existing value, rather then going to this value directly.
   */
  public var gotoValue:Float = 1.0; // val to tween or set val to!

  /**
   * The ease function that shall be used for this tween.
   */
  public var easeToUse:Null<Float->Float>;

  /**
   * Defines the duration of the tween in beats.
   */
  public var timeInBeats:Float = 1.0;

  /**
   * The time (in beats) when this event will be triggered.
   */
  public var startingBeat:Float = 4.0;

  /**
   * If skipping past the event trigger time, should it stil activate?
   */
  public var persist:Bool = true;

  /**
   * Function to trigger for func events.
   */
  public var funcToCall:Void->Void = null;

  /**
   * Function to trigger for funcTween events.
   */
  public var funcTween = function(a:Float)
  {
    return a;
  }

  public function new()
  {
    // super("eventHandle");
  }

  /**
   * The function that gets called every frame by the 'func_tween' as it goes through the tween.
   * @param val The current tween value of this funcTween.
   */
  public function tweenFunky(val:Float):Void
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

  /**
   * The function that gets called for 'func' events
   */
  public function triggerFunction():Void
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
