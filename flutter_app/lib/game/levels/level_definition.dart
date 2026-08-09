class LevelTileDefinition {
  const LevelTileDefinition({required this.id, required this.colorValue});

  final String id;
  final int colorValue;
}

class LevelDefinition {
  LevelDefinition({
    required this.id,
    required this.nameKey,
    required this.boardSize,
    required List<LevelTileDefinition> tiles,
    required List<String> initialTileOrder,
    required List<String> solutionTileOrder,
  }) : tiles = List.unmodifiable(tiles),
       initialTileOrder = List.unmodifiable(initialTileOrder),
       solutionTileOrder = List.unmodifiable(solutionTileOrder) {
    _validate();
  }

  final String id;
  final String nameKey;
  final int boardSize;
  final List<LevelTileDefinition> tiles;
  final List<String> initialTileOrder;
  final List<String> solutionTileOrder;

  void _validate() {
    if (boardSize <= 0) {
      throw ArgumentError.value(boardSize, 'boardSize', 'Must be positive.');
    }

    final expectedTileCount = boardSize * boardSize;
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
    if (_ordersMatch(initialTileOrder, solutionTileOrder)) {
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
