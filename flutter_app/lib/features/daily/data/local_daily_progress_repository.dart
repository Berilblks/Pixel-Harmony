import 'package:pixel_harmony/features/daily/data/daily_progress_local_data_source.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress_repository.dart';

class LocalDailyProgressRepository implements DailyProgressRepository {
  LocalDailyProgressRepository({
    required DailyProgressLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final DailyProgressLocalDataSource _dataSource;
  Future<void> _writeQueue = Future.value();

  @override
  Future<DailyProgress> read() async =>
      await _dataSource.read() ?? const DailyProgress();

  @override
  Future<DailyProgress> complete(String dateKey) async {
    late DailyProgress result;
    _writeQueue = _writeQueue.then((_) async {
      final current = await read();
      final updated = current.complete(dateKey);
      if (identical(updated, current)) {
        result = current;
        return;
      }
      await _dataSource.write(updated);
      result = updated;
    });
    await _writeQueue;
    return result;
  }

  @override
  Future<void> clear() async {
    await _writeQueue;
    await _dataSource.clear();
  }
}
