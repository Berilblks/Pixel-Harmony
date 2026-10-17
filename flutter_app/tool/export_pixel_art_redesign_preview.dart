import 'dart:convert';
import 'dart:io';

import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

const _targetIds = <String>[
  'pixel_002_star',
  'pixel_003_smiley_face',
  'pixel_006_cloud',
  'pixel_008_lightning_bolt',
  'pixel_009_diamond',
  'pixel_016_leaf',
  'pixel_017_balloon',
  'pixel_022_bee',
  'pixel_024_fish',
  'pixel_025_turtle',
  'pixel_029_penguin',
  'pixel_033_panda_face',
  'pixel_034_fox_face',
  'pixel_035_bear_face',
  'pixel_036_crown',
  'pixel_038_camera',
  'pixel_041_hot_air_balloon',
  'pixel_046_bicycle',
  'pixel_047_car',
  'pixel_049_train',
  'pixel_051_teapot',
  'pixel_053_donut',
  'pixel_058_book',
  'pixel_059_paint_palette',
  'pixel_064_peacock',
  'pixel_065_dolphin',
  'pixel_066_whale',
  'pixel_073_elephant',
  'pixel_074_giraffe',
  'pixel_075_lion',
  'pixel_076_tiger',
  'pixel_077_unicorn',
  'pixel_078_swan',
  'pixel_079_hummingbird',
  'pixel_080_koi_fish',
  'pixel_087_small_island',
  'pixel_089_flower_field',
  'pixel_082_mountains_at_sunrise',
  'pixel_092_sailboat_at_sea',
  'pixel_095_snowy_mountain',
  'pixel_096_waterfall_scene',
  'pixel_098_city_skyline_night',
  'pixel_100_northern_lights',
];

void main() {
  PixelPictureCatalog.validate();
  final templates = _targetIds.map(PixelPictureCatalog.byId).toList();
  if (templates.length != 43 ||
      templates.map((e) => e.id).toSet().length != 43) {
    throw StateError(
      'The redesign preview must contain exactly 43 unique templates.',
    );
  }
  final output = File('../docs/game_design/pixel_art_redesign_proposals.html');
  output.writeAsStringSync(_document(templates));
  stdout.writeln('Wrote ${output.absolute.path}');
}

String _document(List<dynamic> templates) {
  final cards = <String>[];
  for (var index = 0; index < templates.length; index++) {
    final template = templates[index];
    final currentCells = <String>[];
    for (final paletteIndex in template.pixels as List<int>) {
      final color = (template.palette[paletteIndex] as int) & 0x00ffffff;
      currentCells.add(
        '<i style="background:#${color.toRadixString(16).padLeft(6, '0')}"></i>',
      );
    }
    cards.add('''
      <article class="card">
        <h2>${index + 1}. ${htmlEscape.convert(template.turkishName as String)}</h2>
        <p>${htmlEscape.convert(template.englishName as String)} · <code>${template.id}</code></p>
        <div class="comparison">
          <section><b>MEVCUT</b><div class="current art" style="--n:${template.columns}">${currentCells.join()}</div><small>${template.rows}×${template.columns} · ${template.requiredPaletteIndices.length} renk</small></section>
          <span class="arrow">→</span>
          <section><b>ÖNERİLEN</b><canvas class="art proposed" data-id="${template.id}" aria-label="${htmlEscape.convert(template.turkishName as String)} önerisi"></canvas><small class="proposal-meta"></small></section>
        </div>
      </article>
    ''');
  }
  return '''<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Pixel Harmony — 43 Pixel Art Yeniden Tasarım Önerisi</title>
<style>
*{box-sizing:border-box}body{margin:0;padding:32px;color:#3e3745;background:#f4eff8;font:14px/1.35 Arial,sans-serif}h1{margin:0 0 6px;font-size:30px}.lead{margin:0 0 24px;color:#6f6677}.sheet{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.card{padding:16px;border:1px solid #ddd2e4;border-radius:18px;background:#fff;box-shadow:0 5px 16px #513b6710}.card h2{margin:0;font-size:17px}.card>p{margin:3px 0 12px;color:#756d7b;font-size:12px}.comparison{display:grid;grid-template-columns:1fr 24px 1fr;align-items:center;gap:8px}.comparison section{text-align:center}.comparison b{display:block;margin-bottom:6px;color:#786d82;font-size:11px;letter-spacing:.08em}.art{width:100%;aspect-ratio:1;border:1px solid #d8cedf;background:#fff;image-rendering:pixelated}.current{display:grid;grid-template-columns:repeat(var(--n),1fr)}.current i{display:block}.proposed{display:block}.arrow{color:#9a82b5;font-size:22px;text-align:center}small{display:block;margin-top:6px;color:#756d7b;font-size:11px}code{font-size:10px}@media(max-width:900px){.sheet{grid-template-columns:1fr}}
</style></head><body>
<h1>43 Pixel Art — Önce / Sonra Tasarım Önerileri</h1>
<p class="lead">Onay öncesi geliştirme önizlemesi. Sol: mevcut üretim matrisi. Sağ: önerilen tanınabilir yeni çizim. Üretim şablonları henüz değiştirilmedi.</p>
<main class="sheet">${cards.join()}</main>
<script src="../../flutter_app/tool/pixel_art_redesign_proposals.js"></script>
</body></html>''';
}
