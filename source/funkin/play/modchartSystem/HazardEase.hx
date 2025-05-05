package funkin.play.modchartSystem;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.math.FlxMath;

/*
  //Custom eases ported from mirin template!
  function bounce(t) return 4 * t * (1 - t) end
  function tri(t) return 1 - abs(2 * t - 1) end
  function bell(t) return inOutQuint(tri(t)) end
  function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
  function tap(t) return 3.5 * t * t * sqrt(1 - t) end
  function pulse(t) return t < .5 and tap(t * 2) or -pop(t * 2 - 1) end
 */
class HazardEase extends FlxEase
{
  public static inline function bounce(t:Float):Float
  {
    return 4 * t * (1 - t);
  }

  public static inline function tri(t:Float):Float
  {
    return 1 - Math.abs(2 * t - 1);
  }

  public static inline function bell(t:Float):Float
  {
    return FlxEase.quintInOut(tri(t));
  }

  public static inline function pop(t:Float):Float
  {
    return 3.5 * (1 - t) * (1 - t) * Math.sqrt(t);
  }

  public static inline function tap(t:Float):Float
  {
    return 3.5 * t * t * Math.sqrt(1 - t);
  }

  public static inline function spike(t:Float):Float
  {
    return t >= 1.0 ? 0.0 : Math.exp(-10 * Math.abs(2 * t - 1));
  }

  public static inline function inverse(t:Float):Float
  {
    return t * t * (1 - t) * (1 - t) / (0.5 - t);
  }

  public static inline function pulse(t:Float):Float
  {
    return t < 0.5 ? tap(t * 2) : -pop(t * 2 - 1);
  }

  public static inline function popElastic(t:Float):Float
  {
    var damp:Float = 1.4;
    var count:Float = 6;
    return (Math.pow(1000, -(Math.pow(t, damp))) - 0.001) * Math.sin(count * Math.PI * t);
  }

  public static inline function tapElastic(t:Float):Float
  {
    var damp:Float = 1.4;
    var count:Float = 6;
    return (Math.pow(1000, -(Math.pow((1 - t), damp))) - 0.001) * Math.sin(count * Math.PI * (1 - t));
  }

  public static inline function pulseElastic(t:Float):Float
  {
    var damp:Float = 1.4;
    var count:Float = 6;
    return (t < .5 ? tapElastic(t * 2) : -popElastic(t * 2 - 1));
  }

  public static inline function impulse(t:Float):Float
  {
    var damp:Float = 0.9;
    t = Math.pow(t, damp);
    return t * (Math.pow(1000, -t) - 0.001) * 18.6;
  }

  public static inline function instant(t:Float):Float
  {
    return 1;
  }

  // Out in eases!
  public static inline function quadOutIn(t:Float):Float
  {
    t *= 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow(1 - t, 2) : 0.5 + 0.5 * Math.pow(t - 1, 2);
  }

  public static inline function sineOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.sineOut(t * 2) * 0.5 : FlxEase.sineIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function bounceOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.bounceOut(t * 2) * 0.5 : FlxEase.bounceIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function circOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.circOut(t * 2) * 0.5 : FlxEase.circIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function quintOutIn(t:Float):Float
  {
    t *= 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow(1 - t, 5) : 0.5 + 0.5 * Math.pow(t - 1, 5);
  }

  public static inline function quartOutIn(t:Float):Float
  {
    t *= 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow(1 - t, 4) : 0.5 + 0.5 * Math.pow(t - 1, 4);
  }

  public static inline function cubeOutIn(t:Float):Float
  {
    t *= 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow(1 - t, 3) : 0.5 + 0.5 * Math.pow(t - 1, 3);
  }

  // convert notitg / mirin stuff to regular haxe name lmao
  public static inline function outInQuad(t:Float):Float
  {
    return quadOutIn(t);
  }

  public static inline function inOutQuad(t:Float):Float
  {
    return FlxEase.quadInOut(t);
  }

  public static inline function outQuad(t:Float):Float
  {
    return FlxEase.quadOut(t);
  }

  public static inline function inQuad(t:Float):Float
  {
    return FlxEase.quadIn(t);
  }

  public static inline function inOutSine(t:Float):Float
  {
    return FlxEase.sineInOut(t);
  }

  public static inline function outSine(t:Float):Float
  {
    return FlxEase.sineOut(t);
  }

  public static inline function outInSine(t:Float):Float
  {
    return sineOutIn(t);
  }

  public static inline function inSine(t:Float):Float
  {
    return FlxEase.sineIn(t);
  }

