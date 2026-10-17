import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations_en.dart';
import 'package:pixel_harmony/core/localization/app_localizations_tr.dart';
import 'package:pixel_harmony/core/localization/pixel_picture_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_art_renderer.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  test('every final artwork exactly reuses its target pixel matrix', () {
    for (final template in PixelPictureCatalog.templates) {
      final rendered = PixelArtRenderData.fromTemplate(template);
      expect(rendered.rows, template.rows, reason: template.id);
      expect(rendered.columns, template.columns, reason: template.id);
      expect(
        rendered.palette,
        orderedEquals(template.palette),
        reason: template.id,
      );
      expect(
        rendered.cellPaletteIndices,
        orderedEquals(template.pixels),
        reason: template.id,
      );
    }
  });

  test('Butterfly final artwork has no alternate representation', () {
    final butterfly = PixelPictureCatalog.byId('butterfly');
    final rendered = PixelArtRenderData.fromTemplate(butterfly);

    expect(rendered.rows * rendered.columns, butterfly.pixels.length);
    expect(rendered.palette, orderedEquals(butterfly.palette));
    expect(rendered.cellPaletteIndices, orderedEquals(butterfly.pixels));
  });

  testWidgets('renderer paints canonical data as crisp pixel art', (
    tester,
  ) async {
    final template = PixelPictureCatalog.templates.first;
    final data = PixelArtRenderData.fromTemplate(template);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PixelArtRenderer(data: data))),
    );

    final artwork = tester.widget<CustomPaint>(
      find.byKey(const Key('completedPixelArtCanvas')),
    );
    final painter = artwork.painter! as PixelArtPainter;
    expect(painter.data.cellPaletteIndices, orderedEquals(template.pixels));
    expect(painter.data.palette, orderedEquals(template.palette));
    expect(tester.takeException(), isNull);
  });

  test('every target figure has English and Turkish localization', () {
    final english = AppLocalizationsEn();
    final turkish = AppLocalizationsTr();

    for (final template in PixelPictureCatalog.templates) {
      expect(localizedPixelFigureName(english, template), isNotEmpty);
      expect(localizedPixelFigureName(turkish, template), isNotEmpty);
    }
  });
}
