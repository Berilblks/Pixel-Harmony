import 'package:pixel_harmony/game/levels/chapter_definition.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/journey_variety.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class LevelNameKeys {
  static const numbered = 'numberedLevel';
}

abstract final class LevelCatalog {
  static const JourneyLevelGenerator generator = JourneyLevelGenerator();
  static final List<LevelDefinition> levels = List.unmodifiable([
    for (var number = 1; number <= 100; number++) generator.generate(number),
  ]);
  static final List<ChapterDefinition> chapters = List.unmodifiable([
    for (var order = 0; order < 10; order++) _segment(order),
  ]);
  static final bool _isValid = _validateCatalog();

  static LevelDefinition byId(String id) {
    final level = findById(id);
    if (level == null) {
      throw ArgumentError.value(id, 'id', 'Unknown Journey level ID.');
    }
    return level;
  }

  static LevelDefinition byNumber(int number) {
    _ensureValid();
    return generator.generate(number);
  }

  static LevelDefinition? findById(String id) {
    _ensureValid();
    final number = numberFromId(id);
    return number == null ? null : generator.generate(number);
  }

  static int? numberFromId(String id) {
    final match = RegExp(r'^level_(\d+)$').firstMatch(id);
    final number = match == null ? null : int.tryParse(match.group(1)!);
    return number != null && number > 0 ? number : null;
  }

  static ChapterDefinition chapterForLevel(String levelId) {
    final number = numberFromId(levelId);
    if (number == null) throw ArgumentError.value(levelId, 'levelId');
    return number <= 100
        ? chapters[(number - 1) ~/ 10]
        : dynamicChapterFor(number);
  }

  static ChapterDefinition dynamicChapterFor(int levelNumber) {
    if (levelNumber <= 100) return chapters[(levelNumber - 1) ~/ 10];
    final order = (levelNumber - 1) ~/ 10;
    final first = order * 10 + 1;
    return ChapterDefinition(
      id: 'journey_segment_${order + 1}',
      nameKey: 'journeySegmentName',
      descriptionKey: 'journeySegmentDescription',
      order: order,
      levelIds: [
        for (var n = first; n < first + 10; n++)
          JourneyLevelGenerator.levelId(n),
      ],
      visualTag: 'journey_milestone',
    );
  }

  static List<ChapterDefinition> chaptersThrough(int levelNumber) {
    final lastOrder = (levelNumber.clamp(1, 1 << 30) - 1) ~/ 10;
    return [
      ...chapters.take((lastOrder + 1).clamp(0, chapters.length)),
      for (var order = 10; order <= lastOrder; order++)
        dynamicChapterFor(order * 10 + 1),
    ];
  }

  static void validate() => _ensureValid();
  static void _ensureValid() {
    if (!_isValid) throw StateError('Invalid Journey catalog.');
  }

  static bool _validateCatalog() {
    if (levels.length != 100 || chapters.length != 10) {
      throw StateError('Invalid first milestone.');
    }
    for (final level in levels) {
      if (level.boardSize != generator.boardSizeFor(level.number)) {
        throw StateError('Invalid size at ${level.id}.');
      }
    }
    JourneyVariety.validateAdjacent(levels);
    return true;
  }
}

ChapterDefinition _segment(int order) => ChapterDefinition(
  id: 'journey_segment_${order + 1}',
  nameKey: 'journeySegmentName',
  descriptionKey: 'journeySegmentDescription',
  order: order,
  levelIds: [
    for (var n = order * 10 + 1; n <= (order + 1) * 10; n++)
      JourneyLevelGenerator.levelId(n),
  ],
  visualTag: 'journey_milestone',
);
