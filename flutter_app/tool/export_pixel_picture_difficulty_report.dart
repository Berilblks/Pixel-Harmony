import 'dart:io';

import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';

void main() {
  PixelPictureCatalog.validate();
  const generator = JourneyLevelGenerator();
  final journeyLevels = <int>[];
  for (var level = 1; journeyLevels.length < 100; level++) {
    if (generator.puzzleTypeFor(level).name == 'pixelPicture') {
      journeyLevels.add(level);
    }
  }

  final buffer =
      StringBuffer()
        ..writeln('# Pixel Coloring Difficulty Report')
        ..writeln()
        ..writeln(
          'Generated from the approved 100-template catalog using Journey '
          'difficulty model version ${JourneyLevelGenerator.generationVersion}.',
        )
        ..writeln()
        ..writeln(
          '| Journey order | Journey level | Template | ID | Matrix | Colors | '
          'Paintable | Similar pairs | Regions | Small regions | Score | Tier |',
        )
        ..writeln('|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---|');

  for (
    var index = 0;
    index < PixelPictureCatalog.journeyAssessments.length;
    index++
  ) {
    final assessment = PixelPictureCatalog.journeyAssessments[index];
    final template = assessment.template;
    buffer.writeln(
      '| ${index + 1} | ${journeyLevels[index]} | ${template.englishName} / '
      '${template.turkishName} | `${template.id}` | ${template.rows}×${template.columns} | '
      '${assessment.colorCount} | ${assessment.paintableCells} | '
      '${assessment.similarColorPairs} | ${assessment.regionCount} | '
      '${assessment.smallRegionCount} | ${assessment.score} | '
      '${_tierLabel(PixelPictureDifficultyEvaluator.tierForJourneyIndex(index))} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## First 30 Journey Pixel Coloring puzzles')
    ..writeln()
    ..writeln('| Pixel order | Journey level | Figure | Score | Tier |')
    ..writeln('|---:|---:|---|---:|---|');
  for (var index = 0; index < 30; index++) {
    final assessment = PixelPictureCatalog.journeyAssessments[index];
    buffer.writeln(
      '| ${index + 1} | ${journeyLevels[index]} | '
      '${assessment.template.englishName} / ${assessment.template.turkishName} | '
      '${assessment.score} | '
      '${_tierLabel(PixelPictureDifficultyEvaluator.tierForJourneyIndex(index))} |',
    );
  }

  final output = File('../docs/game_design/pixel_picture_difficulty_report.md');
  output.writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${output.path}');
}

String _tierLabel(JourneyPixelDifficultyTier tier) => switch (tier) {
  JourneyPixelDifficultyTier.starter => 'Starter',
  JourneyPixelDifficultyTier.easy => 'Easy',
  JourneyPixelDifficultyTier.medium => 'Medium',
  JourneyPixelDifficultyTier.hard => 'Hard',
  JourneyPixelDifficultyTier.expert => 'Expert',
};
