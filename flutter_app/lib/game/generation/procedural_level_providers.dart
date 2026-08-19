import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';

final proceduralLevelGeneratorProvider = Provider<ProceduralLevelGenerator>((
  ref,
) {
  return const ProceduralLevelGenerator();
});
