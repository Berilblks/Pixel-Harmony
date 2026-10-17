import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_1_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_2_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_3_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_4_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_5_templates.dart';

abstract final class PixelPictureCatalog {
  static const recentAppearanceWindow = 15;

  static final List<PixelPictureTemplate> templates = List.unmodifiable([
    ...tier1Templates,
    ...tier2Templates,
    ...tier3Templates,
    ...tier4Templates,
    ...tier5Templates,
  ]);

  static final Map<String, PixelPictureTemplate> _byId = {
    for (final template in templates) template.id: template,
  };

  static final List<PixelPictureDifficultyAssessment> journeyAssessments =
      List.unmodifiable(_buildJourneyAssessments());

  static final List<PixelPictureTemplate> journeyTemplates = List.unmodifiable(
    journeyAssessments.map((assessment) => assessment.template),
  );

  static PixelPictureTemplate byId(String id) =>
      _byId[id] ??
      templates.firstWhere(
        (template) => template.familyId == id,
        orElse: () => throw StateError('Unknown Pixel Art template: $id'),
      );

  /// Occurrence order, rather than Journey level modulo, drives content.
  /// Every curated artwork appears once before normal reuse begins.
  static PixelPictureTemplate selectForJourney({
    required int levelNumber,
    required int pictureOrdinal,
  }) {
    if (levelNumber < 1 || pictureOrdinal < 0) {
      throw ArgumentError('Journey inputs must be non-negative.');
    }
    if (pictureOrdinal < journeyTemplates.length) {
      return journeyTemplates[pictureOrdinal];
    }
    // Once every artwork has appeared, retain expert-level variety instead of
    // abruptly returning to beginner content. The stride is coprime with the
    // 30-item pool, so every item appears before the deterministic cycle repeats.
    const advancedPoolSize = 30;
    const advancedStride = 17;
    final advancedStart = journeyTemplates.length - advancedPoolSize;
    final cycleIndex =
        ((pictureOrdinal - journeyTemplates.length) * advancedStride) %
        advancedPoolSize;
    return journeyTemplates[advancedStart + cycleIndex];
  }

  static List<PixelPictureTemplate> eligibleForLevel(int levelNumber) {
    if (levelNumber < 1) throw ArgumentError.value(levelNumber, 'levelNumber');
    final unlockedTier = switch (levelNumber) {
      < 101 => 0,
      < 201 => 1,
      < 301 => 2,
      < 401 => 3,
      _ => 4,
    };
    return templates.take((unlockedTier + 1) * 20).toList(growable: false);
  }

  static void validate() {
    if (templates.length != 100) {
      throw StateError(
        'The production Pixel Art catalog must contain 100 items.',
      );
    }
    final ids = <String>{};
    final names = <String>{};
    for (final template in templates) {
      template.validate();
      if (!ids.add(template.id)) {
        throw StateError('Duplicate Pixel Art template ID: ${template.id}');
      }
      final identity = '${template.englishName}|${template.turkishName}';
      if (!names.add(identity)) {
        throw StateError('Duplicate Pixel Art subject: $identity');
      }
    }
  }

  static List<PixelPictureDifficultyAssessment> _buildJourneyAssessments() {
    final sorted =
        templates.map(PixelPictureDifficultyEvaluator.evaluate).toList()
          ..sort((first, second) {
            final score = first.score.compareTo(second.score);
            return score != 0
                ? score
                : first.template.id.compareTo(second.template.id);
          });
    final result = <PixelPictureDifficultyAssessment>[];
    for (var start = 0; start < sorted.length;) {
      final minimumScore = sorted[start].score;
      var end = start + 1;
      while (end < sorted.length && sorted[end].score <= minimumScore + 3) {
        end++;
      }
      final remaining = sorted.sublist(start, end);
      while (remaining.isNotEmpty) {
        final previous = result.isEmpty ? null : result.last;
        remaining.sort((first, second) {
          final firstPenalty = _varietyPenalty(previous, first);
          final secondPenalty = _varietyPenalty(previous, second);
          if (firstPenalty != secondPenalty) {
            return firstPenalty.compareTo(secondPenalty);
          }
          final score = first.score.compareTo(second.score);
          return score != 0
              ? score
              : first.template.id.compareTo(second.template.id);
        });
        result.add(remaining.removeAt(0));
      }
      start = end;
    }
    return result;
  }

  static int _varietyPenalty(
    PixelPictureDifficultyAssessment? previous,
    PixelPictureDifficultyAssessment current,
  ) {
    if (previous == null) return 0;
    var penalty = 0;
    if (previous.template.category == current.template.category) penalty += 100;
    if (_paletteFamily(previous.template) == _paletteFamily(current.template)) {
      penalty += 35;
    }
    return penalty;
  }

  static int _paletteFamily(PixelPictureTemplate template) {
    final colors = template.requiredPaletteIndices
        .map((index) => template.palette[index])
        .toList(growable: false);
    var red = 0;
    var green = 0;
    var blue = 0;
    for (final color in colors) {
      red += (color >> 16) & 0xff;
      green += (color >> 8) & 0xff;
      blue += color & 0xff;
    }
    final average =
        0xff000000 |
        ((red ~/ colors.length) << 16) |
        ((green ~/ colors.length) << 8) |
        (blue ~/ colors.length);
    return JourneyColorFamily.familyBucket(average);
  }
}
