import 'package:pixel_harmony/features/settings/data/game_feedback_settings_local_data_source.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings_repository.dart';

class LocalGameFeedbackSettingsRepository
    implements GameFeedbackSettingsRepository {
  LocalGameFeedbackSettingsRepository({required this.dataSource});

  final GameFeedbackSettingsLocalDataSource dataSource;

  @override
  Future<GameFeedbackSettings> read() => dataSource.read();

  @override
  Future<void> write(GameFeedbackSettings settings) =>
      dataSource.write(settings);
}
