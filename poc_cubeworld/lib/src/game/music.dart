import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'sfx.dart';

/// One mood's recipe: semitones over the root, tempo, root Hz, wave, the chance
/// a step sounds, and a low held drone under the notes.
class MoodDef {
  const MoodDef(this.scale, this.bpm, this.root, this.triangle, this.density, this.drone);
  final List<int> scale;
  final int bpm;
  final double root;
  final bool triangle;
  final double density;
  final bool drone;
}

/// Stage 26: ambient music with no audio files. Godot fills two
/// `AudioStreamGenerator` voices a buffer at a time; SoLoud here plays a
/// rendered loop per mood (the same pentatonic random walk, [loopSteps] eighth
/// notes long, restarting on the root every 16 steps) as a looping WAV, and a
/// mood change crossfades the two handles over [crossfade] seconds with
/// `fadeVolume`. The mood is picked by [setContext] (called once a second by
/// `Game`): one per biome group, a minor / slower night variant, a drone alone
/// underground.
class Music {
  Music._();
  static final Music instance = Music._();

  static const int rate = 22050;
  static const double crossfade = 3.0;
  static const double gain = 0.22;
  static const int loopSteps = 32;

  static const Map<String, MoodDef> moods = {
    'Meadow': MoodDef([0, 2, 4, 7, 9], 84, 220.0, false, 0.7, false),
    'Dunes': MoodDef([0, 1, 5, 7, 8], 100, 246.9, true, 0.75, true),
    'Jungle': MoodDef([0, 1, 5, 7, 8], 118, 261.6, true, 0.85, false),
    'Frost': MoodDef([0, 2, 4, 7, 9], 58, 329.6, false, 0.35, false),
    'Marsh': MoodDef([0, 3, 5, 7, 10], 62, 174.6, false, 0.3, true),
    'Deep': MoodDef([0, 7], 50, 110.0, false, 0.0, true),
    'Underworld': MoodDef([0, 1, 6], 40, 55.0, true, 0.15, true), // stage 29: a low tritone drone
  };

  /// The minor pentatonic on the same root.
  static const List<int> nightScale = [0, 3, 5, 7, 10];

  /// Biome id (`TerrainGenerator.biome*`) -> mood.
  static const Map<int, String> biomeMood = {
    0: 'Meadow', 1: 'Meadow', 2: 'Meadow', 3: 'Meadow', 4: 'Dunes', 5: 'Frost', 6: 'Frost', 7: 'Marsh', 8: 'Jungle',
  };

  /// For the probe: samples rendered so far (Godot counts frames pushed), and
  /// how many loops actually started on the audio device.
  int framesFilled = 0;
  int handlesPlayed = 0;
  void Function(String mood)? onMoodChanged;

  String _mood = '';
  final Map<String, AudioSource> _sources = {};
  SoundHandle? _active;
  int _generation = 0;

  String get currentMood => _mood;

  /// The mood name for where the player stands (pure; unit-tested).
  static String moodFor(int biome, bool night, bool underground, [bool underworld = false]) {
    var name = underworld ? 'Underworld' : (underground ? 'Deep' : (biomeMood[biome] ?? 'Meadow'));
    if (night && !underground && !underworld) name += ' Night';
    return name;
  }

  static MoodDef moodDef(String name) {
    final base = name.endsWith(' Night') ? name.substring(0, name.length - 6) : name;
    final d = moods[base];
    if (d == null) throw ArgumentError('unknown mood $name');
    if (!name.endsWith(' Night')) return d;
    return MoodDef(nightScale, (d.bpm * 0.8).toInt(), d.root, d.triangle, d.density, d.drone);
  }

  /// A change of mood starts a crossfade.
  void setContext(int biome, bool night, bool underground, [bool underworld = false]) {
    final name = moodFor(biome, night, underground, underworld);
    if (name == _mood) return;
    _mood = name;
    onMoodChanged?.call(name);
    final gen = ++_generation;
    unawaited(_crossfadeTo(name, gen));
  }

  Future<void> _crossfadeTo(String name, int gen) async {
    if (!Sfx.ready) {
      // No device (or not yet): still render, so the probe sees the loop exist.
      if (!_sources.containsKey(name)) render(name);
      return;
    }
    try {
      var source = _sources[name];
      if (source == null) {
        source = await SoLoud.instance.loadMem('music_${name.replaceAll(' ', '_')}.wav', Sfx.wav16(render(name), rate));
        _sources[name] = source;
      }
      if (gen != _generation) return; // a newer mood won while this one loaded
      final soloud = SoLoud.instance;
      final old = _active;
      if (old != null && soloud.getIsValidVoiceHandle(old)) {
        soloud.fadeVolume(old, 0.0, Duration(milliseconds: (crossfade * 1000).toInt()));
        soloud.scheduleStop(old, Duration(milliseconds: (crossfade * 1000).toInt() + 50));
      }
      final h = soloud.play(source, volume: 0.0, looping: true);
      soloud.fadeVolume(h, gain, Duration(milliseconds: (crossfade * 1000).toInt()));
      _active = h;
      handlesPlayed++;
    } catch (e) {
      debugPrint('[music] $e');
    }
  }

  static int _fnv(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Renders [loopSteps] eighth notes of the mood's melody, mono, -1..1. The
  /// random walk is seeded by the mood name, so a mood always sounds the same.
  Float32List render(String name) {
    final d = moodDef(name);
    final rng = math.Random(_fnv(name));
    final stepFrames = (rate * 30.0 / d.bpm).toInt(); // an eighth note
    final n = stepFrames * loopSteps;
    final out = Float32List(n);
    var phase = 0.0, dronePhase = 0.0, freq = 0.0;
    var age = 0, degree = 0, step = 0, inStep = 0;
    final scale = d.scale;
    for (var i = 0; i < n; i++) {
      if (inStep == 0) {
        // A new step: walk the scale a degree or two, sometimes an octave up,
        // sometimes rest. Every 16 steps the phrase restarts on the root.
        if (step % 16 == 0) degree = 0;
        if (rng.nextDouble() < d.density) {
          degree = (degree + rng.nextInt(5) - 2).clamp(0, scale.length * 2 - 1);
          final semis = scale[degree % scale.length] + 12 * (degree ~/ scale.length);
          freq = d.root * math.pow(2.0, semis / 12.0);
          age = 0;
        }
        step++;
      }
      var s = 0.0;
      if (freq > 0.0) {
        final t = age / rate;
        final env = math.min(t / 0.02, 1.0) * math.exp(-t * 2.2);
        var raw = math.sin(phase);
        if (d.triangle) raw = 2.0 / math.pi * math.asin(raw);
        s += raw * env * 0.8;
        phase = (phase + math.pi * 2 * freq / rate) % (math.pi * 2);
        age++;
      }
      if (d.drone) {
        s += (math.sin(dronePhase) + 0.5 * math.sin(dronePhase * 1.005)) * 0.25;
        dronePhase = (dronePhase + math.pi * 2 * d.root * 0.5 / rate) % (math.pi * 2);
      }
      inStep = (inStep + 1) % stepFrames;
      out[i] = s.clamp(-1.0, 1.0);
    }
    framesFilled += n;
    return out;
  }

  /// Whether the active loop is a live voice on the audio device (probe).
  bool get isPlaying {
    final h = _active;
    if (h == null || !Sfx.ready) return false;
    try {
      return SoLoud.instance.getIsValidVoiceHandle(h);
    } catch (_) {
      return false;
    }
  }
}
