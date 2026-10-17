import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

class PixelColoringSession {
  PixelColoringSession({required PixelPictureTemplate template})
    : _state = PixelColoringState.initial(template);

  PixelColoringState _state;

  PixelColoringState get state => _state;

  void selectPalette(int paletteIndex) {
    if (_state.completed) return;
    _state = _state.selectPalette(paletteIndex);
  }

  PixelPaintResult paint(int cellIndex) {
    if (_state.completed) return PixelPaintResult.alreadyPainted;
    final result = _state.paint(cellIndex);
    _state = result.$1;
    return result.$2;
  }

  int? hintCellIndex() {
    if (_state.completed) return null;
    for (var index = 0; index < _state.template.pixels.length; index++) {
      if (_state.template.pixels[index] == _state.selectedPaletteIndex &&
          !_state.paintedCells[index]) {
        return index;
      }
    }
    for (var index = 0; index < _state.template.pixels.length; index++) {
      if (_state.template.isPaintable(index) && !_state.paintedCells[index]) {
        return index;
      }
    }
    return null;
  }

  bool applyHint() {
    final index = hintCellIndex();
    if (index == null) return false;
    final targetPalette = _state.template.pixels[index];
    _state = _state.selectPalette(targetPalette);
    return paint(index) == PixelPaintResult.painted;
  }
}
