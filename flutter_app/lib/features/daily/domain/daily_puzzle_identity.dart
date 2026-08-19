import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class DailyPuzzleIdentity {
  const DailyPuzzleIdentity({
    required this.dateKey,
    required this.seed,
    required this.generationVersion,
    required this.boardSize,
    required this.targetDifficulty,
  });

  factory DailyPuzzleIdentity.forLocalDate(
    DateTime localDate, {
    int generationVersion = ProceduralLevelGenerator.generationVersion,
  }) {
    final dateKey = formatDateKey(localDate);
    final seed = stableSeed('$dailyNamespace|v$generationVersion|$dateKey');
    final selector = seed % 10;
    final (boardSize, difficulty) = switch (selector) {
      0 || 1 => (3, LevelDifficulty.medium),
      8 || 9 => (5, LevelDifficulty.hard),
      2 || 3 || 4 => (4, LevelDifficulty.medium),
      _ => (4, LevelDifficulty.hard),
    };
    return DailyPuzzleIdentity(
      dateKey: dateKey,
      seed: seed,
      generationVersion: generationVersion,
      boardSize: boardSize,
      targetDifficulty: difficulty,
    );
  }

  static const dailyNamespace = 'pixel_harmony.daily_puzzle';

  final String dateKey;
  final int seed;
  final int generationVersion;
  final int boardSize;
  final LevelDifficulty targetDifficulty;

  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static int stableSeed(String value) {
    var hash = 2166136261;
    for (final byte in value.codeUnits) {
      hash ^= byte;
      hash = (hash * 16777619) & 0xffffffff;
    }
    final seed = hash & 0x7fffffff;
    return seed == 0 ? 1 : seed;
  }

  @override
  bool operator ==(Object other) =>
      other is DailyPuzzleIdentity &&
      other.dateKey == dateKey &&
      other.seed == seed &&
      other.generationVersion == generationVersion &&
      other.boardSize == boardSize &&
      other.targetDifficulty == targetDifficulty;

  @override
  int get hashCode => Object.hash(
    dateKey,
    seed,
    generationVersion,
    boardSize,
    targetDifficulty,
  );
}
