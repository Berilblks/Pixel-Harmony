import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';

void main() {
  test('first completion starts streak and duplicate is idempotent', () {
    const empty = DailyProgress();
    final completed = empty.complete('2026-08-19');

    expect(completed.currentStreak, 1);
    expect(completed.longestStreak, 1);
    expect(completed.totalDailyCompleted, 1);
    expect(completed.complete('2026-08-19'), same(completed));
  });

  test('consecutive completion increments streak and longest streak', () {
    final progress = const DailyProgress()
        .complete('2026-08-19')
        .complete('2026-08-20');

    expect(progress.currentStreak, 2);
    expect(progress.longestStreak, 2);
    expect(progress.totalDailyCompleted, 2);
  });

  test('gap resets current streak without reducing longest streak', () {
    final progress = const DailyProgress()
        .complete('2026-08-19')
        .complete('2026-08-20')
        .complete('2026-08-23');

    expect(progress.currentStreak, 1);
    expect(progress.longestStreak, 2);
    expect(progress.totalDailyCompleted, 3);
  });

  test('moving the clock backwards does not corrupt progress', () {
    final progress = const DailyProgress().complete('2026-08-19');

    expect(progress.complete('2026-08-18'), same(progress));
  });

  test('invalid date keys are rejected', () {
    expect(
      () => const DailyProgress().complete('2026-02-30'),
      throwsFormatException,
    );
  });
}
