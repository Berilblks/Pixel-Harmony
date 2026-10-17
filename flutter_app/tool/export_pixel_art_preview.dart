import 'dart:convert';
import 'dart:io';

import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  PixelPictureCatalog.validate();
  final output = File('../docs/game_design/pixel_art_template_preview.html');
  output.writeAsStringSync(_document());
  stdout.writeln('Wrote ${output.absolute.path}');
}

String _document() {
  final cards = <String>[];
  for (var index = 0; index < PixelPictureCatalog.templates.length; index++) {
    final template = PixelPictureCatalog.templates[index];
    final cells = <String>[];
    for (final paletteIndex in template.pixels) {
      final color = template.palette[paletteIndex] & 0x00ffffff;
      cells.add(
        '<span style="background:#${color.toRadixString(16).padLeft(6, '0')}"></span>',
      );
    }
    cards.add('''
      <article class="card">
        <header>
          <strong>${index + 1}. ${htmlEscape.convert(template.englishName)}</strong>
          <span>${htmlEscape.convert(template.turkishName)}</span>
        </header>
        <div class="art" style="--columns:${template.columns};--rows:${template.rows}">
          ${cells.join()}
        </div>
        <footer>${template.rows} × ${template.columns} · ${template.requiredPaletteIndices.length} colors · ${template.paintablePixelCount} painted</footer>
      </article>
    ''');
  }
  return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Pixel Harmony — 100 Pixel Art Templates</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 32px;
      color: #403a45;
      background: #f7f3fb;
      font: 15px/1.35 Arial, sans-serif;
    }
    h1 { margin: 0 0 6px; font-size: 28px; }
    .summary { margin: 0 0 24px; color: #716979; }
    .sheet {
      display: grid;
      grid-template-columns: repeat(5, minmax(0, 1fr));
      gap: 18px;
    }
    .card {
      min-width: 0;
      padding: 14px;
      border: 1px solid #ded5e6;
      border-radius: 16px;
      background: #fff;
      box-shadow: 0 4px 14px rgba(63, 51, 73, .07);
    }
    header { min-height: 44px; }
    header strong, header span { display: block; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
    header span { color: #776f7d; font-size: 13px; }
    .art {
      display: grid;
      grid-template-columns: repeat(var(--columns), 1fr);
      grid-template-rows: repeat(var(--rows), 1fr);
      width: 100%;
      aspect-ratio: 1;
      margin: 10px 0;
      overflow: hidden;
      border: 1px solid #d8d0df;
      background: white;
      image-rendering: pixelated;
    }
    .art span { min-width: 0; min-height: 0; }
    footer { color: #776f7d; font-size: 12px; white-space: nowrap; }
  </style>
</head>
<body>
  <h1>Pixel Harmony — 100 Pixel Art Template Review</h1>
  <p class="summary">Canonical completed artwork · nearest-neighbor grid · generated directly from PixelPictureCatalog</p>
  <main class="sheet">${cards.join()}</main>
</body>
</html>
''';
}
