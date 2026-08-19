import 'package:pixel_harmony/game/levels/level_definition.dart';

class GeneratedLevel {
  GeneratedLevel({
    required this.id,
    required this.seed,
    required this.boardSize,
    required List<LevelTileDefinition> tiles,
    required List<String> initialTileOrder,
    required List<String> solutionTileOrder,
    required this.difficulty,
    required this.difficultyScore,
    required this.generationVersion,
    required this.candidateAttempts,
  }) : tiles = List.unmodifiable(tiles),
       initialTileOrder = List.unmodifiable(initialTileOrder),
       solutionTileOrder = List.unmodifiable(solutionTileOrder) {
    _validate();
  }

  final String id;
  final int seed;
  final int boardSize;
  final List<LevelTileDefinition> tiles;
  final List<String> initialTileOrder;
  final List<String> solutionTileOrder;
  final LevelDifficulty difficulty;
  final int difficultyScore;
  final int generationVersion;
  final int candidateAttempts;

  LevelDefinition toLevelDefinition({
    int number = 1,
    String nameKey = 'generatedLevel',
  }) {
    return LevelDefinition(
      id: id,
      number: number,
      nameKey: nameKey,
      boardSize: boardSize,
      difficulty: difficulty,
      difficultyScore: difficultyScore,
      tiles: tiles,
      initialTileOrder: initialTileOrder,
      solutionTileOrder: solutionTileOrder,
    );
  }

  void _validate() {
    if (id.isEmpty || boardSize < 3 || boardSize > 5) {
      throw ArgumentError('Generated level identity or board size is invalid.');
    }
    if (generationVersion <= 0 || candidateAttempts <= 0) {
      throw ArgumentError('Generation metadata must be positive.');
    }
    // Reuse the handcrafted model's strict tile/order/difficulty validation.
    toLevelDefinition();
  }
}
