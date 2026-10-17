import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

enum PixelPaintResult { painted, wrongColor, alreadyPainted, notPaintable }

class PixelColoringState {
  PixelColoringState({
    required this.template,
    required List<bool> paintedCells,
    required this.selectedPaletteIndex,
  }) : paintedCells = List.unmodifiable(paintedCells),
       assert(paintedCells.length == template.pixels.length);

  factory PixelColoringState.initial(PixelPictureTemplate template) {
    final required = template.requiredPaletteIndices;
    return PixelColoringState(
      template: template,
      paintedCells: List.filled(template.pixels.length, false),
      selectedPaletteIndex: required.first,
    );
  }

  final PixelPictureTemplate template;
  final List<bool> paintedCells;
  final int selectedPaletteIndex;

  bool get completed {
    for (var index = 0; index < template.pixels.length; index++) {
      if (template.isPaintable(index) && !paintedCells[index]) return false;
    }
    return true;
  }

  int get paintedCount => paintedCells.where((painted) => painted).length;

  bool isPaletteComplete(int paletteIndex) {
    for (var index = 0; index < template.pixels.length; index++) {
      if (template.pixels[index] == paletteIndex && !paintedCells[index]) {
        return false;
      }
    }
    return true;
  }

  PixelColoringState selectPalette(int paletteIndex) {
    if (!template.requiredPaletteIndices.contains(paletteIndex)) {
      throw ArgumentError.value(paletteIndex, 'paletteIndex');
    }
    return PixelColoringState(
      template: template,
      paintedCells: paintedCells,
      selectedPaletteIndex: paletteIndex,
    );
  }

  (PixelColoringState, PixelPaintResult) paint(int cellIndex) {
    RangeError.checkValidIndex(cellIndex, template.pixels, 'cellIndex');
    if (!template.isPaintable(cellIndex)) {
      return (this, PixelPaintResult.notPaintable);
    }
    if (paintedCells[cellIndex]) {
      return (this, PixelPaintResult.alreadyPainted);
    }
    if (template.pixels[cellIndex] != selectedPaletteIndex) {
      return (this, PixelPaintResult.wrongColor);
    }

    final nextPainted = List<bool>.of(paintedCells)..[cellIndex] = true;
    var nextPalette = selectedPaletteIndex;
    final intermediate = PixelColoringState(
      template: template,
      paintedCells: nextPainted,
      selectedPaletteIndex: selectedPaletteIndex,
    );
    if (intermediate.isPaletteComplete(selectedPaletteIndex)) {
      nextPalette = template.requiredPaletteIndices.firstWhere(
        (paletteIndex) => !intermediate.isPaletteComplete(paletteIndex),
        orElse: () => selectedPaletteIndex,
      );
    }
    return (
      PixelColoringState(
        template: template,
        paintedCells: nextPainted,
        selectedPaletteIndex: nextPalette,
      ),
      PixelPaintResult.painted,
    );
  }
}
