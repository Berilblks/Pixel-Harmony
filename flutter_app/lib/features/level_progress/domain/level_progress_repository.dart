import 'package:pixel_harmony/features/level_progress/domain/level_progress.dart';

abstract interface class LevelProgressRepository {
  Future<LevelProgress?> read(String levelId);

  Future<List<LevelProgress>> readAll();

  Future<void> markCompleted(String levelId);

  Future<void> clearAll();
}
