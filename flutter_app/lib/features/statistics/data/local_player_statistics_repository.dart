import 'package:pixel_harmony/features/statistics/data/player_statistics_local_data_source.dart';
import 'package:pixel_harmony/features/statistics/data/player_statistics_snapshot.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics_repository.dart';

class LocalPlayerStatisticsRepository implements PlayerStatisticsRepository {
  LocalPlayerStatisticsRepository({
    required PlayerStatisticsLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final PlayerStatisticsLocalDataSource _dataSource;
  Future<void> _operationQueue = Future.value();

  @override
  Future<PlayerStatistics> read() async =>
      (await _dataSource.read() ?? const PlayerStatisticsSnapshot.empty())
          .statistics;

  @override
  Future<PlayerStatistics> record(PuzzleCompletionRecord completion) {
    final operation = _operationQueue.then((_) async {
      final snapshot =
          await _dataSource.read() ?? const PlayerStatisticsSnapshot.empty();
      if (snapshot.processedCompletionIds.contains(completion.id)) {
        return snapshot.statistics;
      }
      final updated = PlayerStatisticsSnapshot(
        statistics: snapshot.statistics.record(completion),
        processedCompletionIds: {
          ...snapshot.processedCompletionIds,
          completion.id,
        },
      );
      await _dataSource.write(updated);
      return updated.statistics;
    });
    _operationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }

  @override
  Future<void> clear() async {
    await _operationQueue;
    await _dataSource.clear();
  }
}
