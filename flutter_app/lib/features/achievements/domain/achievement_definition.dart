enum AchievementCategory { general, journey, endless, daily }

enum AchievementConditionType {
  totalPuzzles,
  journeyPuzzles,
  endlessPuzzles,
  dailyPuzzles,
  currentDailyStreak,
  completedChapters,
  totalMoves,
}

enum AchievementIconType { harmony, journey, endless, daily, chapter, moves }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconType,
    required this.category,
    required this.conditionType,
    required this.targetValue,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final AchievementIconType iconType;
  final AchievementCategory category;
  final AchievementConditionType conditionType;
  final int targetValue;
}
