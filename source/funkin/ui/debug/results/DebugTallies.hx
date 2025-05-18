package funkin.ui.debug.results;

import funkin.save.Save.SaveScoreTallyData;

/**
 * Just lil class to hold different score tallies for debug purposes
 */
class DebugTallies
{
  public static var LOSS:SaveScoreTallyData =
    {
      sick: 70,
      good: 5,
      bad: 2,
      shit: 1,
      missed: 1402,
      combo: 77,
      maxCombo: 77,
      totalNotesHit: 77,
      totalNotes: 1480
    };

  public static var NICE:SaveScoreTallyData =
    {
      sick: 69,
      good: 0,
      bad: 0,
      shit: 31,
      missed: 0,
      combo: 69,
      maxCombo: 69,
      totalNotesHit: 69,
      totalNotes: 100
    };

  public static var GOOD:SaveScoreTallyData =
    {
      sick: 82,
      good: 2,
      bad: 0,
      shit: 0,
      missed: 16,
      combo: 15,
      maxCombo: 60,
      totalNotesHit: 84,
      totalNotes: 100
    };

  public static var GREAT:SaveScoreTallyData =
    {
      sick: 86,
      good: 2,
      bad: 1,
      shit: 7,
      missed: 8,
      combo: 15,
      maxCombo: 60,
      totalNotesHit: 88,
      totalNotes: 99
    };

  public static var EXCELLENT:SaveScoreTallyData =
    {
      sick: 94,
      good: 3,
      bad: 1,
      shit: 1,
      missed: 5,
      combo: 4,
      maxCombo: 90,
      totalNotesHit: 94,
      totalNotes: 100
    };

  public static var PERFECT:SaveScoreTallyData =
    {
      sick: 189,
      good: 11,
      bad: 0,
      shit: 0,
      missed: 0,
      combo: 200,
      maxCombo: 200,
      totalNotesHit: 200,
      totalNotes: 200
    };

  public static var PERFECT_GOLD:SaveScoreTallyData =
    {
      sick: 200,
      good: 0,
      bad: 0,
      shit: 0,
      missed: 0,
      combo: 200,
      maxCombo: 200,
      totalNotesHit: 200,
      totalNotes: 200
    };

  public static function getTallyForRank(rank:DebugRank):SaveScoreTallyData
  {
    return switch (rank)
    {
      case LOSS_RANK: LOSS;
      case NICE_RANK: NICE;
      case GOOD_RANK: GOOD;
      case GREAT_RANK: GREAT;
      case EXCELLENT_RANK: EXCELLENT;
      case PERFECT_RANK: PERFECT;
      case PERFECTGOLD_RANK: PERFECT_GOLD;
    }
  }

  public static var DEBUG_RANKS:Array<DebugRank> = [
    LOSS_RANK,
    NICE_RANK,
    GOOD_RANK,
    GREAT_RANK,
    EXCELLENT_RANK,
    PERFECT_RANK,
    PERFECTGOLD_RANK
  ];
}

enum abstract DebugRank(String) from String to String
{
  var LOSS_RANK = "Loss";
  var NICE_RANK = "Nice";
  var GOOD_RANK = "Good";
  var GREAT_RANK = "Great";
  var EXCELLENT_RANK = "Excellent";
  var PERFECT_RANK = "Perfect";
  var PERFECTGOLD_RANK = "Perfect Gold";
}
