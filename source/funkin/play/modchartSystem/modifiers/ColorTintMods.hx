package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;

class RedNotesColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -2;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass) return;
    if (!isArrowPath)
    {
      data.red = currentValue;
    }
  }
}

class GreenNotesColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -3;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass) return;
    if (!isArrowPath)
    {
      data.green = currentValue;
    }
  }
}

class BlueNotesColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -4;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (data.inOrientPass) return;
    if (!isArrowPath)
    {
      data.blue = currentValue;
    }
  }
}

class RedStrumColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -2;
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass) return;
    data.red = currentValue;
  }
}

class GreenStrumColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -3;
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass) return;
    data.green = currentValue;
  }
}

class BlueStrumColMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = -4;
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (data.inOrientPass) return;
    data.blue = currentValue;
  }
}
