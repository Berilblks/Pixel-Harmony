import 'dart:io';

import 'package:pixel_harmony/game/generation/difficulty_evaluator.dart';
import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

void main() {
  const generator = JourneyLevelGenerator();
  const transitions = {100, 101, 120, 121, 150, 151, 180, 181, 200};
  final report =
      StringBuffer()
        ..writeln('# Journey 101–200 progression audit')
        ..writeln()
        ..writeln(
          'Generated deterministically with Journey generation version '
          '${JourneyLevelGenerator.generationVersion}. Levels 1–100 retain their '
          'version-6 content signatures.',
        )
        ..writeln()
        ..writeln(
          '| Level | Type | Board | Difficulty | Parameters | Family / template |',
        )
        ..writeln('|---:|---|---:|---:|---|---|');

  for (var number = 90; number <= 210; number++) {
    final level = generator.generate(number);
    final marker = transitions.contains(number) ? '**' : '';
    if (level.puzzleType == JourneyPuzzleType.pixelPicture) {
      report.writeln(
        '| $marker$number$marker | Pixel Coloring | '
        '${level.boardSize}×${level.boardSize} | ${level.difficultyScore} | '
        'curated template | `${level.pictureTemplateId}` |',
      );
      continue;
    }
    final profile = generator.gradientProfileFor(number);
    final family = _family(level);
    final evaluation = _evaluation(level);
    report.writeln(
      '| $marker$number$marker | Gradient | ${level.boardSize}×${level.boardSize} '
      '| ${level.difficultyScore} | '
      'shuffle ${(profile.shuffleFraction * 100).toStringAsFixed(1)}%; '
      'misplaced ${evaluation.misplacedTiles}; swaps ${evaluation.minimumSwaps}; '
      'ΔE floor ${profile.minimumDeltaE.toStringAsFixed(2)}; '
      'luminance ${profile.lowLuminance.toStringAsFixed(3)}–'
      '${profile.highLuminance.toStringAsFixed(3)} | ${family.name} |',
    );
  }

  final docs = Directory('../docs/game_design');
  docs.createSync(recursive: true);
  File(
    '${docs.path}/journey_101_200_progression_report.md',
  ).writeAsStringSync(report.toString());
  File(
    '${docs.path}/journey_101_200_gradient_previews.html',
  ).writeAsStringSync(_previewHtml(generator));
}

DifficultyEvaluation _evaluation(LevelDefinition level) {
  return const DifficultyEvaluator().evaluate(
    boardSize: level.boardSize,
    solutionColors: [
      for (final id in level.solutionTileOrder)
        level.tiles.firstWhere((tile) => tile.id == id).colorValue,
    ],
    initialOrder: level.initialTileOrder,
    solutionOrder: level.solutionTileOrder,
  );
}

JourneyColorFamilyId _family(LevelDefinition level) {
  final byId = {for (final tile in level.tiles) tile.id: tile.colorValue};
  final middle = level.solutionTileOrder[level.solutionTileOrder.length ~/ 2];
  return JourneyColorFamily.nearestToColor(byId[middle]!);
}

String _previewHtml(JourneyLevelGenerator generator) {
  const requested = [100, 101, 120, 121, 150, 180, 200];
  final cards = StringBuffer();
  for (final target in requested) {
    final actual = _nearestGradient(generator, target);
    final level = generator.generate(actual);
    final byId = {for (final tile in level.tiles) tile.id: tile.colorValue};
    cards
      ..writeln('<section class="card">')
      ..writeln(
        '<h2>Requested $target — Level $actual '
        '${actual == target ? '' : '(nearest Gradient substitution)'}</h2>',
      )
      ..writeln(
        '<p>${level.boardSize}×${level.boardSize} · ${_family(level).name} · '
        'difficulty ${level.difficultyScore}</p>',
      )
      ..writeln('<div class="pair"><div><h3>Initial board</h3>')
      ..writeln(_grid(level.initialTileOrder, byId, level.boardSize))
      ..writeln('</div><div><h3>Dark-to-light solution</h3>')
      ..writeln(_grid(level.solutionTileOrder, byId, level.boardSize))
      ..writeln('</div></div></section>');
  }
  return '''<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Journey 101–200 Gradient previews</title>
<style>
body{font:15px system-ui;background:#f7f3fb;color:#302940;margin:0;padding:28px}
main{max-width:1100px;margin:auto}.card{background:white;border-radius:18px;padding:20px;margin:18px 0;box-shadow:0 4px 18px #44226612}
.pair{display:flex;gap:32px;flex-wrap:wrap}.grid{display:grid;width:300px;aspect-ratio:1;gap:1px;background:#ddd;padding:1px}.cell{min-width:0}h2{margin-top:0}h3{font-size:14px;color:#71677d}
</style></head><body><main><h1>Journey 101–200 Gradient previews</h1>
<p>Each preview shows the deterministic initial board beside its solution. Pixel Coloring targets are replaced by the nearest Gradient level and labelled.</p>
${cards.toString()}</main></body></html>''';
}

int _nearestGradient(JourneyLevelGenerator generator, int target) {
  if (generator.puzzleTypeFor(target) == JourneyPuzzleType.gradient) {
    return target;
  }
  for (var distance = 1; distance < 10; distance++) {
    final lower = target - distance;
    if (lower > 0 &&
        generator.puzzleTypeFor(lower) == JourneyPuzzleType.gradient) {
      return lower;
    }
    final upper = target + distance;
    if (generator.puzzleTypeFor(upper) == JourneyPuzzleType.gradient) {
      return upper;
    }
  }
  throw StateError('No Gradient level near $target.');
}

String _grid(List<String> order, Map<String, int> colors, int size) {
  final cells =
      [
        for (final id in order)
          '<span class="cell" style="background:${_hex(colors[id]!)}"></span>',
      ].join();
  return '<div class="grid" style="grid-template-columns:repeat($size,1fr)">'
      '$cells</div>';
}

String _hex(int color) =>
    '#${(color & 0xffffff).toRadixString(16).padLeft(6, '0')}';
