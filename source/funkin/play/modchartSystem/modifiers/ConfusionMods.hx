package funkin.play.modchartSystem.modifiers;

import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.notes.Strumline;
import flixel.math.FlxAngle;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to rotating the nots / strums!
// Notes spin as they approach the receptors

class DizzyMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleZ += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods

class Dizzy2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleZ += data.curPos / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors

class RollMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleX += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods

class Roll2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleX += data.curPos / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors

class TwirlMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleY += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods

class Twirl2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleY += data.curPos / 2.0 * currentValue;
  }
}

// Notes and strums will rotate constantly

class ConfusionMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  // eeeee nawh, I won't bother making this rad just to fuck with you lol

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleZ += beatTime * currentValue; // lol, nobody uses this mod XD
  }
}

// Rotate the strums on the z axis

class ConfusionZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleZ += currentValue * FlxAngle.TO_DEG;
  }
}

// Rotate the strums on the x axis

class ConfusionXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleX += currentValue * FlxAngle.TO_DEG;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleX += currentValue * FlxAngle.TO_DEG;
  }
}

// Rotate the strums on the y axis

class ConfusionYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleY += currentValue * FlxAngle.TO_DEG;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleY += currentValue * FlxAngle.TO_DEG;
  }
}

// Rotate the notes on the z axis

class NotesConfusionZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += currentValue * FlxAngle.TO_DEG;
  }
}

// Rotate the notes on the x axis

class NotesConfusionXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += currentValue * FlxAngle.TO_DEG;
  }
}

// Rotate the notes on the y axis

class NotesConfusionYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    invertForDad = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += currentValue * FlxAngle.TO_DEG;
  }
}
