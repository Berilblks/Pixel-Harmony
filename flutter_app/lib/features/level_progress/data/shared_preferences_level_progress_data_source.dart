import 'package:pixel_harmony/features/level_progress/data/level_progress_local_data_source.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLevelProgressDataSource
    implements LevelProgressLocalDataSource {
  SharedPreferencesLevelProgressDataSource({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _completedLevelIdsKey = 'pixel_harmony.completed_level_ids.v1';
  static const _highestCompletedKey =
      'pixel_harmony.journey.highest_completed.v2';
  static const _exceptionIdsKey = 'pixel_harmony.journey.exceptions.v2';
  static const _generatorVersionKey =
      'pixel_harmony.journey.generator_version.v2';

  final SharedPreferencesAsync _preferences;

  @override
  Future<Set<String>> readCompletedLevelIds() async {
    final storedVersion = await _preferences.getInt(_generatorVersionKey);
    if (storedVersion != null &&
        storedVersion > JourneyLevelGenerator.generationVersion) {
      throw StateError(
        'Journey progress uses unsupported generator version $storedVersion.',
      );
    }
    final legacy =
        await _preferences.getStringList(_completedLevelIdsKey) ??
        const <String>[];
    final highest = await _preferences.getInt(_highestCompletedKey) ?? 0;
    final exceptions =
        await _preferences.getStringList(_exceptionIdsKey) ?? const <String>[];
    return Set.unmodifiable({
      ...legacy,
      ...exceptions,
      for (var number = 1; number <= highest; number++) _levelId(number),
    });
  }

  @override
  Future<void> writeCompletedLevelIds(Set<String> levelIds) {
    return _writeCompressed(levelIds);
  }

  Future<void> _writeCompressed(Set<String> levelIds) async {
    final numbers = levelIds.map(_levelNumber).whereType<int>().toSet();
    var highest = 0;
    while (numbers.contains(highest + 1)) {
      highest++;
    }
    final exceptions = [
      for (final number in numbers.where((number) => number > highest))
        _levelId(number),
    ]..sort();
    await _preferences.setInt(_highestCompletedKey, highest);
    await _preferences.setInt(
      _generatorVersionKey,
      JourneyLevelGenerator.generationVersion,
    );
    await _preferences.setStringList(_exceptionIdsKey, exceptions);
    await _preferences.remove(_completedLevelIdsKey);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_completedLevelIdsKey);
    await _preferences.remove(_highestCompletedKey);
    await _preferences.remove(_exceptionIdsKey);
    await _preferences.remove(_generatorVersionKey);
  }

  static int? _levelNumber(String id) {
    final match = RegExp(r'^level_(\d+)$').firstMatch(id);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static String _levelId(int number) =>
      'level_${number.toString().padLeft(3, '0')}';
}
