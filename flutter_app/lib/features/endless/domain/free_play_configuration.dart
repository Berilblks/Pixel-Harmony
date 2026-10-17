enum FreePlayPuzzleType { gradient, pixelColoring, mixed }

enum FreePlayDifficulty { relaxed, normal, hard, expert }

class FreePlayConfiguration {
  const FreePlayConfiguration({
    required this.puzzleType,
    required this.difficulty,
  });

  final FreePlayPuzzleType puzzleType;
  final FreePlayDifficulty difficulty;
}
