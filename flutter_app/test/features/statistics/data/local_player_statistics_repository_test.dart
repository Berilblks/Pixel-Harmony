import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/statistics/data/local_player_statistics_repository.dart';
import 'package:pixel_harmony/features/statistics/data/player_statistics_local_data_source.dart';
import 'package:pixel_harmony/features/statistics/data/player_statistics_snapshot.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

void main() {
  const journey = PuzzleCompletionRecord(
    id: 'journey:level_001',
    mode: PuzzleCompletionMode.journey,
    moveCount: 2,
  );

  test('empty repository returns default statistics', () async {
    final repository = LocalPlayerStatisticsRepository(
      dataSource: _MemoryStatisticsDataSource(),
    );

    expect(await repository.read(), const PlayerStatistics());
  });

  test('statistics persist across repository recreation', () async {
    final source = _MemoryStatisticsDataSource();
    await LocalPlayerStatisticsRepository(dataSource: source).record(journey);

    final recreated = LocalPlayerStatisticsRepository(dataSource: source);
    expect((await recreated.read()).journeyPuzzlesCompleted, 1);
    expect((await recreated.read()).totalMoves, 2);
  });

  test('duplicate identity is idempotent', () async {
    final repository = LocalPlayerStatisticsRepository(
      dataSource: _MemoryStatisticsDataSource(),
    );

    await repository.record(journey);
    final duplicate = await repository.record(journey);

    expect(duplicate.totalPuzzlesCompleted, 1);
    expect(duplicate.totalMoves, 2);
  });

  test('independent completion identities count separately', () async {
    final repository = LocalPlayerStatisticsRepository(
      dataSource: _MemoryStatisticsDataSource(),
    );
    await repository.record(journey);
    final result = await repository.record(
      const PuzzleCompletionRecord(
        id: 'journey:level_002',
        mode: PuzzleCompletionMode.journey,
        moveCount: 4,
      ),
    );

    expect(result.totalPuzzlesCompleted, 2);
    expect(result.journeyPuzzlesCompleted, 2);
    expect(result.totalMoves, 6);
  });

  test('Daily recording synchronizes authoritative streaks', () async {
    final repository = LocalPlayerStatisticsRepository(
      dataSource: _MemoryStatisticsDataSource(),
    );
    final result = await repository.record(
      const PuzzleCompletionRecord(
        id: 'daily:v1:2026-08-19',
        mode: PuzzleCompletionMode.daily,
        moveCount: 3,
        currentDailyStreak: 2,
        bestDailyStreak: 5,
      ),
    );

    expect(result.dailyPuzzlesCompleted, 1);
    expect(result.currentDailyStreak, 2);
    expect(result.bestDailyStreak, 5);
  });

  test('write failure does not expose advanced statistics', () async {
    final source = _MemoryStatisticsDataSource(failWrites: true);
    final repository = LocalPlayerStatisticsRepository(dataSource: source);

    await expectLater(repository.record(journey), throwsStateError);
    expect(await repository.read(), const PlayerStatistics());
  });
}

class _MemoryStatisticsDataSource implements PlayerStatisticsLocalDataSource {
  _MemoryStatisticsDataSource({this.failWrites = false});

  PlayerStatisticsSnapshot? snapshot;
  final bool failWrites;

  @override
  Future<void> clear() async => snapshot = null;

  @override
  Future<PlayerStatisticsSnapshot?> read() async => snapshot;

  @override
  Future<void> write(PlayerStatisticsSnapshot snapshot) async {
    if (failWrites) throw StateError('write failed');
    this.snapshot = snapshot;
  }
}
