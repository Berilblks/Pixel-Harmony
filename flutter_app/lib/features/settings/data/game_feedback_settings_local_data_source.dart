import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';

abstract interface class GameFeedbackSettingsLocalDataSource {
  Future<GameFeedbackSettings> read();

  Future<void> write(GameFeedbackSettings settings);
}
