import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

class PlayerStatisticsSnapshot {
  PlayerStatisticsSnapshot({
    required this.statistics,
    required Set<String> processedCompletionIds,
  }) : processedCompletionIds = Set.unmodifiable(processedCompletionIds);

  const PlayerStatisticsSnapshot.empty()
    : statistics = const PlayerStatistics(),
      processedCompletionIds = const {};

  final PlayerStatistics statistics;
  final Set<String> processedCompletionIds;
}
