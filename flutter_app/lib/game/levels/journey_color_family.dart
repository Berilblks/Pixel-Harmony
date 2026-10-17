import 'dart:math' as math;

abstract final class JourneyColorFamily {
  static double hueDegrees(int color) {
    final red = ((color >> 16) & 0xff) / 255;
    final green = ((color >> 8) & 0xff) / 255;
    final blue = (color & 0xff) / 255;
    final maximum = math.max(red, math.max(green, blue));
    final minimum = math.min(red, math.min(green, blue));
    final delta = maximum - minimum;
    if (delta == 0) return 0;
    final hue = switch (maximum) {
      final value when value == red => 60 * (((green - blue) / delta) % 6),
      final value when value == green => 60 * ((blue - red) / delta + 2),
      _ => 60 * ((red - green) / delta + 4),
    };
    return hue < 0 ? hue + 360 : hue;
  }

  static double circularHueDistance(double first, double second) {
    final direct = (first - second).abs() % 360;
    return math.min(direct, 360 - direct);
  }

  static int familyBucket(int color) => (hueDegrees(color) / 20).floor() % 18;
}
