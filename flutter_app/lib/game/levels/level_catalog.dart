import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class LevelNameKeys {
  static const level1 = 'level1';
  static const level2 = 'level2';
  static const level3 = 'level3';
  static const level4 = 'level4';
  static const level5 = 'level5';
  static const level6 = 'level6';
  static const level7 = 'level7';
  static const level8 = 'level8';
  static const level9 = 'level9';
  static const level10 = 'level10';
  static const level11 = 'level11';
  static const level12 = 'level12';
}

abstract final class LevelCatalog {
  static final List<LevelDefinition> levels = List.unmodifiable([
    _level(
      number: 1,
      nameKey: LevelNameKeys.level1,
      boardSize: 2,
      colors: const [0xFF5BC0EB, 0xFF9BC53D, 0xFFFDE74C, 0xFFE55934],
      swaps: const [(0, 1)],
    ),
    _level(
      number: 2,
      nameKey: LevelNameKeys.level2,
      boardSize: 2,
      colors: const [0xFF4F86C6, 0xFF6FA8DC, 0xFFA4C2F4, 0xFFD9EAF7],
      swaps: const [(0, 1), (2, 3)],
    ),
    _level(
      number: 3,
      nameKey: LevelNameKeys.level3,
      boardSize: 3,
      colors: const [
        0xFF5BC0EB,
        0xFF6CC5D3,
        0xFF7DCAA9,
        0xFF8ECF80,
        0xFFA6D66A,
        0xFFC3DD5C,
        0xFFDFE451,
        0xFFF1E757,
        0xFFFDEB70,
      ],
      swaps: const [(0, 1), (6, 7)],
    ),
    _level(
      number: 4,
      nameKey: LevelNameKeys.level4,
      boardSize: 3,
      colors: const [
        0xFFFFD6A5,
        0xFFFFC58F,
        0xFFFFB37C,
        0xFFFFA36C,
        0xFFF58B65,
        0xFFEA7364,
        0xFFD95D69,
        0xFFC64D72,
        0xFFAD447A,
      ],
      swaps: const [(0, 4), (6, 8)],
    ),
    _level(
      number: 5,
      nameKey: LevelNameKeys.level5,
      boardSize: 3,
      colors: const [
        0xFFBDE0D5,
        0xFFA8D5C8,
        0xFF91C9BB,
        0xFF78B9AA,
        0xFF60A99B,
        0xFF4A988F,
        0xFF38847F,
        0xFF2E716F,
        0xFF285E61,
      ],
      swaps: const [(0, 3), (2, 8), (4, 6)],
    ),
    _level(
      number: 6,
      nameKey: LevelNameKeys.level6,
      boardSize: 3,
      colors: const [
        0xFFE4D7F5,
        0xFFD7C5EE,
        0xFFC9B2E5,
        0xFFB99FDA,
        0xFFA98BCF,
        0xFF9878C2,
        0xFF8768B2,
        0xFF75599F,
        0xFF634C8B,
      ],
      swaps: const [(0, 8), (1, 5), (2, 6), (3, 7)],
    ),
    _level(
      number: 7,
      nameKey: LevelNameKeys.level7,
      boardSize: 4,
      colors: const [
        0xFFE7F4E4,
        0xFFD8ECD5,
        0xFFC8E3C5,
        0xFFB7D9B6,
        0xFFA6CEAA,
        0xFF94C29F,
        0xFF82B594,
        0xFF70A789,
        0xFF60997F,
        0xFF518A76,
        0xFF447B6D,
        0xFF396C64,
        0xFF315D5B,
        0xFF2B4F51,
        0xFF274248,
        0xFF24363E,
      ],
      swaps: const [(0, 5), (3, 12), (6, 10), (9, 15)],
    ),
    _level(
      number: 8,
      nameKey: LevelNameKeys.level8,
      boardSize: 4,
      colors: const [
        0xFFFFE3D9,
        0xFFFFD5C8,
        0xFFFFC7B6,
        0xFFFFB9A5,
        0xFFF9AA98,
        0xFFF19A8D,
        0xFFE88984,
        0xFFDD797E,
        0xFFD16A7A,
        0xFFC25D78,
        0xFFB25176,
        0xFFA04774,
        0xFF8D3E70,
        0xFF79376A,
        0xFF653260,
        0xFF512D54,
      ],
      swaps: const [(0, 10), (1, 4), (3, 15), (6, 13), (8, 11)],
    ),
    _level(
      number: 9,
      nameKey: LevelNameKeys.level9,
      boardSize: 4,
      colors: const [
        0xFFDCEBFA,
        0xFFCCDDF2,
        0xFFBCCFEA,
        0xFFACC1E1,
        0xFF9CB3D8,
        0xFF8DA5CE,
        0xFF7F97C4,
        0xFF7289B9,
        0xFF667BAE,
        0xFF5B6DA2,
        0xFF525F95,
        0xFF495288,
        0xFF41467A,
        0xFF393A6B,
        0xFF322F5C,
        0xFF2B254D,
      ],
      swaps: const [(0, 14), (1, 7), (2, 9), (4, 12), (6, 15), (10, 13)],
    ),
    _level(
      number: 10,
      nameKey: LevelNameKeys.level10,
      boardSize: 4,
      colors: const [
        0xFFFFE8B8,
        0xFFFFDDA0,
        0xFFFFD089,
        0xFFFFC173,
        0xFFF8B064,
        0xFFEC9E5D,
        0xFFDE8C5C,
        0xFFCF7A60,
        0xFFBE6966,
        0xFFAB5A6C,
        0xFF974D71,
        0xFF824274,
        0xFF6D3973,
        0xFF58336E,
        0xFF442D65,
        0xFF322858,
      ],
      swaps: const [(0, 15), (1, 10), (2, 7), (4, 13), (5, 9), (8, 14)],
    ),
    _level(
      number: 11,
      nameKey: LevelNameKeys.level11,
      boardSize: 4,
      colors: const [
        0xFFDDF7F0,
        0xFFC9EFE8,
        0xFFB4E6E0,
        0xFF9FDDD8,
        0xFF8AD3D1,
        0xFF75C8CB,
        0xFF62BDC5,
        0xFF51B1C0,
        0xFF44A4BA,
        0xFF3B96B3,
        0xFF3788AA,
        0xFF37799F,
        0xFF3A6A92,
        0xFF3E5B83,
        0xFF424C72,
        0xFF433E60,
      ],
      swaps: const [
        (0, 11),
        (1, 6),
        (2, 14),
        (3, 8),
        (4, 15),
        (5, 12),
        (9, 13),
      ],
    ),
    _level(
      number: 12,
      nameKey: LevelNameKeys.level12,
      boardSize: 5,
      colors: const [
        0xFFDAF5EA,
        0xFFC8EDE5,
        0xFFB6E5E0,
        0xFFA5DCDD,
        0xFF95D2DA,
        0xFF86C8D7,
        0xFF79BDD4,
        0xFF6EB1D0,
        0xFF66A5CB,
        0xFF6198C5,
        0xFF608ABE,
        0xFF627CB5,
        0xFF666EAA,
        0xFF6C609E,
        0xFF735291,
        0xFF7A4582,
        0xFF813B72,
        0xFF873361,
        0xFF8B2E51,
        0xFF8C2D42,
        0xFF873337,
        0xFF7E3D31,
        0xFF71472F,
        0xFF625034,
        0xFF52573D,
      ],
      swaps: const [
        (0, 24),
        (1, 13),
        (2, 18),
        (3, 9),
        (4, 20),
        (5, 16),
        (6, 22),
        (8, 15),
        (11, 19),
      ],
    ),
  ]);

