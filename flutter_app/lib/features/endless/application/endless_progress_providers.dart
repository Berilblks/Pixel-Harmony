import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/endless/data/endless_progress_local_data_source.dart';
import 'package:pixel_harmony/features/endless/data/local_endless_progress_repository.dart';
import 'package:pixel_harmony/features/endless/data/shared_preferences_endless_progress_data_source.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress_repository.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';

final endlessProgressLocalDataSourceProvider =
    Provider<EndlessProgressLocalDataSource>((ref) {
      return SharedPreferencesEndlessProgressDataSource();
    });

final endlessProgressRepositoryProvider = Provider<EndlessProgressRepository>((
  ref,
) {
  return LocalEndlessProgressRepository(
    dataSource: ref.watch(endlessProgressLocalDataSourceProvider),
  );
});

final proceduralLevelGeneratorProvider = Provider<ProceduralLevelGenerator>((
  ref,
) {
  return const ProceduralLevelGenerator();
});

final endlessProgressControllerProvider =
    AsyncNotifierProvider<EndlessProgressController, EndlessProgress>(
      EndlessProgressController.new,
    );

class EndlessProgressController extends AsyncNotifier<EndlessProgress> {
  Future<EndlessProgress>? _advanceOperation;

  @override
  Future<EndlessProgress> build() {
    return ref.watch(endlessProgressRepositoryProvider).read();
  }

  Future<EndlessProgress> advance(EndlessProgress expectedCurrent) {
    final active = _advanceOperation;
    if (active != null) return active;

    final operation = _advance(expectedCurrent);
    _advanceOperation = operation;
    return operation.whenComplete(() => _advanceOperation = null);
  }

  Future<EndlessProgress> _advance(EndlessProgress expectedCurrent) async {
    try {
      final next = await ref
          .read(endlessProgressRepositoryProvider)
          .advance(expectedCurrent);
      state = AsyncData(next);
      return next;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> reset() async {
    try {
      await ref.read(endlessProgressRepositoryProvider).clear();
      state = AsyncData(EndlessProgress.initial());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
