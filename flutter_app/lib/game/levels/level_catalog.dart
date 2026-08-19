import 'package:pixel_harmony/game/levels/chapter_definition.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class LevelNameKeys {
  static const numbered = 'numberedLevel';
}

abstract final class ChapterKeys {
  static const calmStart = 'calmStart';
  static const ocean = 'ocean';
  static const forest = 'forest';
  static const sunset = 'sunset';
  static const lavender = 'lavender';
  static const aurora = 'aurora';
}

abstract final class LevelCatalog {
  static final List<LevelDefinition> levels = List.unmodifiable(
    _specs.map(_buildLevel),
  );

  static final List<ChapterDefinition> chapters = List.unmodifiable([
    _chapter(ChapterKeys.calmStart, 0, 1, 'soft_harmony'),
    _chapter(ChapterKeys.ocean, 1, 7, 'cool_water'),
    _chapter(ChapterKeys.forest, 2, 13, 'natural_green'),
    _chapter(ChapterKeys.sunset, 3, 19, 'warm_fade'),
    _chapter(ChapterKeys.lavender, 4, 25, 'soft_violet'),
    _chapter(ChapterKeys.aurora, 5, 31, 'night_glow'),
  ]);

  static final bool _isValid = _validateCatalog();

  static LevelDefinition byId(String id) {
    final level = findById(id);
    if (level == null) {
      throw ArgumentError.value(id, 'id', 'Unknown level ID.');
    }
    return level;
  }

  static LevelDefinition? findById(String id) {
    _ensureValid();
    for (final level in levels) {
      if (level.id == id) return level;
    }
    return null;
  }

  static ChapterDefinition chapterForLevel(String levelId) {
    _ensureValid();
    return chapters.firstWhere(
      (chapter) => chapter.levelIds.contains(levelId),
      orElse:
          () =>
              throw ArgumentError.value(
                levelId,
                'levelId',
                'Level does not belong to a chapter.',
              ),
    );
  }

  static void validate() => _ensureValid();

  static void _ensureValid() {
    if (!_isValid) throw StateError('The level catalog is invalid.');
  }

  static bool _validateCatalog() {
    if (levels.length != 36 || chapters.length != 6) {
      throw StateError('Expected exactly 36 levels and 6 chapters.');
    }
    if (levels.map((level) => level.id).toSet().length != levels.length ||
        chapters.map((chapter) => chapter.id).toSet().length !=
            chapters.length) {
      throw StateError('Catalog IDs must be unique.');
    }
    final chapterLevelIds =
        chapters.expand((chapter) => chapter.levelIds).toList();
    final catalogLevelIds = levels.map((level) => level.id).toList();
    if (chapterLevelIds.length != chapterLevelIds.toSet().length ||
        !_orderedEquals(chapterLevelIds, catalogLevelIds)) {
      throw StateError(
        'Every level must belong to one chapter in catalog order.',
      );
    }
    for (var index = 0; index < chapters.length; index++) {
      if (chapters[index].order != index ||
          chapters[index].levelIds.length != 6) {
        throw StateError('Chapter order and distribution must be contiguous.');
      }
    }
    for (final level in levels) {
      final expectedSize = switch (level.number) {
        <= 4 => 2,
        <= 12 => 3,
        <= 24 => 4,
        _ => 5,
      };
      if (level.boardSize != expectedSize) {
        throw StateError('Invalid board-size curve at ${level.id}.');
      }
    }
    return true;
  }
}

ChapterDefinition _chapter(String key, int order, int firstLevel, String tag) {
  return ChapterDefinition(
    id: key == ChapterKeys.calmStart ? 'calm_start' : key,
    nameKey: '${key}Name',
    descriptionKey: '${key}Description',
    order: order,
    levelIds: [
      for (var number = firstLevel; number < firstLevel + 6; number++)
        _levelId(number),
    ],
    visualTag: tag,
  );
}

