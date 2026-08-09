import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/level_progress/data/level_progress_local_data_source.dart';
import 'package:pixel_harmony/features/level_progress/data/local_level_progress_repository.dart';
import 'package:pixel_harmony/features/level_progress/data/shared_preferences_level_progress_data_source.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';

final levelProgressLocalDataSourceProvider =
    Provider<LevelProgressLocalDataSource>((ref) {
      return SharedPreferencesLevelProgressDataSource();
    });

final levelProgressRepositoryProvider = Provider<LevelProgressRepository>((
  ref,
) {
  return LocalLevelProgressRepository(
    dataSource: ref.watch(levelProgressLocalDataSourceProvider),
  );
});

final levelProgressControllerProvider =
    AsyncNotifierProvider<LevelProgressController, Set<String>>(
      LevelProgressController.new,
    );

class LevelProgressController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final progress = await ref.watch(levelProgressRepositoryProvider).readAll();
    return Set.unmodifiable(
      progress.where((item) => item.completed).map((item) => item.levelId),
    );
  }

  Future<void> markCompleted(String levelId) async {
    final previous = state.value ?? const <String>{};
    if (previous.contains(levelId)) {
      return;
    }

    try {
      await ref.read(levelProgressRepositoryProvider).markCompleted(levelId);
      state = AsyncData(Set.unmodifiable({...previous, levelId}));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> clearAll() async {
    try {
      await ref.read(levelProgressRepositoryProvider).clearAll();
      state = const AsyncData({});
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