  public static inline function outCube(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function inCube(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function inOutCube(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function outInCube(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function outCubic(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function inCubic(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function inOutCubic(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function outInCubic(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function cubicOut(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function cubicIn(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function cubicInOut(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function cubicOutIn(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function expoIn(t:Float):Float
  {
    return FlxEase.expoIn(t); // this one works just fine, where as the other math ends not at 1.0 but at 0.999
    // return Math.pow(1000, (t - 1)) - 0.001;
  }

  public static inline function expoOut(t:Float):Float
  {
    return 1.001 - Math.pow(1000, -t);
  }

  public static inline function expoInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(1000, (t - 1)) - 0.0005 : 1.0005 - 0.5 * Math.pow(1000, (1 - t));
  }

  public static inline function expoOutIn(t:Float):Float
  {
    return t < 0.5 ? expoOut(t * 2) * 0.5 : expoIn(t * 2 - 1) * 0.5 + 0.5;
  }

  public static inline function outExpo(t:Float):Float
  {
    return expoOut(t);
  }

  public static inline function inExpo(t:Float):Float
  {
    return expoIn(t);
  }

  public static inline function inOutExpo(t:Float):Float
  {
    return expoInOut(t);
  }

  public static inline function outInExpo(t:Float):Float
  {
    return expoOutIn(t);
  }

  public static inline function outBounce(t:Float):Float
  {
    return FlxEase.bounceOut(t);
  }

  public static inline function inBounce(t:Float):Float
  {
    return FlxEase.bounceIn(t);
  }

  public static inline function inOutBounce(t:Float):Float
  {
    return FlxEase.bounceInOut(t);
  }

  public static inline function outInBounce(t:Float):Float
  {
    return bounceOutIn(t);
  }

  public static inline function outCirc(t:Float):Float
  {
    return FlxEase.circOut(t);
  }

  public static inline function inCirc(t:Float):Float
  {
    return FlxEase.circIn(t);
  }

  public static inline function inOutCirc(t:Float):Float
  {
    return FlxEase.circInOut(t);
  }

  public static inline function outInCirc(t:Float):Float
  {
    return circOutIn(t);
  }

  public static inline function outInQuint(t:Float):Float
  {
    return quintOutIn(t);
  }

  public static inline function outQuint(t:Float):Float
  {
    return FlxEase.quintOut(t);
  }

  public static inline function inQuint(t:Float):Float
  {
    return FlxEase.quintIn(t);
  }

  public static inline function inOutQuint(t:Float):Float
  {
    return FlxEase.quintInOut(t);
  }

  public static inline function inOutQuart(t:Float):Float
  {
    return FlxEase.quartInOut(t);
  }

  public static inline function outInQuart(t:Float):Float
  {
    return quartOutIn(t);
  }

  public static inline function inQuart(t:Float):Float
  {
    return FlxEase.quartIn(t);
  }

  public static inline function outQuart(t:Float):Float
  {
    return FlxEase.quartOut(t);
  }

  public static inline function outElastic(t:Float):Float
  {
    return elasticOut(t);
  }

  public static inline function elasticOut(t:Float):Float
  {
    // goofy ass fix elasticOut(1.0) returning 1.009711 or some shit
    return t >= 1.0 ? 1.0 : FlxEase.elasticOut(t);
  }

  public static inline function inElastic(t:Float):Float
  {
    return FlxEase.elasticIn(t);
  }

  public static inline function inOutElastic(t:Float):Float
  {
    return FlxEase.elasticInOut(t);
  }

  public static inline function outInElastic(t:Float):Float
  {
    return elasticOutIn(t);
  }

  public static inline function elasticOutIn(t:Float):Float
  {
    var a:Float = 1;
    var p:Float = 0.3;
    return t < 0.5 ? 0.5 * outElasticInternal(t * 2, a, p) : 0.5 + 0.5 * inElasticInternal(t * 2 - 1, a, p);
  }

  public static inline function outElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return a * Math.pow(2, -10 * t) * Math.sin((t - p / (2 * Math.PI) * Math.asin(1 / a)) * 2 * Math.PI / p) + 1;
  }

  public static inline function inElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return 1 - outElasticInternal(1 - t, a, p);
  }

  public static inline function outBack(t:Float):Float
  {
    return FlxEase.backOut(t);
  }

  public static inline function inBack(t:Float):Float
  {
    return FlxEase.backIn(t);
  }

  public static inline function inOutBack(t:Float):Float
  {
    return FlxEase.backInOut(t);
  }

  public static inline function backOutIn(t:Float):Float
  {
    return outInBack(t);
  }

  public static inline function outInBack(t:Float):Float
  {
    var a:Float = 1.70158;
    return t < 0.5 ? 0.5 * outBackInternal(t * 2, a) : 0.5 + 0.5 * inBackInternal(t * 2 - 1, a);
  }

  static inline function inBackInternal(t:Float, a:Float):Float
  {
    return t * t * (a * t + t - a);
  }

  static inline function outBackInternal(t:Float, a:Float):Float
  {
    t = t - 1;
    return t * t * ((a + 1) * t + a) + 1;
  }

  /** @since 4.3.0 */
  public static inline function inSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepIn(t);
  }

  /** @since 4.3.0 */
  public static inline function outSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepOut(t);
  }

  /** @since 4.3.0 */
  public static inline function inOutSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepInOut(t);
  }

  /** @since 4.3.0 */
  public static inline function inSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepIn(t);
  }

  /** @since 4.3.0 */
  public static inline function outSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepOut(t);
  }

  /** @since 4.3.0 */
  public static inline function inOutSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepInOut(t);
  }

  // v0.9.0a new:

  /** @since 4.3.0 */
  public static inline function outInSmoothStep(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.smoothStepOut(t * 2) * 0.5 : FlxEase.smoothStepIn(t * 2 - 1) * 0.5 + 0.5);
  }

  /** @since 4.3.0 */
  public static inline function smoothStepOutIn(t:Float):Float
  {
    return outInSmoothStep(t);
  }

  /** @since 4.3.0 */
  public static inline function outInSmootherStep(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.smootherStepOut(t * 2) * 0.5 : FlxEase.smootherStepIn(t * 2 - 1) * 0.5 + 0.5);
  }

  /** @since 4.3.0 */
  public static inline function smootherStepOutIn(t:Float):Float
  {
    return outInSmootherStep(t);
  }
}
