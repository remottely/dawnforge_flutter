import 'package:dawnforge/src/core/utils/noise/fbm_noise_2d.dart';
import 'package:dawnforge/src/core/utils/noise/perlin_noise_2d.dart';
import 'package:flutter_test/flutter_test.dart';

/// The noise is the generator's only randomness source, so its contract is
/// load-bearing: pure function of (seed, x, y), bounded, continuous.
void main() {
  group('PerlinNoise2D', () {
    test('same seed produces the identical field — pure function of (seed, x, y)',
        () {
      final a = PerlinNoise2D(42);
      final b = PerlinNoise2D(42);
      for (var i = 0; i < 500; i++) {
        final x = (i * 7.31) - 1800;
        final y = (i * 3.77) - 900;
        expect(a.at(x, y), b.at(x, y));
      }
    });

    test('a different seed moves the field', () {
      final a = PerlinNoise2D(1);
      final b = PerlinNoise2D(2);
      var differs = false;
      for (var i = 0; i < 100 && !differs; i++) {
        differs = a.at(i * 5.13, i * 2.71) != b.at(i * 5.13, i * 2.71);
      }
      expect(differs, isTrue);
    });

    test('stays inside [-1, 1] — unit gradients bound the raw value by √2/2',
        () {
      final noise = PerlinNoise2D(7);
      for (var i = 0; i < 5000; i++) {
        final value = noise.at(i * 0.917 - 2000, i * 1.371 - 3000);
        expect(value, greaterThanOrEqualTo(-1));
        expect(value, lessThanOrEqualTo(1));
      }
    });

    test('is continuous — a small step never jumps', () {
      final noise = PerlinNoise2D(11);
      for (var i = 0; i < 200; i++) {
        final x = i * 0.83 - 80;
        final y = i * 0.31 - 30;
        final delta = (noise.at(x + 0.001, y) - noise.at(x, y)).abs();
        expect(delta, lessThan(0.01));
      }
    });

    test('negative coordinates wrap the lattice correctly', () {
      final noise = PerlinNoise2D(3);
      // A crash or NaN here is the classic floor/mask bug — the values just
      // have to be finite and bounded.
      for (final x in [-0.5, -1.0, -255.9, -256.0, -1000.25]) {
        final value = noise.at(x, x * 0.7);
        expect(value.isFinite, isTrue);
        expect(value.abs(), lessThanOrEqualTo(1));
      }
    });
  });

  group('FbmNoise2D', () {
    test('amplitude normalization keeps the fractal inside [-1, 1]', () {
      final fbm = FbmNoise2D(seed: 5, frequency: 0.03, octaves: 4);
      for (var i = 0; i < 3000; i++) {
        final value = fbm.at(i * 1.13 - 1500, i * 0.77 - 700);
        expect(value.abs(), lessThanOrEqualTo(1));
      }
    });

    test('same seed same field; octave count changes the field', () {
      final a = FbmNoise2D(seed: 9, frequency: 0.03, octaves: 4);
      final b = FbmNoise2D(seed: 9, frequency: 0.03, octaves: 4);
      final coarse = FbmNoise2D(seed: 9, frequency: 0.03, octaves: 1);
      expect(a.at(12.3, -45.6), b.at(12.3, -45.6));
      var differs = false;
      for (var i = 0; i < 50 && !differs; i++) {
        differs = a.at(i * 3.1, i * 1.7) != coarse.at(i * 3.1, i * 1.7);
      }
      expect(differs, isTrue);
    });
  });
}
