import 'package:pixel_harmony/features/endless/data/endless_progress_local_data_source.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress_repository.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';

class LocalEndlessProgressRepository implements EndlessProgressRepository {
  LocalEndlessProgressRepository({
    required EndlessProgressLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final EndlessProgressLocalDataSource _dataSource;
  Future<void> _writeQueue = Future.value();

  @override
  Future<EndlessProgress> read() async {
    final progress = await _dataSource.read() ?? EndlessProgress.initial();
    if (progress.generationVersion !=
        ProceduralLevelGenerator.generationVersion) {
      throw UnsupportedEndlessGenerationVersion(progress.generationVersion);
    }
    return progress;
  }

  @override
  Future<EndlessProgress> advance(EndlessProgress expectedCurrent) async {
    late EndlessProgress result;
    _writeQueue = _writeQueue.then((_) async {
      final stored = await read();
      if (stored != expectedCurrent) {
        result = stored;
        return;
      }
      result = stored.advance();
      await _dataSource.write(result);
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
