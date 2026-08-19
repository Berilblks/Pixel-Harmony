import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';

abstract interface class EndlessProgressRepository {
  Future<EndlessProgress> read();

  Future<EndlessProgress> advance(EndlessProgress expectedCurrent);

  Future<void> clear();
}

class UnsupportedEndlessGenerationVersion implements Exception {
  const UnsupportedEndlessGenerationVersion(this.version);

  final int version;

  @override
  String toString() => 'Unsupported Endless generation version: $version';
}
