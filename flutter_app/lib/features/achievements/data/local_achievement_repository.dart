import 'package:pixel_harmony/features/achievements/data/achievement_local_data_source.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_catalog.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_repository.dart';

class LocalAchievementRepository implements AchievementRepository {
  LocalAchievementRepository({required AchievementLocalDataSource dataSource})
    : _dataSource = dataSource;

  final AchievementLocalDataSource _dataSource;
  Future<void> _operationQueue = Future.value();

  @override
  Future<Map<String, DateTime>> readUnlocked() async =>
      Map.unmodifiable(await _dataSource.readUnlocked() ?? const {});

  @override
  Future<Map<String, DateTime>> unlock(
    Set<String> achievementIds,
    DateTime unlockedAt,
  ) {
    for (final id in achievementIds) {
      if (!AchievementCatalog.contains(id)) {
        return Future.error(
          ArgumentError.value(id, 'achievementIds', 'Unknown achievement.'),
        );
      }
    }
    final operation = _operationQueue.then((_) async {
      final current = await _dataSource.readUnlocked() ?? <String, DateTime>{};
      final updated = Map<String, DateTime>.of(current);
      var changed = false;
      for (final id in achievementIds) {
        if (!updated.containsKey(id)) {
          updated[id] = unlockedAt;
          changed = true;
        }
      }
      if (changed) await _dataSource.writeUnlocked(updated);
      return Map<String, DateTime>.unmodifiable(updated);
    });
    _operationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }

  @override
  Future<void> clear() async {
    await _operationQueue;
    await _dataSource.clear();
  }
}
