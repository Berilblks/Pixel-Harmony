import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_pixel_template_selector.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class FreePlayLevelFactory {
  const FreePlayLevelFactory({
    required FreePlayPixelTemplateSelector pixelTemplateSelector,
    ProceduralLevelGenerator gradientGenerator =
        const ProceduralLevelGenerator(),
  }) : _pixelTemplateSelector = pixelTemplateSelector,
       _gradientGenerator = gradientGenerator;

  final FreePlayPixelTemplateSelector _pixelTemplateSelector;
  final ProceduralLevelGenerator _gradientGenerator;

  LevelDefinition create({
    required FreePlayConfiguration configuration,
    required int seed,
    int sequence = 0,
  }) {
    final type = _resolvedType(configuration.puzzleType, sequence);
    return type == FreePlayPuzzleType.gradient
        ? _gradient(configuration.difficulty, seed, sequence)
        : _pixelColoring(configuration.difficulty, seed, sequence);
  }

  FreePlayPuzzleType _resolvedType(FreePlayPuzzleType type, int sequence) {
    if (type != FreePlayPuzzleType.mixed) return type;
    return sequence.isEven
        ? FreePlayPuzzleType.gradient
        : FreePlayPuzzleType.pixelColoring;
  }

  LevelDefinition _gradient(
    FreePlayDifficulty difficulty,
    int seed,
    int sequence,
  ) {
    final (boardSize, levelDifficulty) = switch (difficulty) {
      FreePlayDifficulty.relaxed => (3, LevelDifficulty.easy),
      FreePlayDifficulty.normal => (4, LevelDifficulty.medium),
      FreePlayDifficulty.hard => (5, LevelDifficulty.hard),
      FreePlayDifficulty.expert => (5, LevelDifficulty.expert),
    };
    return _gradientGenerator
        .generate(
          ProceduralLevelRequest(
            seed: seed,
            boardSize: boardSize,
            targetDifficulty: levelDifficulty,
            generatedLevelId: 'free_play_gradient_${difficulty.name}_$seed',
          ),
        )
        .toLevelDefinition(number: sequence + 1, nameKey: 'freePlay');
  }

  LevelDefinition _pixelColoring(
    FreePlayDifficulty difficulty,
    int seed,
    int sequence,
  ) {
    final template = _pixelTemplateSelector.next(difficulty);
    final id = 'free_play_picture_${difficulty.name}_${template.id}_$seed';
    final solution = List.generate(
      template.pixels.length,
      (index) => '${id}_tile_$index',
      growable: false,
    );
    final levelDifficulty = switch (difficulty) {
      FreePlayDifficulty.relaxed => LevelDifficulty.easy,
      FreePlayDifficulty.normal => LevelDifficulty.medium,
      FreePlayDifficulty.hard => LevelDifficulty.hard,
      FreePlayDifficulty.expert => LevelDifficulty.expert,
    };
    final score = switch (difficulty) {
      FreePlayDifficulty.relaxed => 20,
      FreePlayDifficulty.normal => 43,
      FreePlayDifficulty.hard => 68,
      FreePlayDifficulty.expert => 90,
    };
    return LevelDefinition(
      id: id,
      number: sequence + 1,
      nameKey: 'freePlay',
      boardSize: template.size,
      difficulty: levelDifficulty,
      difficultyScore: score,
      puzzleType: JourneyPuzzleType.pixelPicture,
      pictureTemplateId: template.id,
      tiles: [
        for (var index = 0; index < template.pixels.length; index++)
          LevelTileDefinition(
            id: solution[index],
            colorValue: template.palette[template.pixels[index]],
          ),
      ],
      initialTileOrder: solution,
      solutionTileOrder: solution,
    );
  }
}
