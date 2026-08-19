import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

void main() {
  test('default statistics are empty', () {
    expect(const PlayerStatistics(), const PlayerStatistics());
  });

  test('mode completions accumulate counters and moves', () {
    final statistics = const PlayerStatistics()
        .record(
          const PuzzleCompletionRecord(
            id: 'journey:level_001',
            mode: PuzzleCompletionMode.journey,
            moveCount: 1,
          ),
        )
        .record(
          const PuzzleCompletionRecord(
            id: 'endless:v1:1',
            mode: PuzzleCompletionMode.endless,
            moveCount: 3,
          ),
        )
        .record(
          const PuzzleCompletionRecord(
            id: 'daily:v1:2026-08-19',
            mode: PuzzleCompletionMode.daily,
            moveCount: 2,
            currentDailyStreak: 4,
            bestDailyStreak: 7,
          ),
        );

    expect(statistics.totalPuzzlesCompleted, 3);
    expect(statistics.journeyPuzzlesCompleted, 1);
    expect(statistics.endlessPuzzlesCompleted, 1);
    expect(statistics.dailyPuzzlesCompleted, 1);
    expect(statistics.totalMoves, 6);
    expect(statistics.currentDailyStreak, 4);
    expect(statistics.bestDailyStreak, 7);
  });
}
