import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_art_renderer.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  if (kReleaseMode) {
    throw UnsupportedError('The Pixel Art contact sheet is debug-only.');
  }
  runApp(const PixelArtContactSheetApp());
}

class PixelArtContactSheetApp extends StatelessWidget {
  const PixelArtContactSheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF527A75)),
      home: const PixelArtContactSheetScreen(),
    );
  }
}

class PixelArtContactSheetScreen extends StatelessWidget {
  const PixelArtContactSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pixel Art — 100 Template Review')),
      body: GridView.builder(
        key: const Key('pixelArtContactSheet'),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190,
          mainAxisExtent: 240,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: PixelPictureCatalog.templates.length,
        itemBuilder: (context, index) {
          final template = PixelPictureCatalog.templates[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${template.englishName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    template.turkishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          key: Key('contactSheetArt_${template.id}'),
                          painter: PixelArtPainter(
                            PixelArtRenderData.fromTemplate(template),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${template.rows} × ${template.columns}  •  '
                    '${template.paintablePixelCount} pixels  •  '
                    '${template.requiredPaletteIndices.length} colors',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
