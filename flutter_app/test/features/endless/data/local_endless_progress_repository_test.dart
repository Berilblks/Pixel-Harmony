import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/endless/data/endless_progress_local_data_source.dart';
import 'package:pixel_harmony/features/endless/data/local_endless_progress_repository.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress_repository.dart';

void main() {
  test(
    'initial progress is stable and repository recreation resumes it',
    () async {
      final dataSource = _MemoryDataSource();
      final firstRepository = LocalEndlessProgressRepository(
        dataSource: dataSource,
      );
      final initial = await firstRepository.read();
      final advanced = await firstRepository.advance(initial);

      final recreatedRepository = LocalEndlessProgressRepository(
        dataSource: dataSource,
      );
      expect(await recreatedRepository.read(), advanced);
      expect(advanced.currentSeed, initial.advance().currentSeed);
    },
  );

  test(
    'completion with the same expected progress advances only once',
    () async {
      final repository = LocalEndlessProgressRepository(
        dataSource: _MemoryDataSource(),
      );
      final initial = await repository.read();
      final first = await repository.advance(initial);
      final duplicate = await repository.advance(initial);
      expect(duplicate, first);
      expect(duplicate.completedPuzzleCount, 1);
    },
  );

  test(
    'unsupported generation version is rejected without overwrite',
    () async {
      final unsupported = EndlessProgress(
        currentSeed: 1,
        completedPuzzleCount: 3,
        generationVersion: 999,
      );
      final dataSource = _MemoryDataSource(progress: unsupported);
      final repository = LocalEndlessProgressRepository(dataSource: dataSource);
      await expectLater(
        repository.read(),
        throwsA(isA<UnsupportedEndlessGenerationVersion>()),
      );
      expect(dataSource.progress, unsupported);
    },
  );

  test('restart-style reads do not advance progress', () async {
    final repository = LocalEndlessProgressRepository(
      dataSource: _MemoryDataSource(),
    );
    final first = await repository.read();
    expect(await repository.read(), first);
    expect(await repository.read(), first);
  });
}

class _MemoryDataSource implements EndlessProgressLocalDataSource {
  _MemoryDataSource({this.progress});

  EndlessProgress? progress;

  @override
  Future<EndlessProgress?> read() async => progress;

  @override
  Future<void> write(EndlessProgress progress) async {
    this.progress = progress;
  }

  @override
  Future<void> clear() async => progress = null;
}
