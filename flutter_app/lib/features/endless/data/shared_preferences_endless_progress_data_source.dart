import 'dart:convert';

import 'package:pixel_harmony/features/endless/data/endless_progress_local_data_source.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesEndlessProgressDataSource
    implements EndlessProgressLocalDataSource {
  SharedPreferencesEndlessProgressDataSource({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _progressKey = 'pixel_harmony.endless_progress.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<EndlessProgress?> read() async {
    final encoded = await _preferences.getString(_progressKey);
    if (encoded == null) return null;
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return EndlessProgress(
      currentSeed: json['currentSeed'] as int,
      completedPuzzleCount: json['completedPuzzleCount'] as int,
      generationVersion: json['generationVersion'] as int,
    );
  }

  @override
  Future<void> write(EndlessProgress progress) {
    return _preferences.setString(
      _progressKey,
      jsonEncode({
        'currentSeed': progress.currentSeed,
        'completedPuzzleCount': progress.completedPuzzleCount,
        'currentBoardSize': progress.currentBoardSize,
        'currentTargetDifficulty': progress.currentTargetDifficulty.name,
        'generationVersion': progress.generationVersion,
      }),
    );
  }

  @override
  Future<void> clear() => _preferences.remove(_progressKey);
}
