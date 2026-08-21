import 'dart:convert';

import 'package:pixel_harmony/features/achievements/data/achievement_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAchievementDataSource
    implements AchievementLocalDataSource {
  SharedPreferencesAchievementDataSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'pixel_harmony.achievements.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<Map<String, DateTime>?> readUnlocked() async {
    final encoded = await _preferences.getString(_storageKey);
    if (encoded == null) return null;
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return {
      for (final entry in json.entries)
        entry.key: DateTime.parse(entry.value as String),
    };
  }

  @override
  Future<void> writeUnlocked(Map<String, DateTime> unlocked) {
    final ordered =
        unlocked.entries.toList()
          ..sort((first, second) => first.key.compareTo(second.key));
    return _preferences.setString(
      _storageKey,
      jsonEncode({
        for (final entry in ordered) entry.key: entry.value.toIso8601String(),
      }),
    );
  }

  @override
  Future<void> clear() => _preferences.remove(_storageKey);
}
