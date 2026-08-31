/// Seeded 2D gradient noise — the study track's stand-in for Godot's
/// `FastNoiseLite` (SimplexSmooth). A pure function of (seed, x, y):
/// identical on every platform (own PRNG, 32-bit-masked arithmetic that stays
/// inside the 2^53 doubles of dart2js — `dart:math`'s `Random` algorithm is
/// not specified across VM/web, so it never touches the world).
///
/// Deliberate delta from the spec, documented here once: the exact noise
/// ALGORITHM differs (improved Perlin vs OpenSimplex2S), so the same seed
/// produces a different world than the Godot engine — which is a non-goal
/// (decision D1: the tracks share shapes, never worlds). What must match is
/// the field's CHARACTER (continuous, isotropic-ish, [-1, 1]) because the
/// ProceduralWorldManager derives its terrain cuts from this field's own
/// quantiles — densities stay truthful under any continuous noise.
final class PerlinNoise2D {
  PerlinNoise2D(int seed) : _perm = _shuffledPermutation(seed);

  /// Doubled permutation table (512) so corner hashing never wraps mid-sum.
  final List<int> _perm;

  static const double _sqrt2 = 1.4142135623730951;
  static const double _diagonal = 0.7071067811865476;

  /// Noise value at (x, y), in [-1, 1]. Unit gradients bound the raw value by
  /// √2/2, so the √2 scale is exact, never a clamp.
  double at(double x, double y) {
    final xi = x.floorToDouble().toInt();
    final yi = y.floorToDouble().toInt();
    final xf = x - xi;
    final yf = y - yi;
    final u = _fade(xf);
    final v = _fade(yf);

    final xw = xi & 255;
    final yw = yi & 255;
    final hash00 = _perm[_perm[xw] + yw];
    final hash10 = _perm[_perm[xw + 1] + yw];
    final hash01 = _perm[_perm[xw] + yw + 1];
    final hash11 = _perm[_perm[xw + 1] + yw + 1];

    final top = _lerp(_grad(hash00, xf, yf), _grad(hash10, xf - 1, yf), u);
    final bottom =
        _lerp(_grad(hash01, xf, yf - 1), _grad(hash11, xf - 1, yf - 1), u);
    return _lerp(top, bottom, v) * _sqrt2;
  }

  /// Quintic fade (Perlin 2002): zero first AND second derivative at the
  /// lattice, so cell borders never show as creases.
  static double _fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Dot of the offset with one of 8 unit gradients — 4 axis, 4 diagonal.
  static double _grad(int hash, double dx, double dy) {
    switch (hash & 7) {
      case 0:
        return dx;
      case 1:
        return -dx;
      case 2:
        return dy;
      case 3:
        return -dy;
      case 4:
        return (dx + dy) * _diagonal;
      case 5:
        return (dy - dx) * _diagonal;
      case 6:
        return (dx - dy) * _diagonal;
      default:
        return -(dx + dy) * _diagonal;
    }
  }

  /// 0..255 Fisher-Yates-shuffled by the seed, then doubled.
  static List<int> _shuffledPermutation(int seed) {
    final table = List<int>.generate(256, (i) => i);
    var state = seed & 0xFFFFFFFF;
    for (var i = 255; i > 0; i--) {
      state = _mix32(state);
      final j = state % (i + 1);
      final swap = table[i];
      table[i] = table[j];
      table[j] = swap;
    }
    return List<int>.generate(512, (i) => table[i & 255], growable: false);
  }

  /// splitmix32 step — every multiply goes through [_mul32] so intermediate
  /// products stay below 2^53 (dart2js has no 64-bit ints).
  static int _mix32(int state) {
    var z = (state + 0x9E3779B9) & 0xFFFFFFFF;
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
