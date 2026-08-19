/// A small, platform-independent xorshift32 pseudo-random number generator.
///
/// Its sequence is part of procedural generation version 1 and must not be
/// changed without increasing that version.
class SeededRandom {
  SeededRandom(int seed) : _state = _normalizeSeed(seed);

  int _state;

  int nextUint32() {
    var value = _state;
    value ^= (value << 13) & _mask32;
    value ^= value >>> 17;
    value ^= (value << 5) & _mask32;
    return _state = value & _mask32;
  }

  int nextInt(int upperBound) {
    if (upperBound <= 0) {
      throw ArgumentError.value(upperBound, 'upperBound', 'Must be positive.');
    }
    return nextUint32() % upperBound;
  }

  double nextDouble() => nextUint32() / 0x100000000;

  double nextSignedDouble() => (nextDouble() * 2) - 1;

  static int _normalizeSeed(int seed) {
    final normalized = (seed ^ 0x9e3779b9) & _mask32;
    return normalized == 0 ? 0x6d2b79f5 : normalized;
  }

  static const _mask32 = 0xffffffff;
}
