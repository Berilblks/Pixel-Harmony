class PuzzleSolution {
  PuzzleSolution({required List<String> tileIds})
    : tileIds = List.unmodifiable(tileIds) {
    if (tileIds.toSet().length != tileIds.length) {
      throw ArgumentError.value(
        tileIds,
        'tileIds',
        'Solution tile IDs must be unique.',
      );
    }
  }

  final List<String> tileIds;

  bool matches(Iterable<String> currentTileIds) {
    final current = currentTileIds.toList(growable: false);
    if (current.length != tileIds.length) {
      return false;
    }

    for (var index = 0; index < tileIds.length; index++) {
      if (current[index] != tileIds[index]) {
        return false;
      }
    }
    return true;
  }
}
