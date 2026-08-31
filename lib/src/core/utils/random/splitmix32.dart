/// A tiny deterministic PRNG stream over splitmix32 — the same 32-bit-masked
/// arithmetic idiom as `PerlinNoise2D` (dart2js has no 64-bit ints;
/// `dart:math`'s `Random` algorithm is not specified across VM/web, so it
/// never touches the world). A pure function of its seed: the population a
/// chunk rolls from it is identical on every platform and every visit.
final class Splitmix32 {
  Splitmix32(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// Folds parts (a world seed, chunk coordinates) into one 32-bit seed, each
  /// part passed through the mixer so nearby coordinates land far apart.
  static int combine(int a, int b, int c) {
    var h = _mix(a & 0xFFFFFFFF);
    h = _mix((h ^ (b & 0xFFFFFFFF)) & 0xFFFFFFFF);
    return _mix((h ^ (c & 0xFFFFFFFF)) & 0xFFFFFFFF);
  }

  /// The next 32-bit value of the stream.
  int nextUint32() {
    _state = (_state + 0x9E3779B9) & 0xFFFFFFFF;
    return _mix(_state);
  }

  /// Uniform in [0, 1).
  double nextDouble() => nextUint32() / 4294967296;

  /// Uniform integer in [min, max], both inclusive.
  int nextIntInRange(int min, int max) {
    assert(min <= max, '[Splitmix32] range $min..$max inverted');
    return min + nextUint32() % (max - min + 1);
  }

  static int _mix(int state) {
    var z = state;
    z = _mul32(z ^ (z >>> 16), 0x21F0AAAD);
    z = _mul32(z ^ (z >>> 15), 0x735A2D97);
    return z ^ (z >>> 15);
  }

  /// (a * b) mod 2^32 without ever forming a product above 2^49.
  static int _mul32(int a, int b) {
    final low = (a & 0xFFFF) * b;
    final high = ((a >>> 16) * b) & 0xFFFF;
    return (low + (high << 16)) & 0xFFFFFFFF;
  }
}
