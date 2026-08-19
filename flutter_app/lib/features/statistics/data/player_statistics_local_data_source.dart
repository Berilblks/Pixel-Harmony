import 'package:pixel_harmony/features/statistics/data/player_statistics_snapshot.dart';

abstract interface class PlayerStatisticsLocalDataSource {
  Future<PlayerStatisticsSnapshot?> read();

  Future<void> write(PlayerStatisticsSnapshot snapshot);

  Future<void> clear();
}
