import 'dart:math' as math;

import 'package:pixel_harmony/game/generation/difficulty_evaluator.dart';
import 'package:pixel_harmony/game/generation/seeded_random.dart';
import 'package:pixel_harmony/game/levels/journey_gradient.dart';
import 'package:pixel_harmony/game/levels/journey_level_fingerprint.dart';
import 'package:pixel_harmony/game/levels/journey_perceptual_color.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

class JourneyLevelGenerator {
  const JourneyLevelGenerator();

  static const generationVersion = 5;
  static const _gradientGenerationVersion = 3;
  static const maximumBoardSize = 8;
  static const recentComparisonWindow = 8;
  static const minimumNeighborLuminanceDelta = 0.004;
  static const minimumPerceptualDeltaE = 0.25;
  static const maximumHueVariationDegrees = 8.0;
  static const _generationSalt = 0x50484a31;

  static double perceptualThresholdForLevel(int levelNumber) =>
      switch (levelNumber) {
        <= 10 => 6.0,
        <= 30 => 3.0,
        <= 70 => 1.0,
        _ => minimumPerceptualDeltaE,
      };

  LevelDefinition generate(int levelNumber) {
    if (levelNumber <= 0) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Must be positive.',
      );
    }
    if (levelNumber <= 3) return _tutorial(levelNumber);
    if (puzzleTypeFor(levelNumber) == JourneyPuzzleType.pixelPicture) {
      return _picture(levelNumber);
    }

    final recent = <JourneyLevelFingerprint>[];
    final firstRecent = math.max(4, levelNumber - recentComparisonWindow);
    for (var previous = firstRecent; previous < levelNumber; previous++) {
      final previousLevel =
          puzzleTypeFor(previous) == JourneyPuzzleType.pixelPicture
              ? _picture(previous)
              : _candidate(previous, 0);
      recent.add(JourneyLevelFingerprint.fromLevel(previousLevel));
    }
    for (var reroll = 0; reroll < 24; reroll++) {
      final candidate = _candidate(levelNumber, reroll);
      final fingerprint = JourneyLevelFingerprint.fromLevel(candidate);
      final gradientFamilies = recent
          .where((item) => item.puzzleType == JourneyPuzzleType.gradient)
          .toList(growable: false);
      final recentFamilies = gradientFamilies.skip(
        math.max(0, gradientFamilies.length - 3),
      );
      if (recent.every(
            (item) =>
                !fingerprint.isObviousRepeatOf(item) &&
                (item.puzzleType != JourneyPuzzleType.gradient ||
                    item.shuffleShape != fingerprint.shuffleShape),
          ) &&
          recentFamilies.every(
            (item) => item.hueFamily != fingerprint.hueFamily,
          )) {
        return candidate;
      }
    }
    throw StateError('Unable to create a distinct Journey level $levelNumber.');
  }

  int boardSizeFor(int levelNumber) {
    if (levelNumber <= 0) throw ArgumentError.value(levelNumber, 'levelNumber');
    if (puzzleTypeFor(levelNumber) == JourneyPuzzleType.pixelPicture) {
      return PixelPictureCatalog.selectForJourney(
        levelNumber: levelNumber,
        pictureOrdinal: _pictureOrdinal(levelNumber),
      ).size;
    }
    return switch (levelNumber) {
      <= 5 => 2,
      <= 15 => 3,
      <= 35 => 4,
      <= 70 => 5,
      <= 120 => 6,
      <= 200 => 7,
      _ => maximumBoardSize,
    };
  }

  JourneyPuzzleType puzzleTypeFor(int levelNumber) {
    if (levelNumber <= 0) throw ArgumentError.value(levelNumber, 'levelNumber');
    if (levelNumber == 5) return JourneyPuzzleType.pixelPicture;
    if (levelNumber < 6) return JourneyPuzzleType.gradient;
    final block = (levelNumber - 1) ~/ 5;
    final position = 2 + ((_mix(block) >>> 4) % 3);
    return levelNumber == block * 5 + position
        ? JourneyPuzzleType.pixelPicture
        : JourneyPuzzleType.gradient;
  }

  LevelDefinition _candidate(int number, int reroll) {
    final boardSize = boardSizeFor(number);
    final difficulty = _difficultyFor(number);
    final seed = _seed(number, reroll);
    final random = SeededRandom(seed);
    final colors = _palette(boardSize, number, random, difficulty);
    final id = levelId(number);
    final solution = List.generate(
      colors.length,
      (index) => '${id}_tile_$index',
      growable: false,
    );
    final initial = _permutation(
      solution,
      boardSize,
      number,
      random,
      difficulty,
    );
    const evaluator = DifficultyEvaluator();
    final evaluation = evaluator.evaluate(
      boardSize: boardSize,
      solutionColors: colors,
      initialOrder: initial,
      solutionOrder: solution,
    );
    final normalizedDifficulty =
        number <= 12 ? difficulty : evaluation.difficulty;
    final normalizedScore =
        number <= 12
            ? _scoreInside(difficulty, evaluation.score)
            : evaluation.score;
    return LevelDefinition(
      id: id,
      number: number,
      nameKey: 'numberedLevel',
      boardSize: boardSize,
      difficulty: normalizedDifficulty,
      difficultyScore: normalizedScore,
      tiles: [
        for (var index = 0; index < colors.length; index++)
          LevelTileDefinition(id: solution[index], colorValue: colors[index]),
      ],
      initialTileOrder: initial,
      solutionTileOrder: solution,
    );
  }

  List<int> _palette(
    int boardSize,
    int number,
    SeededRandom random,
    LevelDifficulty difficulty,
  ) {
    final progress = (math.log(number + 1) / math.log(10000)).clamp(0.0, 1.0);
    final familyIndex =
        (number * 7 + (number ~/ 18) * 5 + _gradientGenerationVersion * 3) % 18;
    final baseHue = familyIndex * 20.0 + 7 + random.nextDouble() * 6;
    return _shadePalette(
      count: boardSize * boardSize,
      baseHue: baseHue,
      saturation: 0.66 - progress * 0.12 + random.nextSignedDouble() * 0.025,
      lowLuminance: number <= 10 ? 0.015 : 0.025 + progress * 0.045,
      highLuminance: number <= 10 ? 0.84 : 0.80 - progress * 0.22,
      hueVariation: 2.0 + random.nextDouble() * 2.5,
      minimumDeltaE: perceptualThresholdForLevel(number),
    );
  }

  LevelDefinition _picture(int number) {
    PixelPictureCatalog.validate();
    final pictureOrdinal = _pictureOrdinal(number);
    final template = PixelPictureCatalog.selectForJourney(
      levelNumber: number,
      pictureOrdinal: pictureOrdinal,
    );
    final id = levelId(number);
    final colors = [
      for (final index in template.pixels) template.palette[index],
    ];
    final solution = List.generate(
      colors.length,
      (index) => '${id}_tile_$index',
    );
    return LevelDefinition(
      id: id,
      number: number,
      nameKey: 'numberedLevel',
      boardSize: template.size,
      difficulty: _difficultyFor(number),
      difficultyScore: _scoreInside(_difficultyFor(number), 8 + number ~/ 4),
      puzzleType: JourneyPuzzleType.pixelPicture,
      pictureTemplateId: template.id,
      tiles: [
        for (var index = 0; index < colors.length; index++)
          LevelTileDefinition(id: solution[index], colorValue: colors[index]),
      ],
      initialTileOrder: solution,
      solutionTileOrder: solution,
    );
  }

  int _pictureOrdinal(int number) {
    return number == 5 ? 0 : (number - 1) ~/ 5;
  }

  static int _mix(int value) {
    var result = value & 0xffffffff;
    result ^= result >>> 16;
    result = (result * 0x7feb352d) & 0xffffffff;
    result ^= result >>> 15;
    return result & 0x7fffffff;
  }

  List<String> _permutation(
    List<String> solution,
    int boardSize,
    int number,
    SeededRandom random,
    LevelDifficulty difficulty,
  ) {
    final result = List<String>.of(solution);
    final progress = (math.log(number + 1) / math.log(10000)).clamp(0.0, 1.0);
    final baseFraction = switch (difficulty) {
      LevelDifficulty.tutorial => 0.20,
      LevelDifficulty.easy => 0.34,
      LevelDifficulty.medium => 0.52,
      LevelDifficulty.hard => 0.70,
      LevelDifficulty.expert => 0.86,
    };
    final wave = ((number % 7) - 3) * 0.018;
    final target = (solution.length * (baseFraction + progress * 0.08 + wave))
        .round()
        .clamp(2, solution.length - 1);
    final positions = List.generate(solution.length, (index) => index);
    for (var index = positions.length - 1; index > 0; index--) {
      final other = random.nextInt(index + 1);
      final value = positions[index];
      positions[index] = positions[other];
      positions[other] = value;
    }
    final anchor = positions.first;
    for (var index = 1; index <= target; index++) {
      final other = positions[index];
      final value = result[anchor];
      result[anchor] = result[other];
      result[other] = value;
    }
    return result;
  }

  LevelDifficulty _difficultyFor(int number) {
    if (number <= 3) return LevelDifficulty.tutorial;
    if (number <= 8) return LevelDifficulty.easy;
    if (number <= 24) return LevelDifficulty.medium;
    if (number <= 100) return LevelDifficulty.hard;
    return number < 350 ? LevelDifficulty.hard : LevelDifficulty.expert;
  }

  int _scoreInside(LevelDifficulty difficulty, int score) =>
      switch (difficulty) {
        LevelDifficulty.tutorial => score.clamp(1, 10),
        LevelDifficulty.easy => score.clamp(11, 30),
        LevelDifficulty.medium => score.clamp(31, 55),
        LevelDifficulty.hard => score.clamp(56, 80),
        LevelDifficulty.expert => score.clamp(81, 100),
      };

  int _seed(int number, int reroll) {
    var value =
        (number ^ _generationSalt ^ (_gradientGenerationVersion * 0x9e3779b9)) &
        0xffffffff;
    value = (value * 1664525 + 1013904223 + reroll * 0x45d9f3b) & 0xffffffff;
    value ^= value >>> 16;
    return value & 0x7fffffff;
  }

  LevelDefinition _tutorial(int number) {
    const hues = [220.0, 24.0, 145.0];
    const permutations = [
      [1, 0, 2, 3],
      [2, 1, 0, 3],
      [2, 3, 0, 1],
    ];
    final id = levelId(number);
    final solution = List.generate(4, (index) => '${id}_tile_$index');
    final palette = _shadePalette(
      count: 4,
      baseHue: hues[number - 1],
      saturation: 0.72,
      lowLuminance: 0.025 + number * 0.005,
      highLuminance: 0.76 - number * 0.025,
      hueVariation: 1.5,
      minimumDeltaE: perceptualThresholdForLevel(number),
    );
    return LevelDefinition(
      id: id,
      number: number,
      nameKey: 'numberedLevel',
      boardSize: 2,
      difficulty: LevelDifficulty.tutorial,
      difficultyScore: 3 + (number - 1) * 3,
      tiles: [
        for (var index = 0; index < 4; index++)
          LevelTileDefinition(id: solution[index], colorValue: palette[index]),
      ],
      initialTileOrder: [
        for (final index in permutations[number - 1]) solution[index],
      ],
      solutionTileOrder: solution,
    );
  }

  static String levelId(int number) =>
      'level_${number.toString().padLeft(3, '0')}';

  static List<int> _shadePalette({
    required int count,
    required double baseHue,
    required double saturation,
    required double lowLuminance,
    required double highLuminance,
    required double hueVariation,
    required double minimumDeltaE,
  }) {
    var previousLuminance = -1.0;
    final colors = List.generate(count, (index) {
      final t = index / (count - 1);
      final linearTarget = lowLuminance + (highLuminance - lowLuminance) * t;
      final targetLuminance = math.max(
        linearTarget,
        previousLuminance + minimumNeighborLuminanceDelta + 0.003,
      );
      final hue = baseHue + math.sin(t * math.pi * 2) * hueVariation;
      final localSaturation = (saturation + math.sin(t * math.pi) * 0.025)
          .clamp(0.42, 0.78);
      var lower = 0.0;
      var upper = 1.0;
      var color = _hslToArgb(hue, localSaturation, 0.5);
      for (var attempt = 0; attempt < 18; attempt++) {
        final lightness = (lower + upper) / 2;
        color = _hslToArgb(hue, localSaturation, lightness);
        if (JourneyGradient.relativeLuminance(color) < targetLuminance) {
          lower = lightness;
        } else {
          upper = lightness;
        }
      }
      color = _hslToArgb(hue, localSaturation, upper);
      previousLuminance = JourneyGradient.relativeLuminance(color);
      return color;
    }, growable: false);
    for (var index = 1; index < colors.length; index++) {
      if (JourneyPerceptualColor.deltaE(colors[index - 1], colors[index]) <
          minimumDeltaE) {
        throw StateError(
          'Generated Journey shades fell below the readability floor.',
        );
      }
    }
    return colors;
  }

  static int _hslToArgb(double hue, double saturation, double lightness) {
    final wrappedHue = ((hue % 360) + 360) % 360;
    final chroma = (1 - (2 * lightness - 1).abs()) * saturation;
    final section = wrappedHue / 60;
    final secondary = chroma * (1 - ((section % 2) - 1).abs());
    final (red, green, blue) = switch (section.floor() % 6) {
      0 => (chroma, secondary, 0.0),
      1 => (secondary, chroma, 0.0),
      2 => (0.0, chroma, secondary),
      3 => (0.0, secondary, chroma),
      4 => (secondary, 0.0, chroma),
      _ => (chroma, 0.0, secondary),
    };
    final match = lightness - chroma / 2;
    int byte(double value) => ((value + match) * 255).round().clamp(0, 255);
    return 0xff000000 | (byte(red) << 16) | (byte(green) << 8) | byte(blue);
  }
}
