import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Procedural sound effects: short WAV bursts synthesised at startup (no asset
/// files), played through SoLoud.
class Sfx {
  Sfx._();

  static const int rate = 22050;
  static final Map<String, AudioSource> _sources = {};
  static final math.Random _rng = math.Random();
  static bool _ready = false;
  static bool muted = false;

  static Future<void> init() async {
    if (_ready) return;
    try {
      await SoLoud.instance.init();
    } catch (e) {
      debugPrint('[sfx] audio unavailable: $e');
      return;
    }
    Future<void> make(String name, double seconds, double Function(double t, double p) fn) async {
      _sources[name] = await SoLoud.instance.loadMem('$name.wav', _wav(seconds, fn));
    }

    await make('dig', 0.08, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * (1.0 - p) * 0.5);
    await make('break', 0.18, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * math.pow(1.0 - p, 2.0) * 0.8 + math.sin(t * 220.0 * math.pi * 2) * (1.0 - p) * 0.2);
    await make('place', 0.10, (t, p) => math.sin(t * 180.0 * math.pi * 2) * math.pow(1.0 - p, 3.0) * 0.6);
    await make('hit', 0.12, (t, p) => (math.sin(t * 90.0 * math.pi * 2) + (_rng.nextDouble() - 0.5)) * math.pow(1.0 - p, 2.0) * 0.7);
    await make('hurt', 0.25, (t, p) => math.sin(t * (300.0 - p * 200.0) * math.pi * 2) * (1.0 - p) * 0.6);
    await make('pickup', 0.15, (t, p) => math.sin(t * (600.0 + p * 700.0) * math.pi * 2) * (1.0 - p) * 0.4);
    await make('levelup', 0.6, (t, p) {
      final step = (p * 4.0).toInt().clamp(0, 3);
      return math.sin(t * const [440.0, 554.0, 659.0, 880.0][step] * math.pi * 2) * (1.0 - p) * 0.4;
    });
    await make('swing', 0.12, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * math.sin(p * math.pi) * 0.25);
    await make('shoot', 0.15, (t, p) => math.sin(t * (900.0 - p * 600.0) * math.pi * 2) * (1.0 - p) * 0.35);
    await make('bolt', 0.3, (t, p) => (math.sin(t * 200.0 * math.pi * 2) * math.sin(t * 37.0 * math.pi * 2) + (_rng.nextDouble() - 0.5) * 0.3) * (1.0 - p) * 0.5);
    await make('splash', 0.3, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * math.sin(p * math.pi) * 0.35);
    await make('eat', 0.2, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * ((p * 6.0).toInt() % 2 == 0 ? 1.0 : 0.2) * 0.3 * (1.0 - p));
    await make('quest', 0.5, (t, p) => math.sin(t * (p < 0.5 ? 523.0 : 784.0) * math.pi * 2) * (1.0 - p) * 0.4);
    await make('click', 0.04, (t, p) => math.sin(t * 1200.0 * math.pi * 2) * (1.0 - p) * 0.3);
    _ready = true;
  }

  static Uint8List _wav(double seconds, double Function(double, double) fn) {
    final n = (seconds * rate).toInt();
    final bytes = ByteData(44 + n * 2);
    void str(int o, String s) {
      for (var i = 0; i < s.length; i++) {
        bytes.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    bytes.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, rate, Endian.little);
    bytes.setUint32(28, rate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    str(36, 'data');
    bytes.setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      final t = i / rate;
      final v = fn(t, i / n).clamp(-1.0, 1.0);
      bytes.setInt16(44 + i * 2, (v * 32000).toInt(), Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  static void play(String name, [double volumeDb = 0.0, double pitch = 1.0]) {
    if (!_ready || muted) return;
    final source = _sources[name];
    if (source == null) return;
    final volume = math.pow(10.0, volumeDb / 20.0).toDouble().clamp(0.0, 1.0);
    final speed = pitch * (0.92 + _rng.nextDouble() * 0.16);
    try {
      final handle = SoLoud.instance.play(source, volume: volume, paused: true);
      SoLoud.instance.setRelativePlaySpeed(handle, speed);
      SoLoud.instance.setPause(handle, false);
    } catch (e) {
      debugPrint('[sfx] $e');
    }
  }
}
