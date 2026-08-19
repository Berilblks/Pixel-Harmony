import 'package:pixel_harmony/game/levels/level_definition.dart';

class ProceduralLevelRequest {
  ProceduralLevelRequest({
    required this.seed,
    required this.boardSize,
    required this.targetDifficulty,
    this.paletteSeed,
    this.generatedLevelId,
  }) {
    if (boardSize < 3 || boardSize > 5) {
      throw ArgumentError.value(
        boardSize,
        'boardSize',
        'Procedural boards must be 3x3, 4x4, or 5x5.',
      );
    }
    if (targetDifficulty == LevelDifficulty.tutorial) {
      throw ArgumentError.value(
        targetDifficulty,
        'targetDifficulty',
        'Procedural tutorial levels are not supported.',
      );
    }
    if (generatedLevelId case final id? when id.trim().isEmpty) {
      throw ArgumentError.value(id, 'generatedLevelId', 'Must not be empty.');
    }
  }

  final int seed;
  final int boardSize;
  final LevelDifficulty targetDifficulty;
  final int? paletteSeed;
  final String? generatedLevelId;
}
