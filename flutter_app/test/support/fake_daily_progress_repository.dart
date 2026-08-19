import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress_repository.dart';

class FakeDailyProgressRepository implements DailyProgressRepository {
  FakeDailyProgressRepository({
    DailyProgress? progress,
    this.failWrites = false,
  }) : progress = progress ?? const DailyProgress();

  DailyProgress progress;
  final bool failWrites;
  int completeCallCount = 0;

  @override
  Future<void> clear() async => progress = const DailyProgress();

  @override
  Future<DailyProgress> complete(String dateKey) async {
    completeCallCount++;
    if (failWrites) throw StateError('write failed');
    progress = progress.complete(dateKey);
    return progress;
  }

  @override
  Future<DailyProgress> read() async => progress;
}
