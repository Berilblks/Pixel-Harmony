import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';

abstract interface class EndlessProgressLocalDataSource {
  Future<EndlessProgress?> read();

  Future<void> write(EndlessProgress progress);

  Future<void> clear();
}
