import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/debug/pixel_art_contact_sheet.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  testWidgets('debug contact sheet lazily renders all curated artwork', (
    tester,
  ) async {
    await tester.pumpWidget(const PixelArtContactSheetApp());

    expect(find.byKey(const Key('pixelArtContactSheet')), findsOneWidget);
    expect(find.text('1. Heart'), findsOneWidget);
    expect(
      find.byKey(const Key('contactSheetArt_pixel_001_heart')),
      findsOneWidget,
    );
    expect(PixelPictureCatalog.templates, hasLength(100));
    expect(find.byType(CustomPaint).evaluate().length, lessThan(30));

    await tester.scrollUntilVisible(
      find.text('100. Northern Lights Landscape'),
      900,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('100. Northern Lights Landscape'), findsOneWidget);
    expect(
      find.byKey(const Key('contactSheetArt_pixel_100_northern_lights')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
