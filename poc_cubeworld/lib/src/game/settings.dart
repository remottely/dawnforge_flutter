import 'dart:io';

import '../player/player.dart';
import 'sfx.dart';

/// Stage 24: player settings, kept in `settings.cfg` next to `worlds/` (Godot's
/// `user://settings.cfg`, the same `ConfigFile` text: `[section]` then
/// `key=value`) and applied at boot. The Escape menu edits them live; [save]
/// writes them back.
class Settings {
  Settings._();
  static final Settings instance = Settings._();

  String path = '';
  int renderRadius = 8; // chunks, 4..10
  double sensitivity = 1.0; // mouse, x Player.mouseSensitivity
  double fov = 72.0;
  double volume = 1.0; // master, linear 0..1
  bool weather = true;
  bool showFps = false;
  bool viewBob = true; // the camera's walking sway; off for a still image
  bool tutorialDone = false; // stage 30: the guided first steps, shown once

  /// Walking into a one-block step lifts the body onto it in one tick (the
  /// port's first behaviour). Off: the player jumps it, Minecraft's auto-jump.
  /// The half step (a slab, a stair) is always taken. `--step-teleport` turns
  /// it on for one run.
  bool stepTeleport = false;

  /// Cube World's wall climbing: hold jump against a wall. Off by default;
  /// ladders climb either way. `--climb` turns it on for one run.
  bool climbWalls = false;

  /// Reads [path]; a missing or unreadable file keeps the defaults.
  bool loadFile() {
    final f = File(path);
    if (path == '' || !f.existsSync()) return false;
    fromConfig(f.readAsStringSync());
    return true;
  }

  bool save() {
    try {
      final f = File(path);
      f.parent.createSync(recursive: true);
      f.writeAsStringSync(toConfig(), flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Godot's `ConfigFile.save` layout: one section per group, a blank line
  /// after each header.
  String toConfig() {
    String f(double v) => v == v.roundToDouble() ? v.toStringAsFixed(1) : '$v';
    return '[video]\n\nrender_radius=$renderRadius\nfov=${f(fov)}\nshow_fps=$showFps\nview_bob=$viewBob\n\n'
        '[input]\n\nsensitivity=${f(sensitivity)}\n\n'
        '[audio]\n\nvolume=${f(volume)}\n\n'
        '[world]\n\nweather=$weather\n\n'
        '[gameplay]\n\nstep_teleport=$stepTeleport\nclimb_walls=$climbWalls\n\n'
        '[tutorial]\n\ndone=$tutorialDone\n';
  }

  void fromConfig(String text) {
    final values = <String, String>{};
    var section = '';
    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith(';')) continue;
      if (line.startsWith('[') && line.endsWith(']')) {
        section = line.substring(1, line.length - 1);
        continue;
      }
      final eq = line.indexOf('=');
      if (eq > 0) values['$section/${line.substring(0, eq).trim()}'] = line.substring(eq + 1).trim();
    }
    double num(String key, double fallback) => double.tryParse(values[key] ?? '') ?? fallback;
    bool flag(String key, bool fallback) => values[key] == null ? fallback : values[key] == 'true';
    renderRadius = num('video/render_radius', renderRadius.toDouble()).toInt().clamp(4, 10);
    sensitivity = num('input/sensitivity', sensitivity).clamp(0.3, 3.0);
    fov = num('video/fov', fov).clamp(60.0, 100.0);
    volume = num('audio/volume', volume).clamp(0.0, 1.0);
    weather = flag('world/weather', weather);
    showFps = flag('video/show_fps', showFps);
    viewBob = flag('video/view_bob', viewBob);
    tutorialDone = flag('tutorial/done', tutorialDone);
    stepTeleport = flag('gameplay/step_teleport', stepTeleport);
    climbWalls = flag('gameplay/climb_walls', climbWalls);
  }

  /// The settings that live outside the play session: the player's statics and
  /// the master volume.
  void applyGlobals() {
    Player.sensitivityScale = sensitivity;
    Player.baseFov = fov;
    Sfx.setVolume(volume);
  }
}
