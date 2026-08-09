import 'package:pixel_harmony/features/level_progress/domain/level_progress.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';

class FakeLevelProgressRepository implements LevelProgressRepository {
  FakeLevelProgressRepository({
    Set<String> completedLevelIds = const {},
    this.failReads = false,
  }) : completedLevelIds = {...completedLevelIds};

  final Set<String> completedLevelIds;
  final bool failReads;
  int markCompletedCallCount = 0;

  @override
  Future<LevelProgress?> read(String levelId) async {
    if (failReads) {
      throw StateError('Progress read failed.');
    }
    return completedLevelIds.contains(levelId)
        ? LevelProgress(levelId: levelId, completed: true)
        : null;
  }

  @override
  Future<List<LevelProgress>> readAll() async {
    if (failReads) {
      throw StateError('Progress read failed.');
    }
    return [
      for (final levelId in completedLevelIds)
        LevelProgress(levelId: levelId, completed: true),
    ];
  }

  @override
  Future<void> markCompleted(String levelId) async {
    markCompletedCallCount++;
    completedLevelIds.add(levelId);
  }

  @override
  Future<void> clearAll() async => completedLevelIds.clear();
}
