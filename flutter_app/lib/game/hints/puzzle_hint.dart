class PuzzleHint {
  const PuzzleHint({
    required this.tileId,
    required this.currentIndex,
    required this.targetIndex,
  });

  final String tileId;
  final int currentIndex;
  final int targetIndex;
}
