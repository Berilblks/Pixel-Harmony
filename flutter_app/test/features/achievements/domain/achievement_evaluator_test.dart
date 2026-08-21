import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_catalog.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_evaluator.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

void main() {
  const evaluator = AchievementEvaluator();

  test('catalog contains exactly the approved 14 achievements', () {
    expect(AchievementCatalog.definitions, hasLength(14));
    expect(
      AchievementCatalog.definitions.map((item) => item.id).toSet(),
      hasLength(14),
    );
  });

  for (final testCase in const [
    ('first_harmony', 'total', 1),
    ('ten_harmonies', 'total', 10),
    ('hundred_harmonies', 'total', 100),
    ('journey_begins', 'journey', 10),
    ('halfway_there', 'journey', 50),
    ('journey_complete', 'journey', 100),
    ('endless_explorer', 'endless', 10),
    ('endless_wanderer', 'endless', 50),
    ('endless_devotion', 'endless', 100),
    ('daily_rhythm', 'streak', 7),
    ('daily_devotion', 'daily', 30),
    ('thousand_moves', 'moves', 1000),
  ]) {
    test('${testCase.$1} stays locked below and unlocks at threshold', () {
      PlayerStatistics statistics(int value) => switch (testCase.$2) {
        'total' => PlayerStatistics(totalPuzzlesCompleted: value),
        'journey' => PlayerStatistics(journeyPuzzlesCompleted: value),
        'endless' => PlayerStatistics(endlessPuzzlesCompleted: value),
        'daily' => PlayerStatistics(dailyPuzzlesCompleted: value),
        'streak' => PlayerStatistics(currentDailyStreak: value),
        'moves' => PlayerStatistics(totalMoves: value),
        _ => throw StateError('Unknown test metric.'),
      };

      final below = evaluator.evaluate(
        statistics: statistics(testCase.$3 - 1),
        completedJourneyLevelIds: const {},
        chapters: LevelCatalog.chapters,
      );
      final exact = evaluator.evaluate(
        statistics: statistics(testCase.$3),
        completedJourneyLevelIds: const {},
        chapters: LevelCatalog.chapters,
      );
      expect(below.byId(testCase.$1).unlocked, isFalse);
      expect(exact.byId(testCase.$1).unlocked, isTrue);
    });
  }

  test('chapter_master derives one complete chapter from Journey IDs', () {
    final completed = LevelCatalog.chapters.first.levelIds.toSet();
    final result = evaluator.evaluate(
      statistics: const PlayerStatistics(),
      completedJourneyLevelIds: completed,
      chapters: LevelCatalog.chapters,
    );

    expect(result.byId('chapter_master').unlocked, isTrue);
    expect(result.byId('chapter_master').currentValue, 1);
    expect(result.byId('perfect_journey').unlocked, isFalse);
  });

  test('perfect_journey derives all 10 complete chapters', () {
    final result = evaluator.evaluate(
      statistics: const PlayerStatistics(),
      completedJourneyLevelIds:
          LevelCatalog.levels.map((level) => level.id).toSet(),
      chapters: LevelCatalog.chapters,
    );

    expect(result.byId('chapter_master').unlocked, isTrue);
    expect(result.byId('perfect_journey').unlocked, isTrue);
    expect(result.byId('perfect_journey').currentValue, 10);
  });

  test('persisted achievement stays unlocked if values decrease', () {
    final result = evaluator.evaluate(
      statistics: const PlayerStatistics(),
      completedJourneyLevelIds: const {},
      chapters: LevelCatalog.chapters,
      unlockedAchievements: {'first_harmony': DateTime(2026, 8, 21)},
    );

    expect(result.byId('first_harmony').unlocked, isTrue);
  });

  test('evaluation is deterministic', () {
    final inputs = (
      statistics: const PlayerStatistics(totalPuzzlesCompleted: 10),
      ids: LevelCatalog.chapters.first.levelIds.toSet(),
    );
    final first = evaluator.evaluate(
      statistics: inputs.statistics,
      completedJourneyLevelIds: inputs.ids,
      chapters: LevelCatalog.chapters,
    );
    final second = evaluator.evaluate(
      statistics: inputs.statistics,
      completedJourneyLevelIds: inputs.ids,
      chapters: LevelCatalog.chapters,
    );

    expect(
      first.states.map(
        (item) => (item.definition.id, item.unlocked, item.currentValue),
      ),
      second.states.map(
        (item) => (item.definition.id, item.unlocked, item.currentValue),
      ),
    );
  });
}
