import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

const tier1Palette = [
  0xFFF5F2EC,
  0xFFE34B67,
  0xFFFFC857,
  0xFF4E89AE,
  0xFF4F9D69,
];
const tier2Palette = [
  0xFFF5F2EC,
  0xFF334E68,
  0xFF5BC0EB,
  0xFFFFC857,
  0xFFE55934,
  0xFF6A4C93,
];
const tier3Palette = [
  0xFFF5F2EC,
  0xFF263238,
  0xFF3D7EA6,
  0xFF64B96A,
  0xFFFFC857,
  0xFFED6A5A,
  0xFF8D6AAE,
];
const tier4Palette = [
  0xFFF5F2EC,
  0xFF202A44,
  0xFF3A6EA5,
  0xFF57B8A5,
  0xFFFFCF5C,
  0xFFF07B5A,
  0xFFA55FA5,
  0xFFF4A6B8,
];
const tier5Palette = [
  0xFFF5F2EC,
  0xFF17243A,
  0xFF315B8A,
  0xFF4AA6A6,
  0xFF72B86B,
  0xFFFFD166,
  0xFFF07A5A,
  0xFF9B6BB3,
  0xFFF2A7B5,
];

PixelPictureTemplate curatedTemplate({
  required int number,
  required String id,
  required String englishName,
  required String turkishName,
  required PixelPictureCategory category,
  required int size,
  required List<int> palette,
  required List<String> art,
}) {
  if (art.length > size || art.any((row) => row.length > size)) {
    throw StateError('Authored artwork exceeds ${size}x$size: $id.');
  }
  final top = (size - art.length) ~/ 2;
  final pixels = List<int>.filled(size * size, 0);
  for (var sourceRow = 0; sourceRow < art.length; sourceRow++) {
    final row = art[sourceRow];
    final left = (size - row.length) ~/ 2;
    for (var sourceColumn = 0; sourceColumn < row.length; sourceColumn++) {
      final character = row.codeUnitAt(sourceColumn);
      if (character == 46) continue;
      final paletteIndex = character - 48;
      if (paletteIndex < 1 || paletteIndex >= palette.length) {
        throw StateError('Invalid authored color $character in $id.');
      }
      pixels[(top + sourceRow) * size + left + sourceColumn] = paletteIndex;
    }
  }
  final tier = (number - 1) ~/ 20;
  return PixelPictureTemplate(
    id: 'pixel_${number.toString().padLeft(3, '0')}_$id',
    familyId: id,
    englishName: englishName,
    turkishName: turkishName,
    category: category,
    minimumJourneyLevel: switch (tier) {
      0 => 5,
      1 => 101,
      2 => 201,
      3 => 301,
      _ => 401,
    },
    difficulty: switch (tier) {
      0 => PixelPictureDifficulty.beginner,
      1 => PixelPictureDifficulty.early,
      2 => PixelPictureDifficulty.medium,
      _ => PixelPictureDifficulty.advanced,
    },
    rows: size,
    columns: size,
    palette: List<int>.unmodifiable(palette),
    pixels: List<int>.unmodifiable(pixels),
  );
}
