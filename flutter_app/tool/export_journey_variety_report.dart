import 'dart:io';

import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  const generator = JourneyLevelGenerator();
  final report =
      StringBuffer()
        ..writeln('# Journey Color Variety Report')
        ..writeln()
        ..writeln(
          '| Level | Type | Family / figure | Difficulty | Nearby repeat |',
        )
        ..writeln('|---:|---|---|---|---|');
  final recentGradientFamilies = <JourneyColorFamilyId>[];
  String? previousPictureCategory;
  final previewLevels = <LevelDefinition>[];

  for (var number = 1; number <= 100; number++) {
    final level = generator.generate(number);
    if (level.puzzleType == JourneyPuzzleType.gradient) {
      final family = _family(level);
      final exactRepeat = recentGradientFamilies.reversed
          .take(5)
          .contains(family);
      final closeRepeat = recentGradientFamilies.reversed
          .take(2)
          .any(
            (previous) => JourneyColorFamily.areVisuallyClose(previous, family),
          );
      report.writeln(
        '| $number | Gradient | ${family.englishName} / ${family.turkishName} | '
        '${level.difficulty.name} | '
        '${exactRepeat
            ? 'exact recent family'
            : closeRepeat
            ? 'near recent family'
            : 'none'} |',
      );
      recentGradientFamilies.add(family);
      if (recentGradientFamilies.length > 5) recentGradientFamilies.removeAt(0);
      if (previewLevels.length < 30) previewLevels.add(level);
    } else {
      final template = PixelPictureCatalog.byId(level.pictureTemplateId!);
      final categoryRepeat = previousPictureCategory == template.category.name;
      report.writeln(
        '| $number | Pixel Coloring | ${template.englishName} / '
        '${template.turkishName} | ${level.difficulty.name} | '
        '${categoryRepeat ? 'same category as previous picture' : 'none'} |',
      );
      previousPictureCategory = template.category.name;
    }
  }

  File(
    '../docs/game_design/journey_color_variety_report.md',
  ).writeAsStringSync(report.toString());
  File(
    '../docs/game_design/journey_gradient_preview.html',
  ).writeAsStringSync(_previewHtml(previewLevels));
  stdout.writeln('Wrote Journey variety report and gradient preview.');
}

JourneyColorFamilyId _family(LevelDefinition level) {
  final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
  final middle = level.solutionTileOrder[level.solutionTileOrder.length ~/ 2];
  return JourneyColorFamily.nearestToColor(colors[middle]!);
}

String _previewHtml(List<LevelDefinition> levels) {
  final cards = StringBuffer();
  for (final level in levels) {
    final family = _family(level);
    final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
    cards
      ..writeln('<article>')
      ..writeln('<h2>Level ${level.number} · ${family.englishName}</h2>')
      ..writeln(
        '<p>${family.turkishName} · ${level.boardSize}×${level.boardSize} · '
        '${level.difficulty.name}</p>',
      )
      ..writeln('<div class="swatches">');
    for (final id in level.solutionTileOrder) {
      final hex = (colors[id]! & 0xffffff).toRadixString(16).padLeft(6, '0');
      cards.writeln('<span style="background:#$hex" title="#$hex"></span>');
    }
    cards
      ..writeln('</div>')
      ..writeln('</article>');
  }
  return '''<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Pixel Harmony · First 30 Journey Gradients</title>
<style>
body{margin:0;background:#f8f5ff;color:#302a46;font:15px system-ui,sans-serif}
main{max-width:1100px;margin:auto;padding:32px}h1{margin:0 0 8px}p{color:#716a86}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}
article{background:#fff;border:1px solid #e8e0f4;border-radius:18px;padding:16px}
h2{font-size:16px;margin:0}article p{margin:5px 0 12px}.swatches{display:flex;height:40px;
overflow:hidden;border-radius:10px}.swatches span{flex:1;min-width:2px}
</style></head><body><main><h1>First 30 Journey Gradients</h1>
<p>Exact dark-to-light solution palettes for visual diversity review.</p>
<section class="grid">$cards</section></main></body></html>''';
}
