import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';

abstract interface class DailyProgressLocalDataSource {
  Future<DailyProgress?> read();

  Future<void> write(DailyProgress progress);

  Future<void> clear();
}
