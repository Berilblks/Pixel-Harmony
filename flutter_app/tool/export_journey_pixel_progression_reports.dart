import 'dart:io';

import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';

void main() {
  const generator = JourneyLevelGenerator();
  final assessmentById = {
    for (final item in PixelPictureCatalog.journeyAssessments)
      item.template.id: item,
  };
  final selections = <_Selection>[];
  var ordinal = 0;
  for (var levelNumber = 1; levelNumber <= 1000; levelNumber++) {
    if (generator.puzzleTypeFor(levelNumber) !=
        JourneyPuzzleType.pixelPicture) {
      continue;
    }
    final level = generator.generate(levelNumber);
    final assessment = assessmentById[level.pictureTemplateId!]!;
    selections.add(
      _Selection(
        levelNumber: levelNumber,
        ordinal: ordinal,
        assessment: assessment,
      ),
    );
    ordinal++;
  }

  final docs = Directory('../docs/game_design')..createSync(recursive: true);
  File(
    '${docs.path}/journey_pixel_coloring_repetition_1_500.md',
  ).writeAsStringSync(_repetitionReport(selections));
  File(
    '${docs.path}/journey_pixel_coloring_difficulty_1_1000.md',
  ).writeAsStringSync(_difficultyReport(selections));
  File(
    '${docs.path}/pixel_art_catalog_expansion_plan.md',
  ).writeAsStringSync(_expansionPlan(selections));
}

String _repetitionReport(List<_Selection> all) {
  final selections = all.where((item) => item.levelNumber <= 500).toList();
  final lastLevel = <String, int>{};
  var repeats = 0;
  final rows = StringBuffer();
  for (final selection in selections) {
    final id = selection.assessment.template.id;
    final previous = lastLevel[id];
    if (previous != null) repeats++;
    rows.writeln(
      '| ${selection.levelNumber} | ${selection.ordinal + 1} | `$id` | '
      '${selection.assessment.template.category.name} | '
      '${selection.assessment.score} | '
      '${previous == null ? 'first use' : '**repeat after ${selection.levelNumber - previous} levels**'} |',
    );
    lastLevel[id] = selection.levelNumber;
  }
  return '''# Journey Pixel Coloring repetition report — levels 1–500

The first ${selections.length} Pixel Coloring appearances use
${lastLevel.length} unique approved templates. Repeated IDs in this range:
**$repeats**. The first catalog reuse occurs after this range, because the
100th unique artwork appears near Journey level 500.

| Journey level | Pixel occurrence | Template ID | Category | Complexity | Repeat interval |
|---:|---:|---|---|---:|---|
${rows.toString()}''';
}

String _difficultyReport(List<_Selection> selections) {
  final lastOccurrence = <String, int>{};
  final rows = StringBuffer();
  for (final selection in selections) {
    final template = selection.assessment.template;
    final previous = lastOccurrence[template.id];
    rows.writeln(
      '| ${selection.levelNumber} | ${selection.ordinal + 1} | '
      '`${template.id}` | ${template.size}×${template.size} | '
      '${selection.assessment.colorCount} | '
      '${selection.assessment.paintableCells} | '
      '${selection.assessment.regionCount} | '
      '${selection.assessment.smallRegionCount} | '
      '${selection.assessment.score} | '
      '${previous == null ? 'new' : selection.ordinal - previous} |',
    );
    lastOccurrence[template.id] = selection.ordinal;
  }
  final bands = <String>[];
  for (final (start, end) in const [
    (1, 200),
    (201, 400),
    (401, 600),
    (601, 800),
    (801, 1000),
  ]) {
    final band =
        selections
            .where(
              (item) => item.levelNumber >= start && item.levelNumber <= end,
            )
            .toList();
    final average =
        band.map((item) => item.assessment.score).reduce((a, b) => a + b) /
        band.length;
    bands.add(
      '| $start–$end | ${band.length} | '
      '${average.toStringAsFixed(1)} | '
      '${band.map((item) => item.assessment.template.id).toSet().length} |',
    );
  }
  return '''# Journey Pixel Coloring difficulty — levels 1–1000

Difficulty is measured from matrix area, paintable cells, palette size and
similarity, region fragmentation, small regions, and edge detail. The catalog
contains finite authored content, so difficulty reaches an expert plateau after
the first 100 unique appearances rather than increasing without limit.

## Broad progression

| Journey range | Pixel puzzles | Average complexity | Unique templates |
|---|---:|---:|---:|
${bands.join('\n')}

## Selection details

| Journey level | Pixel occurrence | Template ID | Matrix | Colors | Paintable | Regions | Small regions | Complexity | Repeat gap (occurrences) |
|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|
${rows.toString()}''';
}

String _expansionPlan(List<_Selection> selections) {
  final firstReuse = selections.firstWhere(
    (selection) => selection.ordinal >= 100,
  );
  return '''# Pixel Art catalog expansion plan

## Current limitation

The 100 approved artworks support one unique pass. The first reuse begins at
Pixel occurrence 101 near Journey level ${firstReuse.levelNumber}. No selection
algorithm can provide endless unique recognizable artwork from a finite catalog.
The version-8 selector broadens sustained expert reuse from 30 to
${PixelPictureCatalog.journeySelector.reusePoolSize} templates from the first
post-catalog appearance. Identical IDs are separated by a complete reuse cycle,
while levels 1–500 retain their first unique appearance mappings.

## Metadata contract

Authored template metadata remains stable and catalog-driven:

- `id` and `familyId`: permanent identity and compatibility keys
- localized English/Turkish names
- category
- minimum Journey level and authored difficulty
- rows, columns, background index, palette, and pixel matrix
- computed complexity: paintable cells, palette count/similarity, region count,
  small regions, and edge-detail ratio
- computed palette-family bucket for visual-repeat avoidance

The selector consumes this metadata list and contains no hardcoded template
IDs. A 200-, 300-, or 500-item catalog therefore uses every supplied item once
before a proportional high-difficulty reuse pool is needed.

## Recommended authored expansion

| Catalog size | Unique Pixel appearances | Approximate Journey reach | Recommendation |
|---:|---:|---:|---|
| 100 | 100 | ~500 | Current approved library; repetition is unavoidable afterward |
| 200 | 200 | ~1000 | Add advanced objects, animals, vehicles, and scenes |
| 300 | 300 | ~1500 | Add visually distinct expert subjects and palettes |
| 500 | 500 | ~2500 | Supports a long unique campaign before controlled reuse |

New artwork should be individually authored and approved. Random pixel patterns,
matrix scaling, recoloring an existing silhouette, or duplicate subject IDs do
not count as catalog growth. Adding artwork changes future deterministic
selection and therefore requires a deliberate Journey generation-version bump;
existing template IDs and completed level IDs remain untouched.
''';
}

class _Selection {
  const _Selection({
    required this.levelNumber,
    required this.ordinal,
    required this.assessment,
  });

  final int levelNumber;
  final int ordinal;
  final PixelPictureDifficultyAssessment assessment;
}
