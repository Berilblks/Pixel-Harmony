import 'package:pixel_harmony/game/levels/journey_gradient.dart';
import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class JourneyLevelFingerprint {
  const JourneyLevelFingerprint({
    required this.boardSize,
    required this.permutation,
    required this.shuffleShape,
    required this.hueFamily,
    required this.luminanceProfile,
    required this.difficultyBucket,
    required this.misplacedTiles,
    required this.inversionBucket,
    required this.maximumDisplacement,
    required this.puzzleType,
    required this.pictureTemplateId,
  });

  factory JourneyLevelFingerprint.fromLevel(LevelDefinition level) {
    final solutionIndices = {
      for (var index = 0; index < level.solutionTileOrder.length; index++)
        level.solutionTileOrder[index]: index,
    };
    final permutation = [
      for (final id in level.initialTileOrder) solutionIndices[id]!,
    ];
    final displacement = [
      for (var index = 0; index < permutation.length; index++)
        (permutation[index] - index).abs(),
    ]..sort();
    var inversions = 0;
    for (var first = 0; first < permutation.length; first++) {
      for (var second = first + 1; second < permutation.length; second++) {
        if (permutation[first] > permutation[second]) inversions++;
      }
    }
    final orderedColors = {
      for (final tile in level.tiles) tile.id: tile.colorValue,
    };
    final first = orderedColors[level.solutionTileOrder.first]!;
    final middle =
        orderedColors[level.solutionTileOrder[level.solutionTileOrder.length ~/
            2]]!;
    final last = orderedColors[level.solutionTileOrder.last]!;
    return JourneyLevelFingerprint(
      boardSize: level.boardSize,
      permutation: permutation.join(','),
      shuffleShape: displacement.join(','),
      hueFamily:
          '${JourneyColorFamily.familyBucket(first)}:'
          '${JourneyColorFamily.familyBucket(middle)}:'
          '${JourneyColorFamily.familyBucket(last)}',
      luminanceProfile: [first, middle, last]
          .map(JourneyGradient.relativeLuminance)
          .map((value) => (value * 12).floor())
          .join(':'),
      difficultyBucket: level.difficultyScore ~/ 8,
      misplacedTiles: displacement.where((distance) => distance > 0).length,
      inversionBucket: inversions ~/ level.boardSize,
      maximumDisplacement: displacement.last,
      puzzleType: level.puzzleType,
      pictureTemplateId: level.pictureTemplateId,
    );
  }

  final int boardSize;
  final String permutation;
  final String shuffleShape;
  final String hueFamily;
  final String luminanceProfile;
  final int difficultyBucket;
  final int misplacedTiles;
  final int inversionBucket;
  final int maximumDisplacement;
  final JourneyPuzzleType puzzleType;
  final String? pictureTemplateId;

  bool isObviousRepeatOf(JourneyLevelFingerprint other) =>
      puzzleType == other.puzzleType &&
      pictureTemplateId == other.pictureTemplateId &&
      boardSize == other.boardSize &&
      (permutation == other.permutation ||
          (shuffleShape == other.shuffleShape &&
              hueFamily == other.hueFamily &&
              luminanceProfile == other.luminanceProfile &&
              difficultyBucket == other.difficultyBucket &&
              misplacedTiles == other.misplacedTiles &&
              inversionBucket == other.inversionBucket &&
              maximumDisplacement == other.maximumDisplacement));
}
