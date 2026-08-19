import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';

abstract interface class DailyProgressRepository {
  Future<DailyProgress> read();

  Future<DailyProgress> complete(String dateKey);

  Future<void> clear();
}
