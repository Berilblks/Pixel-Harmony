import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/level_progress/data/level_progress_local_data_source.dart';
import 'package:pixel_harmony/features/level_progress/data/local_level_progress_repository.dart';

void main() {
  test('initial progress is empty', () async {
    final repository = LocalLevelProgressRepository(
      dataSource: _FakeLocalDataSource(),
    );

    expect(await repository.readAll(), isEmpty);
    expect(await repository.read('level_001'), isNull);
  });

  test('marking completion persists across repository instances', () async {
    final dataSource = _FakeLocalDataSource();
    final repository = LocalLevelProgressRepository(dataSource: dataSource);
    await repository.markCompleted('level_001');

    final restartedRepository = LocalLevelProgressRepository(
      dataSource: dataSource,
    );

    expect((await restartedRepository.read('level_001'))?.completed, isTrue);
  });

  test('marking the same level twice is idempotent', () async {
    final dataSource = _FakeLocalDataSource();
    final repository = LocalLevelProgressRepository(dataSource: dataSource);

    await repository.markCompleted('level_001');
    await repository.markCompleted('level_001');

    expect(dataSource.writeCount, 1);
    expect(await dataSource.readCompletedLevelIds(), {'level_001'});
  });

  test('unknown level IDs are rejected', () async {
    final repository = LocalLevelProgressRepository(
      dataSource: _FakeLocalDataSource(),
    );

    await expectLater(repository.markCompleted('unknown'), throwsArgumentError);
    await expectLater(repository.read('unknown'), throwsArgumentError);
  });
}

class _FakeLocalDataSource implements LevelProgressLocalDataSource {
  Set<String> storedIds = {};
  int writeCount = 0;

  @override
  Future<Set<String>> readCompletedLevelIds() async => {...storedIds};

  @override
  Future<void> writeCompletedLevelIds(Set<String> levelIds) async {
    writeCount++;
    storedIds = {...levelIds};
  }

  @override
  Future<void> clear() async => storedIds.clear();
}
