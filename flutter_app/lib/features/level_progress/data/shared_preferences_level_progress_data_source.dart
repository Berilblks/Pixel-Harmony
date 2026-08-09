import 'package:pixel_harmony/features/level_progress/data/level_progress_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLevelProgressDataSource
    implements LevelProgressLocalDataSource {
  SharedPreferencesLevelProgressDataSource({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _completedLevelIdsKey = 'pixel_harmony.completed_level_ids.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<Set<String>> readCompletedLevelIds() async {
    final storedIds = await _preferences.getStringList(_completedLevelIdsKey);
    return Set.unmodifiable(storedIds ?? const <String>[]);
  }

  @override
  Future<void> writeCompletedLevelIds(Set<String> levelIds) {
    final sortedIds = levelIds.toList()..sort();
    return _preferences.setStringList(_completedLevelIdsKey, sortedIds);
  }

  @override
  Future<void> clear() => _preferences.remove(_completedLevelIdsKey);
}
