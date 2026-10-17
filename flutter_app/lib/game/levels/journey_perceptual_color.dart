import 'dart:math' as math;

abstract final class JourneyPerceptualColor {
  static double deltaE(int first, int second) {
    final a = _lab(first);
    final b = _lab(second);
    final dl = a.$1 - b.$1;
    final da = a.$2 - b.$2;
    final db = a.$3 - b.$3;
    return math.sqrt(dl * dl + da * da + db * db);
  }

  static (double, double, double) _lab(int color) {
    double linear(int byte) {
      final value = byte / 255;
      return value <= 0.04045
          ? value / 12.92
          : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    }

    final red = linear((color >> 16) & 0xff);
    final green = linear((color >> 8) & 0xff);
    final blue = linear(color & 0xff);
    final x = (red * 0.4124 + green * 0.3576 + blue * 0.1805) / 0.95047;
    final y = (red * 0.2126 + green * 0.7152 + blue * 0.0722);
    final z = (red * 0.0193 + green * 0.1192 + blue * 0.9505) / 1.08883;
    double transform(double value) =>
        value > 0.008856
            ? math.pow(value, 1 / 3).toDouble()
            : 7.787 * value + 16 / 116;
    final fx = transform(x);
    final fy = transform(y);
    final fz = transform(z);
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }
}