  static LevelDefinition byId(String id) {
    final level = findById(id);
    if (level == null) {
      throw ArgumentError.value(id, 'id', 'Unknown level ID.');
    }
    return level;
  }

  static LevelDefinition? findById(String id) {
    for (final level in levels) {
      if (level.id == id) {
        return level;
      }
    }
    return null;
  }
}

LevelDefinition _level({
  required int number,
  required String nameKey,
  required int boardSize,
  required List<int> colors,
  required List<(int, int)> swaps,
}) {
  final levelId = 'level_${number.toString().padLeft(3, '0')}';
  final solutionOrder = List.generate(
    colors.length,
    (index) => '${levelId}_tile_$index',
  );
  final initialOrder = List<String>.of(solutionOrder);
  for (final (first, second) in swaps) {
    final tileId = initialOrder[first];
    initialOrder[first] = initialOrder[second];
    initialOrder[second] = tileId;
  }

  return LevelDefinition(
    id: levelId,
    nameKey: nameKey,
    boardSize: boardSize,
    tiles: [
      for (var index = 0; index < colors.length; index++)
        LevelTileDefinition(
          id: '${levelId}_tile_$index',
          colorValue: colors[index],
        ),
    ],
    initialTileOrder: initialOrder,
    solutionTileOrder: solutionOrder,
  );
}
