import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress_repository.dart';

class FakeEndlessProgressRepository implements EndlessProgressRepository {
  FakeEndlessProgressRepository({EndlessProgress? progress})
    : progress = progress ?? EndlessProgress.initial();

  EndlessProgress progress;
  int advanceCallCount = 0;

  @override
  Future<EndlessProgress> read() async => progress;

  @override
  Future<EndlessProgress> advance(EndlessProgress expectedCurrent) async {
    advanceCallCount++;
    if (progress == expectedCurrent) {
      progress = progress.advance();
    }
    return progress;
  }

  @override
  Future<void> clear() async => progress = EndlessProgress.initial();
}
