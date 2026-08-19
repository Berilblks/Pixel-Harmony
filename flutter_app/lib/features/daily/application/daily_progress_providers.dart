import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/daily/data/daily_progress_local_data_source.dart';
import 'package:pixel_harmony/features/daily/data/local_daily_progress_repository.dart';
import 'package:pixel_harmony/features/daily/data/shared_preferences_daily_progress_data_source.dart';
import 'package:pixel_harmony/features/daily/domain/daily_clock.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress_repository.dart';
import 'package:pixel_harmony/features/daily/domain/daily_puzzle_identity.dart';

final dailyClockProvider = Provider<DailyClock>((ref) {
  return const SystemDailyClock();
});

final dailyPuzzleIdentityProvider = Provider<DailyPuzzleIdentity>((ref) {
  return DailyPuzzleIdentity.forLocalDate(ref.watch(dailyClockProvider).now());
});

final dailyProgressLocalDataSourceProvider =
    Provider<DailyProgressLocalDataSource>((ref) {
      return SharedPreferencesDailyProgressDataSource();
    });

final dailyProgressRepositoryProvider = Provider<DailyProgressRepository>((
  ref,
) {
  return LocalDailyProgressRepository(
    dataSource: ref.watch(dailyProgressLocalDataSourceProvider),
  );
});

final dailyProgressControllerProvider =
    AsyncNotifierProvider<DailyProgressController, DailyProgress>(
      DailyProgressController.new,
    );

class DailyProgressController extends AsyncNotifier<DailyProgress> {
  Future<DailyProgress?>? _completionOperation;

  @override
  Future<DailyProgress> build() {
    return ref.watch(dailyProgressRepositoryProvider).read();
  }

  Future<DailyProgress?> complete(String dateKey) {
    final active = _completionOperation;
    if (active != null) return active;
    final operation = _complete(dateKey);
    _completionOperation = operation;
    return operation.whenComplete(() => _completionOperation = null);
  }

  Future<DailyProgress?> _complete(String dateKey) async {
    try {
      final persisted = await ref
          .read(dailyProgressRepositoryProvider)
          .complete(dateKey);
      state = AsyncData(persisted);
      return persisted;
    } catch (error, stackTrace) {
      // Keep the stored state authoritative. Gameplay completion remains usable.
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
