enum PuzzleCompletionMode { journey, endless, daily }

class PuzzleCompletionRecord {
  const PuzzleCompletionRecord({
    required this.id,
    required this.mode,
    required this.moveCount,
    this.currentDailyStreak,
    this.bestDailyStreak,
  });

  final String id;
  final PuzzleCompletionMode mode;
  final int moveCount;
  final int? currentDailyStreak;
  final int? bestDailyStreak;
}

class PlayerStatistics {
  const PlayerStatistics({
    this.totalPuzzlesCompleted = 0,
    this.journeyPuzzlesCompleted = 0,
    this.endlessPuzzlesCompleted = 0,
    this.dailyPuzzlesCompleted = 0,
    this.totalMoves = 0,
    this.bestDailyStreak = 0,
    this.currentDailyStreak = 0,
  });

  final int totalPuzzlesCompleted;
  final int journeyPuzzlesCompleted;
  final int endlessPuzzlesCompleted;
  final int dailyPuzzlesCompleted;
  final int totalMoves;
  final int bestDailyStreak;
  final int currentDailyStreak;

  PlayerStatistics record(PuzzleCompletionRecord completion) {
    if (completion.id.isEmpty || completion.moveCount < 0) {
      throw ArgumentError('Completion identity and move count are invalid.');
    }
    final isDaily = completion.mode == PuzzleCompletionMode.daily;
    if (isDaily &&
        (completion.currentDailyStreak == null ||
            completion.bestDailyStreak == null)) {
      throw ArgumentError('Daily completion requires authoritative streaks.');
    }
    return PlayerStatistics(
      totalPuzzlesCompleted: totalPuzzlesCompleted + 1,
      journeyPuzzlesCompleted:
          journeyPuzzlesCompleted +
          (completion.mode == PuzzleCompletionMode.journey ? 1 : 0),
      endlessPuzzlesCompleted:
          endlessPuzzlesCompleted +
          (completion.mode == PuzzleCompletionMode.endless ? 1 : 0),
      dailyPuzzlesCompleted:
          dailyPuzzlesCompleted +
          (completion.mode == PuzzleCompletionMode.daily ? 1 : 0),
      totalMoves: totalMoves + completion.moveCount,
      currentDailyStreak:
          isDaily ? completion.currentDailyStreak! : currentDailyStreak,
      bestDailyStreak: isDaily ? completion.bestDailyStreak! : bestDailyStreak,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayerStatistics &&
      other.totalPuzzlesCompleted == totalPuzzlesCompleted &&
      other.journeyPuzzlesCompleted == journeyPuzzlesCompleted &&
      other.endlessPuzzlesCompleted == endlessPuzzlesCompleted &&
      other.dailyPuzzlesCompleted == dailyPuzzlesCompleted &&
      other.totalMoves == totalMoves &&
      other.bestDailyStreak == bestDailyStreak &&
      other.currentDailyStreak == currentDailyStreak;

  @override
  int get hashCode => Object.hash(
    totalPuzzlesCompleted,
    journeyPuzzlesCompleted,
    endlessPuzzlesCompleted,
    dailyPuzzlesCompleted,
    totalMoves,
    bestDailyStreak,
    currentDailyStreak,
  );
}
