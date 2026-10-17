import 'dart:math' as math;

import 'package:pixel_harmony/game/levels/journey_perceptual_color.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

enum JourneyPixelDifficultyTier { starter, easy, medium, hard, expert }

class PixelPictureDifficultyAssessment {
  const PixelPictureDifficultyAssessment({
    required this.template,
    required this.score,
    required this.paintableCells,
    required this.colorCount,
    required this.similarColorPairs,
    required this.regionCount,
    required this.smallRegionCount,
    required this.detailRatio,
  });

  final PixelPictureTemplate template;
  final int score;
  final int paintableCells;
  final int colorCount;
  final int similarColorPairs;
  final int regionCount;
  final int smallRegionCount;
  final double detailRatio;
}

abstract final class PixelPictureDifficultyEvaluator {
  static PixelPictureDifficultyAssessment evaluate(
    PixelPictureTemplate template,
  ) {
    final colors = template.requiredPaletteIndices.toList()..sort();
    var similarColorPairs = 0;
    for (var first = 0; first < colors.length; first++) {
      for (var second = first + 1; second < colors.length; second++) {
        final deltaE = JourneyPerceptualColor.deltaE(
          template.palette[colors[first]],
          template.palette[colors[second]],
        );
        if (deltaE < 24) similarColorPairs++;
      }
    }

    final regions = _regions(template);
    final smallRegionCount = regions.where((size) => size <= 3).length;
    final detailRatio = _detailRatio(template);
    final paintableCells = template.paintablePixelCount;
    final colorCount = colors.length;
    final possibleColorPairs = colorCount * (colorCount - 1) / 2;
    final extraRegions = math.max(0, regions.length - colorCount);

    final areaFactor = _normalize(
      template.rows * template.columns,
      minimum: 25,
      maximum: 256,
    );
    final paintFactor = _normalize(paintableCells, minimum: 5, maximum: 210);
    final colorFactor = _normalize(colorCount, minimum: 1, maximum: 8);
    final similarityFactor =
        possibleColorPairs == 0
            ? 0.0
            : (similarColorPairs / possibleColorPairs).clamp(0.0, 1.0);
    final fragmentationFactor = (extraRegions / math.max(1, paintableCells / 5))
        .clamp(0.0, 1.0);
    final smallRegionFactor = (smallRegionCount / math.max(1, colorCount * 3))
        .clamp(0.0, 1.0);

    final score = (1 +
            areaFactor * 14 +
            paintFactor * 18 +
            colorFactor * 18 +
            similarityFactor * 12 +
            fragmentationFactor * 11 +
            smallRegionFactor * 9 +
            detailRatio * 17)
        .round()
        .clamp(1, 100);

    return PixelPictureDifficultyAssessment(
      template: template,
      score: score,
      paintableCells: paintableCells,
      colorCount: colorCount,
      similarColorPairs: similarColorPairs,
      regionCount: regions.length,
      smallRegionCount: smallRegionCount,
      detailRatio: detailRatio,
    );
  }

  static JourneyPixelDifficultyTier tierForJourneyIndex(int index) {
    if (index < 0) throw ArgumentError.value(index, 'index');
    return switch (index) {
      < 20 => JourneyPixelDifficultyTier.starter,
      < 40 => JourneyPixelDifficultyTier.easy,
      < 60 => JourneyPixelDifficultyTier.medium,
      < 80 => JourneyPixelDifficultyTier.hard,
      _ => JourneyPixelDifficultyTier.expert,
    };
  }

  static List<int> _regions(PixelPictureTemplate template) {
    final visited = List<bool>.filled(template.pixels.length, false);
    final result = <int>[];
    for (var start = 0; start < template.pixels.length; start++) {
      final color = template.pixels[start];
      if (visited[start] || color == template.backgroundPaletteIndex) continue;
      var size = 0;
      final pending = <int>[start];
      visited[start] = true;
      while (pending.isNotEmpty) {
        final index = pending.removeLast();
        size++;
        final row = index ~/ template.columns;
        final column = index % template.columns;
        for (final neighbor in [
          if (row > 0) index - template.columns,
          if (row + 1 < template.rows) index + template.columns,
          if (column > 0) index - 1,
          if (column + 1 < template.columns) index + 1,
        ]) {
          if (!visited[neighbor] && template.pixels[neighbor] == color) {
            visited[neighbor] = true;
            pending.add(neighbor);
          }
        }
      }
      result.add(size);
    }
    return result;
  }

  static double _detailRatio(PixelPictureTemplate template) {
    var transitions = 0;
    var comparisons = 0;
    for (var row = 0; row < template.rows; row++) {
      for (var column = 0; column < template.columns; column++) {
        final index = row * template.columns + column;
        if (column + 1 < template.columns) {
          comparisons++;
          if (template.pixels[index] != template.pixels[index + 1]) {
            transitions++;
          }
        }
        if (row + 1 < template.rows) {
          comparisons++;
          if (template.pixels[index] !=
              template.pixels[index + template.columns]) {
            transitions++;
          }
        }
      }
    }
    return comparisons == 0 ? 0 : transitions / comparisons;
  }

  static double _normalize(
    num value, {
    required num minimum,
    required num maximum,
  }) => ((value - minimum) / (maximum - minimum)).clamp(0.0, 1.0);
}
