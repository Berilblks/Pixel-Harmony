import 'package:pixel_harmony/features/settings/data/game_feedback_settings_local_data_source.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesGameFeedbackSettingsDataSource
    implements GameFeedbackSettingsLocalDataSource {
  static const soundEffectsKey = 'settings.sound_effects_enabled';
  static const hapticsKey = 'settings.haptics_enabled';

  @override
  Future<GameFeedbackSettings> read() async {
    final preferences = await SharedPreferences.getInstance();
    return GameFeedbackSettings(
      soundEffectsEnabled: preferences.getBool(soundEffectsKey) ?? true,
      hapticsEnabled: preferences.getBool(hapticsKey) ?? true,
    );
  }

  @override
  Future<void> write(GameFeedbackSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(soundEffectsKey, settings.soundEffectsEnabled),
      preferences.setBool(hapticsKey, settings.hapticsEnabled),
    ]);
  }
}
