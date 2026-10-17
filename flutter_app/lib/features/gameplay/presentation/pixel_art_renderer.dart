import 'package:flutter/material.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

/// Immutable render input derived directly from the canonical coloring template.
class PixelArtRenderData {
  const PixelArtRenderData({
    required this.rows,
    required this.columns,
    required this.palette,
    required this.cellPaletteIndices,
  });

  factory PixelArtRenderData.fromTemplate(PixelPictureTemplate template) =>
      PixelArtRenderData(
        rows: template.rows,
        columns: template.columns,
        palette: List<int>.unmodifiable(template.palette),
        cellPaletteIndices: List<int>.unmodifiable(template.pixels),
      );

  final int rows;
  final int columns;
  final List<int> palette;
  final List<int> cellPaletteIndices;
}

/// Presents the exact target cells as crisp, gapless pixel art.
class PixelArtRenderer extends StatelessWidget {
  const PixelArtRenderer({super.key, required this.data});

  final PixelArtRenderData data;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F1EC), Color(0xFFE8DED8)],
          ),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.78,
            child: AspectRatio(
              aspectRatio: data.columns / data.rows,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF514B45).withValues(alpha: 0.16),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: CustomPaint(
                  key: const Key('completedPixelArtCanvas'),
                  painter: PixelArtPainter(data),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelArtPainter extends CustomPainter {
  const PixelArtPainter(this.data);

  final PixelArtRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / data.columns;
    final cellHeight = size.height / data.rows;
    final paint = Paint()..isAntiAlias = false;

    for (var index = 0; index < data.cellPaletteIndices.length; index++) {
      final row = index ~/ data.columns;
      final column = index % data.columns;
      paint.color = Color(data.palette[data.cellPaletteIndices[index]]);
      canvas.drawRect(
        Rect.fromLTRB(
          column * cellWidth,
          row * cellHeight,
          (column + 1) * cellWidth,
          (row + 1) * cellHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PixelArtPainter oldDelegate) => oldDelegate.data != data;
}
