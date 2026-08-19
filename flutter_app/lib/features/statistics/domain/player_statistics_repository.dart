import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

abstract interface class PlayerStatisticsRepository {
  Future<PlayerStatistics> read();

  Future<PlayerStatistics> record(PuzzleCompletionRecord completion);

  Future<void> clear();
}
