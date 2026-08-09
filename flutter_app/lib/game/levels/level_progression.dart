import 'package:pixel_harmony/game/levels/level_definition.dart';

class LevelProgression {
  LevelProgression({required List<LevelDefinition> levels})
    : levels = List.unmodifiable(levels) {
    final ids = levels.map((level) => level.id).toSet();
    if (ids.length != levels.length) {
      throw ArgumentError.value(levels, 'levels', 'Level IDs must be unique.');
    }
  }

  final List<LevelDefinition> levels;

  bool isUnlocked(String levelId, Set<String> completedLevelIds) {
    final index = _indexOf(levelId);
    if (index == 0 || completedLevelIds.contains(levelId)) {
      return true;
    }
    return completedLevelIds.contains(levels[index - 1].id);
  }

  LevelDefinition? previousLevel(String levelId) {
    final index = _indexOf(levelId);
    return index == 0 ? null : levels[index - 1];
  }

  LevelDefinition? nextLevel(String levelId) {
    final index = _indexOf(levelId);
    return index == levels.length - 1 ? null : levels[index + 1];
  }

  int _indexOf(String levelId) {
    final index = levels.indexWhere((level) => level.id == levelId);
    if (index == -1) {
      throw ArgumentError.value(levelId, 'levelId', 'Unknown level ID.');
    }
    return index;
  }
}
