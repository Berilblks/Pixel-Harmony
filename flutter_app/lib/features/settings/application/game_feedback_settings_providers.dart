import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/settings/data/game_feedback_settings_local_data_source.dart';
import 'package:pixel_harmony/features/settings/data/local_game_feedback_settings_repository.dart';
import 'package:pixel_harmony/features/settings/data/shared_preferences_game_feedback_settings_data_source.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings_repository.dart';

final gameFeedbackSettingsLocalDataSourceProvider =
    Provider<GameFeedbackSettingsLocalDataSource>((ref) {
      return SharedPreferencesGameFeedbackSettingsDataSource();
    });

final gameFeedbackSettingsRepositoryProvider =
    Provider<GameFeedbackSettingsRepository>((ref) {
      return LocalGameFeedbackSettingsRepository(
        dataSource: ref.watch(gameFeedbackSettingsLocalDataSourceProvider),
      );
    });

final gameFeedbackSettingsControllerProvider =
    AsyncNotifierProvider<GameFeedbackSettingsController, GameFeedbackSettings>(
      GameFeedbackSettingsController.new,
    );

class GameFeedbackSettingsController
    extends AsyncNotifier<GameFeedbackSettings> {
  @override
  Future<GameFeedbackSettings> build() {
    return ref.watch(gameFeedbackSettingsRepositoryProvider).read();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) {
    return _update(
      (settings) => settings.copyWith(soundEffectsEnabled: enabled),
    );
  }

  Future<void> setHapticsEnabled(bool enabled) {
    return _update((settings) => settings.copyWith(hapticsEnabled: enabled));
  }

  Future<void> _update(
    GameFeedbackSettings Function(GameFeedbackSettings settings) transform,
  ) async {
    final previous = state.value ?? const GameFeedbackSettings();
    final updated = transform(previous);
    state = AsyncData(updated);
    try {
      await ref.read(gameFeedbackSettingsRepositoryProvider).write(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
