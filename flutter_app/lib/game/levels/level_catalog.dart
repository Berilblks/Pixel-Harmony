import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class LevelNameKeys {
  static const level1 = 'level1';
  static const level2 = 'level2';
  static const level3 = 'level3';
}

abstract final class LevelCatalog {
  static final List<LevelDefinition> levels = List.unmodifiable([
    LevelDefinition(
      id: 'level_001',
      nameKey: LevelNameKeys.level1,
      boardSize: 2,
      tiles: const [
        LevelTileDefinition(id: 'level_001_tile_0', colorValue: 0xFF5BC0EB),
        LevelTileDefinition(id: 'level_001_tile_1', colorValue: 0xFF9BC53D),
        LevelTileDefinition(id: 'level_001_tile_2', colorValue: 0xFFFDE74C),
        LevelTileDefinition(id: 'level_001_tile_3', colorValue: 0xFFE55934),
      ],
      initialTileOrder: const [
        'level_001_tile_1',
        'level_001_tile_0',
        'level_001_tile_2',
        'level_001_tile_3',
      ],
      solutionTileOrder: const [
        'level_001_tile_0',
        'level_001_tile_1',
        'level_001_tile_2',
        'level_001_tile_3',
      ],
    ),
    LevelDefinition(
      id: 'level_002',
      nameKey: LevelNameKeys.level2,
      boardSize: 2,
      tiles: const [
        LevelTileDefinition(id: 'level_002_tile_0', colorValue: 0xFF4F86C6),
        LevelTileDefinition(id: 'level_002_tile_1', colorValue: 0xFF6FA8DC),
        LevelTileDefinition(id: 'level_002_tile_2', colorValue: 0xFFA4C2F4),
        LevelTileDefinition(id: 'level_002_tile_3', colorValue: 0xFFD9EAF7),
      ],
      initialTileOrder: const [
        'level_002_tile_1',
        'level_002_tile_0',
        'level_002_tile_3',
        'level_002_tile_2',
      ],
      solutionTileOrder: const [
        'level_002_tile_0',
        'level_002_tile_1',
        'level_002_tile_2',
        'level_002_tile_3',
      ],
    ),
    LevelDefinition(
      id: 'level_003',
      nameKey: LevelNameKeys.level3,
      boardSize: 3,
      tiles: const [
        LevelTileDefinition(id: 'level_003_tile_0', colorValue: 0xFF5BC0EB),
        LevelTileDefinition(id: 'level_003_tile_1', colorValue: 0xFF6CC5D3),
        LevelTileDefinition(id: 'level_003_tile_2', colorValue: 0xFF7DCAA9),
        LevelTileDefinition(id: 'level_003_tile_3', colorValue: 0xFF8ECF80),
        LevelTileDefinition(id: 'level_003_tile_4', colorValue: 0xFFA6D66A),
        LevelTileDefinition(id: 'level_003_tile_5', colorValue: 0xFFC3DD5C),
        LevelTileDefinition(id: 'level_003_tile_6', colorValue: 0xFFDFE451),
        LevelTileDefinition(id: 'level_003_tile_7', colorValue: 0xFFF1E757),
        LevelTileDefinition(id: 'level_003_tile_8', colorValue: 0xFFFDEB70),
      ],
      initialTileOrder: const [
        'level_003_tile_1',
        'level_003_tile_0',
        'level_003_tile_2',
        'level_003_tile_3',
        'level_003_tile_4',
        'level_003_tile_5',
        'level_003_tile_7',
        'level_003_tile_6',
        'level_003_tile_8',
      ],
      solutionTileOrder: const [
        'level_003_tile_0',
        'level_003_tile_1',
        'level_003_tile_2',
        'level_003_tile_3',
        'level_003_tile_4',
        'level_003_tile_5',
        'level_003_tile_6',
        'level_003_tile_7',
        'level_003_tile_8',
      ],
    ),
  ]);

  static LevelDefinition byId(String id) {
    return levels.firstWhere(
      (level) => level.id == id,
      orElse: () => throw ArgumentError.value(id, 'id', 'Unknown level ID.'),
    );
  }
}
