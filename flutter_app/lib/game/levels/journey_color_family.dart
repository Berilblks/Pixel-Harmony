import 'dart:math' as math;

enum JourneyColorFamilyId {
  pink('Pink', 'Pembe', 340),
  purple('Purple', 'Mor', 282),
  lavender('Lavender', 'Lavanta', 258),
  blue('Blue', 'Mavi', 218),
  turquoise('Turquoise', 'Turkuaz', 184),
  mint('Mint', 'Mint yeşili', 158),
  emerald('Emerald', 'Zümrüt yeşili', 140),
  yellow('Yellow', 'Sarı', 56),
  gold('Gold', 'Altın', 44),
  orange('Orange', 'Turuncu', 29),
  coral('Coral', 'Mercan', 10),
  red('Red', 'Kırmızı', 0),
  peach('Peach', 'Şeftali', 22),
  fuchsia('Fuchsia', 'Fuşya', 316);

  const JourneyColorFamilyId(this.englishName, this.turkishName, this.hue);

  final String englishName;
  final String turkishName;
  final double hue;
}

abstract final class JourneyColorFamily {
  static const _balancedCycle = [
    JourneyColorFamilyId.pink,
    JourneyColorFamilyId.purple,
    JourneyColorFamilyId.blue,
    JourneyColorFamilyId.turquoise,
    JourneyColorFamilyId.orange,
    JourneyColorFamilyId.lavender,
    JourneyColorFamilyId.mint,
    JourneyColorFamilyId.coral,
    JourneyColorFamilyId.gold,
    JourneyColorFamilyId.emerald,
    JourneyColorFamilyId.red,
    JourneyColorFamilyId.fuchsia,
    JourneyColorFamilyId.yellow,
    JourneyColorFamilyId.peach,
  ];

  static JourneyColorFamilyId forGradientOrdinal(int ordinal) {
    if (ordinal < 0) throw ArgumentError.value(ordinal, 'ordinal');
    final block = ordinal ~/ JourneyColorFamilyId.values.length;
    final position = ordinal % JourneyColorFamilyId.values.length;
    var order = _balancedCycle;
    for (var currentBlock = 1; currentBlock <= block; currentBlock++) {
      order = _nextBlockOrder(currentBlock, order);
    }
    return order[position];
  }

  static JourneyColorFamilyId nearestToColor(int color) {
    final hue = hueDegrees(color);
    return JourneyColorFamilyId.values.reduce(
      (first, second) =>
          circularHueDistance(hue, first.hue) <=
                  circularHueDistance(hue, second.hue)
              ? first
              : second,
    );
  }

  static bool areVisuallyClose(
    JourneyColorFamilyId first,
    JourneyColorFamilyId second,
  ) => circularHueDistance(first.hue, second.hue) < 32;

  static List<JourneyColorFamilyId> _nextBlockOrder(
    int block,
    List<JourneyColorFamilyId> previous,
  ) {
    final count = _balancedCycle.length;
    final preferred = _mix(block) % (count * 2);
    for (var attempt = 0; attempt < count * 2; attempt++) {
      final variant = (preferred + attempt) % (count * 2);
      final source =
          variant >= count
              ? _balancedCycle.reversed.toList(growable: false)
              : _balancedCycle;
      final offset = variant % count;
      final candidate = [
        for (var index = 0; index < count; index++)
          source[(offset + index) % count],
      ];
      final recent = previous.sublist(previous.length - 5);
      var valid = true;
      for (final family in candidate.take(5)) {
        if (recent.contains(family) ||
            recent.reversed
                .take(2)
                .any((item) => areVisuallyClose(item, family))) {
          valid = false;
          break;
        }
        recent
          ..add(family)
          ..removeAt(0);
      }
      if (valid) return List.unmodifiable(candidate);
    }
    return _balancedCycle;
  }

  static int _mix(int value) {
    var result = value & 0xffffffff;
    result ^= result >>> 16;
    result = (result * 0x7feb352d) & 0xffffffff;
    result ^= result >>> 15;
    return result & 0x7fffffff;
  }

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
