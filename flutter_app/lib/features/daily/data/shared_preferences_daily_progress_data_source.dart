import 'dart:convert';

import 'package:pixel_harmony/features/daily/data/daily_progress_local_data_source.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDailyProgressDataSource
    implements DailyProgressLocalDataSource {
  SharedPreferencesDailyProgressDataSource({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _progressKey = 'pixel_harmony.daily_progress.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<DailyProgress?> read() async {
    final encoded = await _preferences.getString(_progressKey);
    if (encoded == null) return null;
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return DailyProgress(
      lastCompletedDateKey: json['lastCompletedDateKey'] as String?,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalDailyCompleted: json['totalDailyCompleted'] as int,
    );
  }

  @override
  Future<void> write(DailyProgress progress) {
    return _preferences.setString(
      _progressKey,
      jsonEncode({
        'lastCompletedDateKey': progress.lastCompletedDateKey,
        'currentStreak': progress.currentStreak,
        'longestStreak': progress.longestStreak,
        'totalDailyCompleted': progress.totalDailyCompleted,
      }),
    );
  }

  @override
  Future<void> clear() => _preferences.remove(_progressKey);
}