const _specs = <_LevelSpec>[
  _LevelSpec(
    1,
    2,
    LevelDifficulty.tutorial,
    3,
    [0xFFB9E8F5, 0xFF82D4C7, 0xFFF7E98E, 0xFFF09B82],
    [(0, 1)],
  ),
  _LevelSpec(
    2,
    2,
    LevelDifficulty.tutorial,
    5,
    [0xFFC9EAF4, 0xFF7FCFD0, 0xFFF5D77A, 0xFFEC8A75],
    [(1, 3)],
  ),
  _LevelSpec(
    3,
    2,
    LevelDifficulty.tutorial,
    7,
    [0xFFD5EFF2, 0xFF91D8C1, 0xFFF2DD8C, 0xFFE98070],
    [(0, 2), (1, 3)],
  ),
  _LevelSpec(
    4,
    2,
    LevelDifficulty.tutorial,
    10,
    [0xFFBFE3EF, 0xFF78CBB8, 0xFFF0D36F, 0xFFE77365],
    [(0, 3), (1, 2)],
  ),
  _LevelSpec(
    5,
    3,
    LevelDifficulty.easy,
    14,
    [0xFFD6F0F3, 0xFF8ED7C8, 0xFFF1DE8D, 0xFFEA8272],
    [(0, 1), (4, 5)],
  ),
  _LevelSpec(
    6,
    3,
    LevelDifficulty.easy,
    18,
    [0xFFC8EAF2, 0xFF79CCBE, 0xFFF0D17A, 0xFFE97970],
    [(0, 4), (2, 8), (5, 7)],
  ),
  _LevelSpec(
    7,
    3,
    LevelDifficulty.easy,
    22,
    [0xFFD8FAF5, 0xFF75DAD2, 0xFF2E9DB5, 0xFF24527A],
    [(0, 1), (6, 7)],
  ),
  _LevelSpec(
    8,
    3,
    LevelDifficulty.easy,
    25,
    [0xFFC8F4EF, 0xFF63CCC9, 0xFF238BAA, 0xFF203F6B],
    [(0, 3), (2, 5), (7, 8)],
  ),
  _LevelSpec(
    9,
    3,
    LevelDifficulty.easy,
    28,
    [0xFFB8EEE9, 0xFF4FC0C2, 0xFF237C9F, 0xFF1D335F],
    [(0, 8), (1, 4), (2, 6)],
  ),
  _LevelSpec(
    10,
    3,
    LevelDifficulty.medium,
    32,
    [0xFFB2E9E5, 0xFF45B8BC, 0xFF216E96, 0xFF182A54],
    [(0, 6), (1, 7), (3, 5)],
  ),
  _LevelSpec(
    11,
    3,
    LevelDifficulty.medium,
    36,
    [0xFFA7E3DF, 0xFF39ADB5, 0xFF205F8B, 0xFF142449],
    [(0, 5), (1, 8), (2, 4), (3, 7)],
  ),
  _LevelSpec(
    12,
    3,
    LevelDifficulty.medium,
    40,
    [0xFF9EDDD9, 0xFF319FAE, 0xFF1D5480, 0xFF101D3F],
    [(0, 8), (1, 6), (2, 7), (3, 5)],
  ),
  _LevelSpec(
    13,
    4,
    LevelDifficulty.medium,
    43,
    [0xFFE2EBD2, 0xFFA8C889, 0xFF5E9360, 0xFF315B43],
    [(0, 1), (5, 6), (10, 11)],
  ),
  _LevelSpec(
    14,
    4,
    LevelDifficulty.medium,
    46,
    [0xFFD9E6C7, 0xFF98BC77, 0xFF4F8754, 0xFF2B503B],
    [(0, 4), (3, 7), (8, 12), (10, 15)],
  ),
  _LevelSpec(
    15,
    4,
    LevelDifficulty.medium,
    49,
    [0xFFD0E0BC, 0xFF88B165, 0xFF447B4B, 0xFF284735],
    [(0, 15), (1, 5), (6, 10), (11, 14)],
  ),
  _LevelSpec(
    16,
    4,
    LevelDifficulty.medium,
    52,
    [0xFFC8DAB2, 0xFF7AA657, 0xFF396F43, 0xFF253F30],
    [(0, 10), (2, 8), (3, 15), (5, 12), (7, 14)],
  ),
  _LevelSpec(
    17,
    4,
    LevelDifficulty.medium,
    54,
    [0xFFC0D4A8, 0xFF6D9B4D, 0xFF32653C, 0xFF22372B],
    [(0, 7), (1, 13), (3, 9), (4, 15), (6, 11)],
  ),
  _LevelSpec(
    18,
    4,
    LevelDifficulty.hard,
    57,
    [0xFFB8CE9E, 0xFF608F44, 0xFF2C5B36, 0xFF1F3027],
    [(0, 14), (1, 9), (2, 12), (4, 11), (6, 15), (7, 10)],
  ),
  _LevelSpec(
    19,
    4,
    LevelDifficulty.hard,
    59,
    [0xFFFFE0C2, 0xFFF5A078, 0xFFD85C68, 0xFF704A78],
    [(0, 5), (3, 7), (8, 9), (14, 15)],
  ),
  _LevelSpec(
    20,
    4,
    LevelDifficulty.hard,
    62,
    [0xFFFFD6B4, 0xFFF18F6D, 0xFFCF5064, 0xFF65436F],
    [(0, 12), (1, 6), (4, 9), (7, 15), (10, 13)],
  ),
  _LevelSpec(
    21,
    4,
    LevelDifficulty.hard,
    65,
    [0xFFFFCDA8, 0xFFED8065, 0xFFC44761, 0xFF5C3B68],
    [(0, 15), (2, 11), (3, 8), (5, 14), (6, 9)],
  ),
  _LevelSpec(
    22,
    4,
    LevelDifficulty.hard,
    68,
    [0xFFFFC39C, 0xFFE9725E, 0xFFB9405E, 0xFF533461],
    [(0, 9), (1, 14), (2, 7), (4, 12), (6, 15), (10, 13)],
  ),
  _LevelSpec(
    23,
    4,
    LevelDifficulty.hard,
    72,
    [0xFFFFBA91, 0xFFE46558, 0xFFAE395C, 0xFF492E5A],
    [(0, 13), (1, 8), (3, 15), (4, 10), (5, 12), (6, 14)],
  ),
  _LevelSpec(
    24,
    4,
    LevelDifficulty.hard,
    76,
    [0xFFFFB087, 0xFFDE5953, 0xFFA33359, 0xFF402853],
    [(0, 15), (1, 11), (2, 13), (3, 9), (4, 14), (5, 10), (6, 12)],
  ),
  _LevelSpec(
    25,
    5,
    LevelDifficulty.hard,
    78,
    [0xFFF0E4F5, 0xFFC9A7D8, 0xFF966Caa, 0xFF5B4D72],
    [(0, 1), (6, 7), (12, 13), (18, 19)],
  ),
  _LevelSpec(
    26,
    5,
    LevelDifficulty.hard,
    80,
    [0xFFEADCF1, 0xFFC09ACC, 0xFF895F9F, 0xFF514667],
    [(0, 5), (4, 9), (10, 15), (14, 19), (20, 24)],
  ),
  _LevelSpec(
    27,
    5,
    LevelDifficulty.expert,
    83,
    [0xFFE4D4ED, 0xFFB88EC1, 0xFF7C558F, 0xFF483F5C],
    [(0, 24), (1, 6), (7, 12), (13, 18), (19, 23)],
  ),
  _LevelSpec(
    28,
    5,
    LevelDifficulty.expert,
    86,
    [0xFFDECBE9, 0xFFAF82B7, 0xFF704B80, 0xFF403752],
    [(0, 18), (2, 22), (4, 20), (6, 14), (8, 16), (10, 24)],
  ),
  _LevelSpec(
    29,
    5,
    LevelDifficulty.expert,
    89,
    [0xFFD8C3E5, 0xFFA676AD, 0xFF654373, 0xFF382F49],
    [(0, 23), (1, 17), (3, 21), (5, 19), (7, 13), (9, 15), (11, 24)],
  ),
  _LevelSpec(
    30,
    5,
    LevelDifficulty.expert,
    91,
    [0xFFD2BBE1, 0xFF9D6AA3, 0xFF5B3B68, 0xFF302841],
    [(0, 24), (1, 20), (2, 16), (3, 12), (4, 8), (6, 18), (10, 22)],
  ),
  _LevelSpec(
    31,
    5,
    LevelDifficulty.expert,
    93,
    [0xFFB7F1E5, 0xFF4BC9D1, 0xFF7264C7, 0xFFCB4FA0, 0xFF25305F],
    [(0, 6), (4, 8), (12, 18), (20, 24)],
  ),
  _LevelSpec(
    32,
    5,
    LevelDifficulty.expert,
    94,
    [0xFFA9EADF, 0xFF3DBCC9, 0xFF6958BB, 0xFFBE4698, 0xFF202955],
    [(0, 19), (2, 14), (4, 22), (6, 12), (8, 16), (10, 24)],
  ),
  _LevelSpec(
    33,
    5,
    LevelDifficulty.expert,
    95,
    [0xFF9BE3D9, 0xFF32AFC1, 0xFF604DAD, 0xFFB03E90, 0xFF1B234B],
    [(0, 24), (1, 13), (3, 17), (5, 21), (7, 15), (9, 19), (11, 23)],
  ),
  _LevelSpec(
    34,
    5,
    LevelDifficulty.expert,
    97,
    [0xFF8DDCD3, 0xFF299FBA, 0xFF57469F, 0xFFA33688, 0xFF171E42],
    [(0, 23), (1, 18), (2, 15), (4, 20), (6, 24), (8, 12), (10, 22)],
  ),
  _LevelSpec(
    35,
    5,
    LevelDifficulty.expert,
    98,
    [0xFF80D5CD, 0xFF238FAF, 0xFF4F3F92, 0xFF962F81, 0xFF131A39],
    [(0, 24), (1, 21), (2, 17), (3, 13), (4, 9), (6, 18), (8, 22), (10, 20)],
  ),
  _LevelSpec(
    36,
    5,
    LevelDifficulty.expert,
    100,
    [0xFF73CEC7, 0xFF1E80A5, 0xFF473885, 0xFF89297A, 0xFF101630],
    [
      (0, 24),
      (1, 22),
      (2, 19),
      (3, 16),
      (4, 13),
      (5, 20),
      (6, 18),
      (7, 15),
      (8, 12),
    ],
  ),
];

