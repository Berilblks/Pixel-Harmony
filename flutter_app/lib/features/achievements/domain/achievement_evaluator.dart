import 'package:pixel_harmony/features/achievements/domain/achievement_catalog.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_state.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/levels/chapter_definition.dart';

class AchievementEvaluator {
  const AchievementEvaluator();

  AchievementCollection evaluate({
    required PlayerStatistics statistics,
    required Set<String> completedJourneyLevelIds,
    required List<ChapterDefinition> chapters,
    Map<String, DateTime> unlockedAchievements = const {},
  }) {
    final completedChapters =
        chapters
            .where(
              (chapter) =>
                  chapter.levelIds.every(completedJourneyLevelIds.contains),
            )
            .length;
    return AchievementCollection([
      for (final definition in AchievementCatalog.definitions)
        AchievementState(
          definition: definition,
          currentValue: _currentValue(
            definition.conditionType,
            statistics,
            completedChapters,
          ),
          unlocked:
              unlockedAchievements.containsKey(definition.id) ||
              _currentValue(
                    definition.conditionType,
                    statistics,
                    completedChapters,
                  ) >=
                  definition.targetValue,
          unlockedAt: unlockedAchievements[definition.id],
        ),
    ]);
  }

  int _currentValue(
    AchievementConditionType condition,
    PlayerStatistics statistics,
    int completedChapters,
  ) => switch (condition) {
    AchievementConditionType.totalPuzzles => statistics.totalPuzzlesCompleted,
    AchievementConditionType.journeyPuzzles =>
      statistics.journeyPuzzlesCompleted,
    AchievementConditionType.endlessPuzzles =>
      statistics.endlessPuzzlesCompleted,
    AchievementConditionType.dailyPuzzles => statistics.dailyPuzzlesCompleted,
    AchievementConditionType.currentDailyStreak =>
      statistics.currentDailyStreak,
    AchievementConditionType.completedChapters => completedChapters,
    AchievementConditionType.totalMoves => statistics.totalMoves,
  };
}
