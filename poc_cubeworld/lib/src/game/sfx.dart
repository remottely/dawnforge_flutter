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

  /// Stage 24: the settings' master volume (Godot's bus 0), linear 0..1.
  static double _volume = 1.0;

  static void setVolume(double v) {
    _volume = v;
    if (!_ready) return;
    try {
      SoLoud.instance.setGlobalVolume(v);
    } catch (e) {
      debugPrint('[sfx] $e');
    }
  }

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
    await make('thunder', 1.6, (t, p) => (_rng.nextDouble() * 2.0 - 1.0) * math.pow(1.0 - p, 1.5) * (0.5 + 0.5 * math.sin(t * 9.0 * math.pi * 2)) * 0.7);
    await make('click', 0.04, (t, p) => math.sin(t * 1200.0 * math.pi * 2) * (1.0 - p) * 0.3);
    // Stage 27: a door swinging on its hinge, a low creak that drops in pitch.
    await make('door', 0.22, (t, p) => (math.sin(t * (140.0 - p * 60.0) * math.pi * 2) * 0.6 + (_rng.nextDouble() - 0.5) * 0.3) * math.sin(p * math.pi) * 0.5);
    // Stage 32: one break / place / step voice per material family
    // (`Blocks.materialFamily`), a hurt voice per species group, and the
    // low-health heartbeat.
    const tau = math.pi * 2;
    double rnd() => _rng.nextDouble() * 2.0 - 1.0;
    double half() => _rng.nextDouble() - 0.5;
    double pw(double b, double e) => math.pow(b, e).toDouble();
    double sn(double v) => math.sin(v);
    await make('break_stone', 0.20, (t, p) => (rnd() * 0.7 + sn(t * 160.0 * tau) * 0.3) * pw(1.0 - p, 2.0) * 0.8);
    await make('break_wood', 0.22, (t, p) => (sn(t * 110.0 * tau) * 0.5 + rnd() * 0.4) * pw(1.0 - p, 1.5) * ((p * 9.0).toInt() % 2 == 0 ? 1.0 : 0.4) * 0.7);
    await make('break_earth', 0.24, (t, p) => rnd() * pw(1.0 - p, 3.0) * 0.55 * (0.6 + 0.4 * sn(t * 40.0 * tau)));
    await make('break_metal', 0.30, (t, p) => (sn(t * 880.0 * tau) * 0.5 + sn(t * 1320.0 * tau) * 0.3 + half() * 0.2) * pw(1.0 - p, 2.5) * 0.6);
    await make('break_glass', 0.28, (t, p) => (sn(t * (2400.0 + sn(t * 90.0) * 800.0) * tau) * 0.5 + rnd() * 0.5) * pw(1.0 - p, 1.2) * 0.5);
    await make('break_plant', 0.16, (t, p) => rnd() * sn(p * math.pi) * ((p * 14.0).toInt() % 3 != 0 ? 1.0 : 0.3) * 0.35);
    await make('break_liquid', 0.26, (t, p) => rnd() * sn(p * math.pi) * (0.5 + 0.5 * sn(t * 25.0 * tau)) * 0.4);
    await make('place_stone', 0.10, (t, p) => (sn(t * 150.0 * tau) * 0.7 + half() * 0.3) * pw(1.0 - p, 3.0) * 0.6);
    await make('place_wood', 0.12, (t, p) => (sn(t * 220.0 * tau) * 0.6 + sn(t * 95.0 * tau) * 0.4) * pw(1.0 - p, 3.0) * 0.6);
    await make('place_earth', 0.12, (t, p) => rnd() * pw(1.0 - p, 4.0) * 0.45);
    await make('place_metal', 0.16, (t, p) => (sn(t * 660.0 * tau) * 0.6 + sn(t * 990.0 * tau) * 0.3) * pw(1.0 - p, 3.0) * 0.5);
    await make('place_glass', 0.12, (t, p) => sn(t * 1800.0 * tau) * pw(1.0 - p, 3.0) * 0.4);
    await make('place_plant', 0.10, (t, p) => rnd() * sn(p * math.pi) * 0.25);
    await make('place_liquid', 0.20, (t, p) => rnd() * sn(p * math.pi) * (0.6 + 0.4 * sn(t * 18.0 * tau)) * 0.35);
    await make('step_stone', 0.06, (t, p) => (rnd() * 0.6 + sn(t * 140.0 * tau) * 0.4) * pw(1.0 - p, 2.0) * 0.5);
    await make('step_wood', 0.07, (t, p) => (sn(t * 120.0 * tau) * 0.6 + half() * 0.4) * pw(1.0 - p, 2.0) * 0.5);
    await make('step_earth', 0.07, (t, p) => rnd() * pw(1.0 - p, 3.0) * 0.4);
    await make('step_metal', 0.08, (t, p) => (sn(t * 700.0 * tau) * 0.5 + half() * 0.3) * pw(1.0 - p, 2.5) * 0.4);
    await make('step_glass', 0.06, (t, p) => sn(t * 1500.0 * tau) * pw(1.0 - p, 3.0) * 0.3);
    await make('step_plant', 0.08, (t, p) => rnd() * sn(p * math.pi) * 0.25);
    await make('step_liquid', 0.12, (t, p) => rnd() * sn(p * math.pi) * (0.5 + 0.5 * sn(t * 30.0 * tau)) * 0.3);
    await make('hurt_small', 0.14, (t, p) => sn(t * (700.0 + p * 300.0) * tau) * (1.0 - p) * 0.4);
    await make('hurt_large', 0.35, (t, p) => (sn(t * (140.0 - p * 60.0) * tau) * 0.7 + half() * 0.3) * (1.0 - p) * 0.6);
    await make('hurt_undead', 0.30, (t, p) => (sn(t * (180.0 - p * 90.0) * tau) * sn(t * 13.0 * tau) + half() * 0.4) * (1.0 - p) * 0.55);
    await make('hurt_flying', 0.12, (t, p) => sn(t * (1400.0 - p * 500.0) * tau) * ((p * 8.0).toInt() % 2 == 0 ? 1.0 : 0.3) * (1.0 - p) * 0.35);
    await make('heartbeat', 0.32, (t, p) {
      final beat = pw(math.max(1.0 - p * 4.0, 0.0), 2.0) + 0.7 * pw(math.max(1.0 - (p - 0.45).abs() * 5.0, 0.0), 2.0);
      return sn(t * 55.0 * tau) * beat * 0.7;
    });
    _ready = true;
    setVolume(_volume);
  }

  static bool get ready => _ready;

  /// Stage 26: a mono 16-bit WAV of [samples] (-1..1) at [sampleRate], for the
  /// music loops.
  static Uint8List wav16(Float32List samples, int sampleRate) {
    final n = samples.length;
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
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    str(36, 'data');
    bytes.setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      bytes.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32000).toInt(), Endian.little);
    }
    return bytes.buffer.asUint8List();
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