class _LevelSpec {
  const _LevelSpec(
    this.number,
    this.boardSize,
    this.difficulty,
    this.score,
    this.stops,
    this.swaps,
  );
  final int number;
  final int boardSize;
  final LevelDifficulty difficulty;
  final int score;
  final List<int> stops;
  final List<(int, int)> swaps;
}

LevelDefinition _buildLevel(_LevelSpec spec) {
  final colors = _palette(spec.stops, spec.boardSize * spec.boardSize);
  final id = _levelId(spec.number);
  final solution = [
    for (var index = 0; index < colors.length; index++) '${id}_tile_$index',
  ];
  final initial = List<String>.of(solution);
  for (final (first, second) in spec.swaps) {
    final tileId = initial[first];
    initial[first] = initial[second];
    initial[second] = tileId;
  }
  return LevelDefinition(
    id: id,
    number: spec.number,
    nameKey: LevelNameKeys.numbered,
    boardSize: spec.boardSize,
    difficulty: spec.difficulty,
    difficultyScore: spec.score,
    tiles: [
      for (var index = 0; index < colors.length; index++)
        LevelTileDefinition(id: '${id}_tile_$index', colorValue: colors[index]),
    ],
    initialTileOrder: initial,
    solutionTileOrder: solution,
  );
}

List<int> _palette(List<int> stops, int count) {
  return List.generate(count, (index) {
    final position = index * (stops.length - 1) / (count - 1);
    final segment = position.floor().clamp(0, stops.length - 2);
    final amount = position - segment;
    return _blend(stops[segment], stops[segment + 1], amount);
  });
}

int _blend(int first, int second, double amount) {
  int channel(int shift) {
    final start = (first >> shift) & 0xFF;
    final end = (second >> shift) & 0xFF;
    return (start + (end - start) * amount).round();
  }

  return 0xFF000000 | (channel(16) << 16) | (channel(8) << 8) | channel(0);
}

String _levelId(int number) => 'level_${number.toString().padLeft(3, '0')}';

bool _orderedEquals(List<String> first, List<String> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
