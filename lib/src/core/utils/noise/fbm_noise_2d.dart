import 'package:dawnforge/src/core/utils/noise/perlin_noise_2d.dart';

/// Fractal Brownian motion over [PerlinNoise2D] — the fractal half of the
/// Godot `FastNoiseLite` FBM setup (same knobs: octaves, lacunarity, gain;
/// same defaults). Output is amplitude-normalized back into [-1, 1].
final class FbmNoise2D {
  FbmNoise2D({
    required int seed,
    required this.frequency,
    required this.octaves,
    this.lacunarity = 2.0,
    this.gain = 0.5,
  })  : assert(octaves > 0, '[FbmNoise2D] octaves must be > 0'),
        assert(frequency > 0, '[FbmNoise2D] frequency must be > 0'),
        // One decorrelated lattice per octave (FastNoiseLite salts the seed
        // per octave the same way) — sharing one lattice makes every octave
        // peak on the same spots and the fractal reads as one noise scaled.
        _octaveNoise = List<PerlinNoise2D>.generate(
          octaves,
          (octave) => PerlinNoise2D(seed + octave),
          growable: false,
        );

  final double frequency;
  final int octaves;
  final double lacunarity;
  final double gain;
  final List<PerlinNoise2D> _octaveNoise;

  /// Fractal value at (x, y), in [-1, 1].
  double at(double x, double y) {
    var sum = 0.0;
    var amplitude = 1.0;
    var totalAmplitude = 0.0;
    var octaveFrequency = frequency;
    for (var octave = 0; octave < octaves; octave++) {
      sum += amplitude *
          _octaveNoise[octave].at(x * octaveFrequency, y * octaveFrequency);
      totalAmplitude += amplitude;
      amplitude *= gain;
      octaveFrequency *= lacunarity;
    }
    return sum / totalAmplitude;
  }
}
