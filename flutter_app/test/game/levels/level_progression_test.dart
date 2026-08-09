import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';

void main() {
  final progression = LevelProgression(levels: LevelCatalog.levels);

  test('only Level 1 is unlocked with empty progress', () {
    expect(progression.isUnlocked('level_001', const {}), isTrue);
    expect(progression.isUnlocked('level_002', const {}), isFalse);
    expect(progression.isUnlocked('level_003', const {}), isFalse);
  });

  test('completing Level 1 unlocks Level 2 but not Level 3', () {
    const completed = {'level_001'};

    expect(progression.isUnlocked('level_002', completed), isTrue);
    expect(progression.isUnlocked('level_003', completed), isFalse);
  });

  test('completing Level 2 unlocks Level 3', () {
    expect(progression.isUnlocked('level_003', const {'level_002'}), isTrue);
  });

  test(
    'a completed level remains playable even with out-of-order progress',
    () {
      expect(progression.isUnlocked('level_003', const {'level_003'}), isTrue);
    },
  );

  test('previous and next levels follow catalog order', () {
    expect(progression.previousLevel('level_001'), isNull);
    expect(progression.previousLevel('level_003')?.id, 'level_002');
    expect(progression.nextLevel('level_001')?.id, 'level_002');
    expect(progression.nextLevel('level_003'), isNull);
  });
}
