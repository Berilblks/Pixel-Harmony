import 'package:pixel_harmony/features/level_progress/data/level_progress_local_data_source.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

class LocalLevelProgressRepository implements LevelProgressRepository {
  LocalLevelProgressRepository({
    required LevelProgressLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final LevelProgressLocalDataSource _dataSource;

  @override
  Future<LevelProgress?> read(String levelId) async {
    _validateLevelId(levelId);
    final completedIds = await _readValidatedIds();
    return completedIds.contains(levelId)
        ? LevelProgress(levelId: levelId, completed: true)
        : null;
  }

  @override
  Future<List<LevelProgress>> readAll() async {
    final completedIds = await _readValidatedIds();
    return [
      for (final level in LevelCatalog.levels)
        if (completedIds.contains(level.id))
          LevelProgress(levelId: level.id, completed: true),
    ];
  }

  @override
  Future<void> markCompleted(String levelId) async {
    _validateLevelId(levelId);
    final completedIds = await _readValidatedIds();
    if (completedIds.contains(levelId)) {
      return;
    }

    await _dataSource.writeCompletedLevelIds({...completedIds, levelId});
  }

  @override
  Future<void> clearAll() => _dataSource.clear();

  Future<Set<String>> _readValidatedIds() async {
    final completedIds = await _dataSource.readCompletedLevelIds();
    for (final levelId in completedIds) {
      _validateLevelId(levelId);
    }
    return completedIds;
  }

  void _validateLevelId(String levelId) {
    if (LevelCatalog.findById(levelId) == null) {
      throw ArgumentError.value(levelId, 'levelId', 'Unknown level ID.');
    }
  }
}
