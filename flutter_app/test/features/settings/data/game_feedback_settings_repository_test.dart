import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/settings/data/local_game_feedback_settings_repository.dart';
import 'package:pixel_harmony/features/settings/data/shared_preferences_game_feedback_settings_data_source.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('settings default to sound and haptics enabled', () async {
    final repository = LocalGameFeedbackSettingsRepository(
      dataSource: SharedPreferencesGameFeedbackSettingsDataSource(),
    );

    expect(await repository.read(), const GameFeedbackSettings());
  });

  test(
    'sound and haptic settings persist after repository recreation',
    () async {
      final repository = LocalGameFeedbackSettingsRepository(
        dataSource: SharedPreferencesGameFeedbackSettingsDataSource(),
      );
      await repository.write(
        const GameFeedbackSettings(
          soundEffectsEnabled: false,
          hapticsEnabled: false,
        ),
      );

      final recreatedRepository = LocalGameFeedbackSettingsRepository(
        dataSource: SharedPreferencesGameFeedbackSettingsDataSource(),
      );

      expect(
        await recreatedRepository.read(),
        const GameFeedbackSettings(
          soundEffectsEnabled: false,
          hapticsEnabled: false,
        ),
      );
    },
  );
}
