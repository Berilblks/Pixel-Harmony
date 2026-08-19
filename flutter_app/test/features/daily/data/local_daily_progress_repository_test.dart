import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/daily/data/daily_progress_local_data_source.dart';
import 'package:pixel_harmony/features/daily/data/local_daily_progress_repository.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';

void main() {
  test('progress survives repository recreation', () async {
    final dataSource = _MemoryDailyProgressDataSource();
    final first = LocalDailyProgressRepository(dataSource: dataSource);
    await first.complete('2026-08-19');

    final recreated = LocalDailyProgressRepository(dataSource: dataSource);
    expect(
      await recreated.read(),
      const DailyProgress(
        lastCompletedDateKey: '2026-08-19',
        currentStreak: 1,
        longestStreak: 1,
        totalDailyCompleted: 1,
      ),
    );
  });

  test('duplicate completion performs no second write', () async {
    final dataSource = _MemoryDailyProgressDataSource();
    final repository = LocalDailyProgressRepository(dataSource: dataSource);

    await repository.complete('2026-08-19');
    await repository.complete('2026-08-19');

    expect(dataSource.writeCount, 1);
  });

  test('failed persistence does not return falsely advanced state', () async {
    final repository = LocalDailyProgressRepository(
      dataSource: _MemoryDailyProgressDataSource(failWrites: true),
    );

    await expectLater(
      repository.complete('2026-08-19'),
      throwsA(isA<StateError>()),
    );
    expect(await repository.read(), const DailyProgress());
  });
}

class _MemoryDailyProgressDataSource implements DailyProgressLocalDataSource {
  _MemoryDailyProgressDataSource({this.failWrites = false});

  DailyProgress? value;
  final bool failWrites;
  int writeCount = 0;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<DailyProgress?> read() async => value;

  @override
  Future<void> write(DailyProgress progress) async {
    if (failWrites) throw StateError('write failed');
    writeCount++;
    value = progress;
  }
}
