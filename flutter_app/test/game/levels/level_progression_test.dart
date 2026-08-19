import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';

void main() {
  final levels = LevelCatalog.levels;
  final progression = LevelProgression(levels: levels);

  test('only Level 1 is unlocked with empty progress', () {
    for (var index = 0; index < levels.length; index++) {
      expect(
        progression.isUnlocked(levels[index].id, const {}),
        index == 0,
        reason: levels[index].id,
      );
    }
  });

  test('completing each level unlocks exactly the next catalog level', () {
    for (var index = 0; index < levels.length - 1; index++) {
      final completed = {levels[index].id};
      final next = levels[index + 1];

      expect(progression.isUnlocked(next.id, completed), isTrue);
      if (index + 2 < levels.length) {
        expect(
          progression.isUnlocked(levels[index + 2].id, completed),
          isFalse,
        );
      }
    }
  });

  test('Level 36 requires Level 35 completion', () {
    expect(progression.isUnlocked('level_036', const {}), isFalse);
    expect(progression.isUnlocked('level_036', const {'level_034'}), isFalse);
    expect(progression.isUnlocked('level_036', const {'level_035'}), isTrue);
  });

  test('completed levels remain playable even with out-of-order progress', () {
    for (final level in levels) {
      expect(progression.isUnlocked(level.id, {level.id}), isTrue);
    }
  });

  test('previous and next levels follow the complete catalog order', () {
    expect(progression.previousLevel(levels.first.id), isNull);
    expect(progression.nextLevel(levels.last.id), isNull);

    for (var index = 0; index < levels.length - 1; index++) {
      expect(progression.nextLevel(levels[index].id), levels[index + 1]);
      expect(progression.previousLevel(levels[index + 1].id), levels[index]);
    }
  });
}
