import 'package:pixel_harmony/game/generation/seeded_random.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class PaletteGenerator {
  const PaletteGenerator();

  List<int> generate({
    required int seed,
    required int boardSize,
    required LevelDifficulty difficulty,
    required int attempt,
  }) {
    final random = SeededRandom(_mix(seed, attempt));
    final profile = _PaletteProfile.forDifficulty(difficulty);
    final baseHue = random.nextDouble() * 360;
    final saturation = profile.saturation + random.nextSignedDouble() * 0.04;
    final lightness = profile.lightness + random.nextSignedDouble() * 0.035;
    final horizontalHue = profile.hueSpan * (0.8 + random.nextDouble() * 0.4);
    final verticalHue = profile.hueSpan * (0.45 + random.nextDouble() * 0.35);
    final horizontalLight =
        profile.lightnessSpan * (0.75 + random.nextDouble() * 0.35);
    final verticalLight =
        profile.lightnessSpan * (0.45 + random.nextDouble() * 0.35);

    return List.generate(boardSize * boardSize, (index) {
      final row = index ~/ boardSize;
      final column = index % boardSize;
      final x = column / (boardSize - 1);
      final y = row / (boardSize - 1);
      final hue = _wrapHue(baseHue + horizontalHue * x + verticalHue * y);
      final localSaturation = _clamp(
        saturation + (x - y) * profile.saturationVariation,
        0.42,
        0.78,
      );
      final localLightness = _clamp(
        lightness + horizontalLight * (x - 0.5) + verticalLight * (y - 0.5),
        0.36,
        0.72,
      );
      return _hslToArgb(hue, localSaturation, localLightness);
    }, growable: false);
  }

  static int _mix(int seed, int attempt) {
    return seed ^ ((attempt + 1) * 0x45d9f3b);
  }

  static double _wrapHue(double hue) => hue % 360;

  static double _clamp(double value, double minimum, double maximum) =>
      value.clamp(minimum, maximum).toDouble();

  static int _hslToArgb(double hue, double saturation, double lightness) {
    final chroma = (1 - (2 * lightness - 1).abs()) * saturation;
    final section = hue / 60;
    final secondary = chroma * (1 - ((section % 2) - 1).abs());
    final (red, green, blue) = switch (section.floor() % 6) {
      0 => (chroma, secondary, 0.0),
      1 => (secondary, chroma, 0.0),
      2 => (0.0, chroma, secondary),
      3 => (0.0, secondary, chroma),
      4 => (secondary, 0.0, chroma),
      _ => (chroma, 0.0, secondary),
    };
    final match = lightness - chroma / 2;
    final redByte = ((red + match) * 255).round().clamp(0, 255);
    final greenByte = ((green + match) * 255).round().clamp(0, 255);
    final blueByte = ((blue + match) * 255).round().clamp(0, 255);
    return 0xff000000 | (redByte << 16) | (greenByte << 8) | blueByte;
  }
}

class _PaletteProfile {
  const _PaletteProfile({
    required this.hueSpan,
    required this.saturation,
    required this.lightness,
    required this.lightnessSpan,
    required this.saturationVariation,
  });

  factory _PaletteProfile.forDifficulty(LevelDifficulty difficulty) {
    return switch (difficulty) {
      LevelDifficulty.tutorial =>
        throw ArgumentError('Tutorial palettes are not procedural.'),
      LevelDifficulty.easy => const _PaletteProfile(
        hueSpan: 72,
        saturation: 0.64,
        lightness: 0.56,
        lightnessSpan: 0.24,
        saturationVariation: 0.08,
      ),
      LevelDifficulty.medium => const _PaletteProfile(
        hueSpan: 54,
        saturation: 0.60,
        lightness: 0.56,
        lightnessSpan: 0.19,
        saturationVariation: 0.06,
      ),
      LevelDifficulty.hard => const _PaletteProfile(
        hueSpan: 39,
        saturation: 0.57,
        lightness: 0.55,
        lightnessSpan: 0.15,
        saturationVariation: 0.045,
      ),
      LevelDifficulty.expert => const _PaletteProfile(
        hueSpan: 29,
        saturation: 0.54,
        lightness: 0.55,
        lightnessSpan: 0.12,
        saturationVariation: 0.035,
      ),
    };
  }

  final double hueSpan;
  final double saturation;
  final double lightness;
  final double lightnessSpan;
  final double saturationVariation;
}
