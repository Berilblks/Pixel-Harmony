import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';

import '../../../support/fake_level_progress_repository.dart';

void main() {
  test('completed state is exposed through Riverpod', () async {
    final repository = FakeLevelProgressRepository();
    final container = ProviderContainer(
      overrides: [
        levelProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(levelProgressControllerProvider.future),
      isEmpty,
    );

    await container
        .read(levelProgressControllerProvider.notifier)
        .markCompleted('level_002');

    expect(container.read(levelProgressControllerProvider).value, {
      'level_002',
    });
    expect(repository.completedLevelIds, {'level_002'});
  });
}
