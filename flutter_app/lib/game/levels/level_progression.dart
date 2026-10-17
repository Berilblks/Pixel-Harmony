import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';

class LevelProgression {
  LevelProgression({required List<LevelDefinition> levels})
    : levels = List.unmodifiable(levels),
      _journeyGenerator = null {
    final ids = levels.map((level) => level.id).toSet();
    if (ids.length != levels.length) {
      throw ArgumentError.value(levels, 'levels', 'Level IDs must be unique.');
    }
  }

  const LevelProgression.journey({
    JourneyLevelGenerator generator = const JourneyLevelGenerator(),
  }) : levels = const [],
       _journeyGenerator = generator;

  final List<LevelDefinition> levels;
  final JourneyLevelGenerator? _journeyGenerator;

  bool isUnlocked(String levelId, Set<String> completedLevelIds) {
    if (_journeyGenerator != null) {
      final number = _numberFromId(levelId);
      if (number == 1 || completedLevelIds.contains(levelId)) return true;
      return completedLevelIds.contains(
        JourneyLevelGenerator.levelId(number - 1),
      );
    }
    final index = _indexOf(levelId);
    if (index == 0 || completedLevelIds.contains(levelId)) {
      return true;
    }
    return completedLevelIds.contains(levels[index - 1].id);
  }

  LevelDefinition? previousLevel(String levelId) {
    if (_journeyGenerator case final generator?) {
      final number = _numberFromId(levelId);
      return number == 1 ? null : generator.generate(number - 1);
    }
    final index = _indexOf(levelId);
    return index == 0 ? null : levels[index - 1];
  }

  LevelDefinition? nextLevel(String levelId) {
    if (_journeyGenerator case final generator?) {
      return generator.generate(_numberFromId(levelId) + 1);
    }
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

  int _numberFromId(String levelId) {
    final match = RegExp(r'^level_(\d+)$').firstMatch(levelId);
    final number = match == null ? null : int.tryParse(match.group(1)!);
    if (number == null || number <= 0) {
      throw ArgumentError.value(levelId, 'levelId', 'Unknown level ID.');
    }
    return number;
  }
}
