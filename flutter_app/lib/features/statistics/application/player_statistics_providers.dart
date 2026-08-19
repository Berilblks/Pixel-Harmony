import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/statistics/data/local_player_statistics_repository.dart';
import 'package:pixel_harmony/features/statistics/data/player_statistics_local_data_source.dart';
import 'package:pixel_harmony/features/statistics/data/shared_preferences_player_statistics_data_source.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics_repository.dart';

final playerStatisticsLocalDataSourceProvider =
    Provider<PlayerStatisticsLocalDataSource>((ref) {
      return SharedPreferencesPlayerStatisticsDataSource();
    });

final playerStatisticsRepositoryProvider = Provider<PlayerStatisticsRepository>(
  (ref) {
    return LocalPlayerStatisticsRepository(
      dataSource: ref.watch(playerStatisticsLocalDataSourceProvider),
    );
  },
);

final playerStatisticsControllerProvider =
    AsyncNotifierProvider<PlayerStatisticsController, PlayerStatistics>(
      PlayerStatisticsController.new,
    );

class PlayerStatisticsController extends AsyncNotifier<PlayerStatistics> {
  @override
  Future<PlayerStatistics> build() {
    return ref.watch(playerStatisticsRepositoryProvider).read();
  }

  Future<bool> record(PuzzleCompletionRecord completion) async {
    try {
      final updated = await ref
          .read(playerStatisticsRepositoryProvider)
          .record(completion);
      state = AsyncData(updated);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(playerStatisticsRepositoryProvider).read(),
    );
  }
}
