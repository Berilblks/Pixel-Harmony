import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

void main() {
  final solution = PuzzleSolution(tileIds: const ['a', 'b', 'c', 'd']);

  test('solved tile ID order matches', () {
    expect(solution.matches(const ['a', 'b', 'c', 'd']), isTrue);
  });

  test('unsolved tile ID order does not match', () {
    expect(solution.matches(const ['b', 'a', 'c', 'd']), isFalse);
  });

  test('a different number of tile IDs does not match', () {
    expect(solution.matches(const ['a', 'b', 'c']), isFalse);
  });

  test('duplicate solution tile IDs are rejected', () {
    expect(
      () => PuzzleSolution(tileIds: const ['a', 'a']),
      throwsArgumentError,
    );
  });
}
