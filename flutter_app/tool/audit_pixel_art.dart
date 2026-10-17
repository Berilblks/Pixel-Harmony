// Development-only catalog report intentionally writes to stdout.
// ignore_for_file: avoid_print

import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  PixelPictureCatalog.validate();
  const generator = JourneyLevelGenerator();
  final occurrences = <({int level, int occurrence, String templateId})>[];
  for (var level = 1; level <= 5000; level++) {
    if (generator.puzzleTypeFor(level) != JourneyPuzzleType.pixelPicture) {
      continue;
    }
    occurrences.add((
      level: level,
      occurrence: occurrences.length + 1,
      templateId: generator.generate(level).pictureTemplateId!,
    ));
  }

  for (final item in occurrences.take(100)) {
    final template = PixelPictureCatalog.byId(item.templateId);
    print(
      '${item.occurrence.toString().padLeft(3)} | '
      'Journey ${item.level.toString().padLeft(4)} | '
      '${template.id} | ${template.englishName} | '
      '${template.rows}x${template.columns} | '
      '${template.paintablePixelCount} pixels | '
      '${template.requiredPaletteIndices.length} colors | '
      '${template.category.name}',
    );
  }

  for (var group = 0; group < 5; group++) {
    final counts =
        PixelPictureCatalog.templates
            .skip(group * 20)
            .take(20)
            .map((template) => template.paintablePixelCount)
            .toList()
          ..sort();
    final average = counts.reduce((a, b) => a + b) / counts.length;
    final median = (counts[9] + counts[10]) / 2;
    final colorCounts =
        PixelPictureCatalog.templates
            .skip(group * 20)
            .take(20)
            .map((template) => template.requiredPaletteIndices.length)
            .toList();
    final averageColors =
        colorCounts.reduce((a, b) => a + b) / colorCounts.length;
    print(
      '${group * 20 + 1}-${group * 20 + 20}: '
      'average=${average.toStringAsFixed(1)}, median=$median, '
      'min=${counts.first}, max=${counts.last}, '
      'averageColors=${averageColors.toStringAsFixed(1)}',
    );
  }

  final firstHundred = occurrences.take(100).map((item) => item.templateId);
  print('Journey 1-5000 Pixel Coloring occurrences: ${occurrences.length}');
  print('First 100 unique templates: ${firstHundred.toSet().length}');
}
