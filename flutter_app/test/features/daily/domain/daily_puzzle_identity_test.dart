import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/daily/domain/daily_puzzle_identity.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

void main() {
  test('same local date produces the same stable identity', () {
    final first = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 8, 19, 1));
    final second = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 8, 19, 23));

    expect(first, second);
    expect(first.dateKey, '2026-08-19');
    expect(first.seed, 1390213367);
  });

  test('date and generation version affect the identity', () {
    final first = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 8, 19));
    final nextDay = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 8, 20));
    final nextVersion = DailyPuzzleIdentity.forLocalDate(
      DateTime(2026, 8, 19),
      generationVersion: 2,
    );

    expect(nextDay.seed, isNot(first.seed));
    expect(nextVersion.seed, isNot(first.seed));
  });

  test('Daily selection stays within supported MVP bands', () {
    for (var day = 1; day <= 28; day++) {
      final identity = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 2, day));
      expect(identity.boardSize, isIn([3, 4, 5]));
      expect(
        identity.targetDifficulty,
        isIn([LevelDifficulty.medium, LevelDifficulty.hard]),
      );
      if (identity.boardSize == 3) {
        expect(identity.targetDifficulty, LevelDifficulty.medium);
      }
      if (identity.boardSize == 5) {
        expect(identity.targetDifficulty, LevelDifficulty.hard);
      }
    }
  });

  test('same identity recreates the exact valid generated puzzle', () {
    final identity = DailyPuzzleIdentity.forLocalDate(DateTime(2026, 8, 19));
    const generator = ProceduralLevelGenerator();
    final request = ProceduralLevelRequest(
      seed: identity.seed,
      paletteSeed: identity.seed ^ 0x4441494c,
      boardSize: identity.boardSize,
      targetDifficulty: identity.targetDifficulty,
      generatedLevelId: 'daily_${identity.dateKey}',
    );

    final first = generator.generate(request);
    final second = generator.generate(request);
    expect(first.toLevelDefinition().id, 'daily_2026-08-19');
    expect(
      second.tiles.map((tile) => (tile.id, tile.colorValue)),
      first.tiles.map((tile) => (tile.id, tile.colorValue)),
    );
    expect(second.initialTileOrder, first.initialTileOrder);
    expect(second.solutionTileOrder, first.solutionTileOrder);
  });
}
