class LevelTileDefinition {
  const LevelTileDefinition({required this.id, required this.colorValue});

  final String id;
  final int colorValue;
}

enum LevelDifficulty { tutorial, easy, medium, hard, expert }

enum JourneyPuzzleType { gradient, pixelPicture }

class LevelDefinition {
  LevelDefinition({
    required this.id,
    required this.number,
    required this.nameKey,
    required this.boardSize,
    int? rowCount,
    int? columnCount,
    required this.difficulty,
    required this.difficultyScore,
    this.puzzleType = JourneyPuzzleType.gradient,
    this.pictureTemplateId,
    required List<LevelTileDefinition> tiles,
    required List<String> initialTileOrder,
    required List<String> solutionTileOrder,
  }) : rowCount = rowCount ?? boardSize,
       columnCount = columnCount ?? boardSize,
       tiles = List.unmodifiable(tiles),
       initialTileOrder = List.unmodifiable(initialTileOrder),
       solutionTileOrder = List.unmodifiable(solutionTileOrder) {
    _validate();
  }

  final String id;
  final int number;
  final String nameKey;
  final int boardSize;
  final int rowCount;
  final int columnCount;
  final LevelDifficulty difficulty;
  final int difficultyScore;
  final JourneyPuzzleType puzzleType;
  final String? pictureTemplateId;
  final List<LevelTileDefinition> tiles;
  final List<String> initialTileOrder;
  final List<String> solutionTileOrder;

  void _validate() {
    if (puzzleType == JourneyPuzzleType.pixelPicture &&
        (pictureTemplateId == null || pictureTemplateId!.isEmpty)) {
      throw ArgumentError.value(
        pictureTemplateId,
        'pictureTemplateId',
        'Pixel Picture levels require a template ID.',
      );
    }
    if (puzzleType == JourneyPuzzleType.gradient && pictureTemplateId != null) {
      throw ArgumentError.value(
        pictureTemplateId,
        'pictureTemplateId',
        'Gradient levels cannot reference a picture template.',
      );
    }
    if (number <= 0) {
      throw ArgumentError.value(number, 'number', 'Must be positive.');
    }
    if (boardSize <= 0 || rowCount <= 0 || columnCount <= 0) {
      throw ArgumentError.value(boardSize, 'boardSize', 'Must be positive.');
    }
    if (difficultyScore < 1 || difficultyScore > 100) {
      throw ArgumentError.value(
        difficultyScore,
        'difficultyScore',
        'Must be between 1 and 100.',
      );
    }
    final expectedRange = switch (difficulty) {
      LevelDifficulty.tutorial => (1, 10),
      LevelDifficulty.easy => (11, 30),
      LevelDifficulty.medium => (31, 55),
      LevelDifficulty.hard => (56, 80),
      LevelDifficulty.expert => (81, 100),
    };
    if (difficultyScore < expectedRange.$1 ||
        difficultyScore > expectedRange.$2) {
      throw ArgumentError.value(
        difficultyScore,
        'difficultyScore',
        'Does not match $difficulty.',
      );
    }

    final expectedTileCount = rowCount * columnCount;
    if (tiles.length != expectedTileCount) {
      throw ArgumentError.value(
        tiles.length,
        'tiles',
        'Expected $expectedTileCount tiles.',
      );
    }

    final tileIds = tiles.map((tile) => tile.id).toList(growable: false);
    if (tileIds.toSet().length != tileIds.length) {
      throw ArgumentError.value(tileIds, 'tiles', 'Tile IDs must be unique.');
    }

    _validateOrder(
      name: 'initialTileOrder',
      order: initialTileOrder,
      expectedTileCount: expectedTileCount,
      tileIds: tileIds.toSet(),
    );
    _validateOrder(
      name: 'solutionTileOrder',
      order: solutionTileOrder,
      expectedTileCount: expectedTileCount,
      tileIds: tileIds.toSet(),
    );
    if (puzzleType == JourneyPuzzleType.gradient &&
        _ordersMatch(initialTileOrder, solutionTileOrder)) {
      throw ArgumentError.value(
        initialTileOrder,
        'initialTileOrder',
        'Initial order must be different from the solution order.',
      );
    }
  }

  static bool _ordersMatch(List<String> first, List<String> second) {
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  static void _validateOrder({
    required String name,
    required List<String> order,
    required int expectedTileCount,
    required Set<String> tileIds,
  }) {
    if (order.length != expectedTileCount) {
      throw ArgumentError.value(
        order.length,
        name,
        'Expected $expectedTileCount tile IDs.',
      );
    }
    final orderIds = order.toSet();
    if (orderIds.length != order.length ||
        !orderIds.every(tileIds.contains) ||
        !tileIds.every(orderIds.contains)) {
      throw ArgumentError.value(
        order,
        name,
        'Order must contain every known tile ID exactly once.',
      );
    }
  }
}
