import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics_repository.dart';

class FakePlayerStatisticsRepository implements PlayerStatisticsRepository {
  FakePlayerStatisticsRepository({
    PlayerStatistics? statistics,
    this.failReads = false,
    this.failWrites = false,
  }) : statistics = statistics ?? const PlayerStatistics();

  PlayerStatistics statistics;
  final bool failReads;
  final bool failWrites;
  final Set<String> processedIds = {};
  int recordCallCount = 0;

  @override
  Future<void> clear() async {
    statistics = const PlayerStatistics();
    processedIds.clear();
  }

  @override
  Future<PlayerStatistics> read() async {
    if (failReads) throw StateError('statistics read failed');
    return statistics;
  }

  @override
  Future<PlayerStatistics> record(PuzzleCompletionRecord completion) async {
    recordCallCount++;
    if (failWrites) throw StateError('statistics write failed');
    if (processedIds.add(completion.id)) {
      statistics = statistics.record(completion);
    }
    return statistics;
  }
}
