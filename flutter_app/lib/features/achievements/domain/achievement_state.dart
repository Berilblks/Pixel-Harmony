import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';

class AchievementState {
  const AchievementState({
    required this.definition,
    required this.unlocked,
    required this.currentValue,
    this.unlockedAt,
  });

  final AchievementDefinition definition;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int currentValue;

  int get targetValue => definition.targetValue;
  int get displayedCurrentValue => currentValue.clamp(0, targetValue);
}

class AchievementCollection {
  AchievementCollection(List<AchievementState> states)
    : states = List.unmodifiable(states);

  final List<AchievementState> states;

  AchievementState byId(String id) =>
      states.firstWhere((state) => state.definition.id == id);
}
