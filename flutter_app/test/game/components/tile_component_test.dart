import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';

void main() {
  TileComponent createTile() {
    return TileComponent(
      model: const TileModel(id: 'tile', color: Color(0xFF5BC0EB)),
      onDragStarted: (_) => true,
      onDragUpdated: (_, delta) => Vector2.zero() + delta,
      onDragFinished: (_) {},
      onDragCancelled: (_) {},
    );
  }

  test('drag feedback scales up subtly and settles back to rest', () {
    final tile = createTile();

    tile.startDragFeedback();
    tile.update(0.16);

    expect(tile.isDragFeedbackActive, isTrue);
    expect(tile.visualScale, closeTo(1.045, 0.001));

    tile.endDragFeedback();
    tile.update(0.16);

    expect(tile.isDragFeedbackActive, isFalse);
    expect(tile.visualScale, closeTo(1, 0.001));
  });
}
