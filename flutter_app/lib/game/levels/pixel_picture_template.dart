class PixelPictureTemplate {
  const PixelPictureTemplate({
    required this.id,
    required this.familyId,
    required this.englishName,
    required this.turkishName,
    required this.category,
    required this.minimumJourneyLevel,
    required this.difficulty,
    required this.rows,
    required this.columns,
    required this.palette,
    required this.pixels,
    this.backgroundPaletteIndex = 0,
  });

  final String id;
  final String familyId;
  final String englishName;
  final String turkishName;
  final PixelPictureCategory category;
  final int minimumJourneyLevel;
  final PixelPictureDifficulty difficulty;
  final int rows;
  final int columns;
  final List<int> palette;
  final List<int> pixels;
  final int backgroundPaletteIndex;

  int get size {
    if (rows != columns) {
      throw StateError('Pixel Coloring boards must be square: $id.');
    }
    return rows;
  }

  int get paintablePixelCount =>
      pixels.where((index) => index != backgroundPaletteIndex).length;
  Set<int> get requiredPaletteIndices =>
      pixels.where((index) => index != backgroundPaletteIndex).toSet();

  bool isPaintable(int cellIndex) =>
      pixels[cellIndex] != backgroundPaletteIndex;

  int identifierForPalette(int paletteIndex) {
    if (paletteIndex == backgroundPaletteIndex) return 0;
    final indices = requiredPaletteIndices.toList()..sort();
    return indices.indexOf(paletteIndex) + 1;
  }

  void validate() {
    if (id.isEmpty ||
        familyId.isEmpty ||
        englishName.isEmpty ||
        turkishName.isEmpty) {
      throw StateError('Pixel Picture metadata cannot be empty.');
    }
    if (minimumJourneyLevel < 1 ||
        rows < 5 ||
        rows > 16 ||
        columns < 5 ||
        columns > 16 ||
        rows != columns ||
        pixels.length != rows * columns) {
      throw StateError('Invalid dimensions for Pixel Picture $id.');
    }
    if (palette.length < 2 ||
        pixels.any((index) => index < 0 || index >= palette.length)) {
      throw StateError('Invalid palette indices for Pixel Picture $id.');
    }
    if (backgroundPaletteIndex < 0 ||
        backgroundPaletteIndex >= palette.length ||
        requiredPaletteIndices.isEmpty ||
        paintablePixelCount < 5) {
      throw StateError('Invalid paintable palette for Pixel Picture $id.');
    }
  }
}

enum PixelPictureCategory {
  symbol,
  nature,
  food,
  animal,
  object,
  vehicle,
  scene,
}

enum PixelPictureDifficulty { beginner, early, medium, advanced }
