import 'dart:io';

import 'package:flutter/material.dart';

import '../game/game.dart';
import '../game/game_state.dart';
import '../game/settings.dart';

/// Escape: the settings (stage 24: render distance, mouse, FOV, volume, weather,
/// FPS overlay — kept in settings.cfg), resume, save, save & quit. The world
/// keeps running behind it; only the mouse is released.
class PauseMenu extends StatefulWidget {
  const PauseMenu({super.key, required this.game});
  final Game game;

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  Game get game => widget.game;
  Settings get settings => Settings.instance;

  /// Godot's `HSlider.step`: 0.05 up to 1, 0.1 below 10, 1 otherwise.
  Widget _slider(String text, double lo, double hi, double value, void Function(double) cb) {
    final step = hi <= 1.0 ? 0.05 : (hi < 10.0 ? 0.1 : 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$text: ${value.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13, color: Colors.white)),
        SizedBox(
          height: 30,
          child: Slider(
            min: lo,
            max: hi,
            divisions: ((hi - lo) / step).round(),
            value: value.clamp(lo, hi),
            onChanged: (v) => setState(() => cb(v)),
          ),
        ),
      ],
    );
  }

  Widget _check(String text, bool value, void Function(bool) cb) => SizedBox(
        height: 36,
        child: SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
          value: value,
          onChanged: (v) => setState(() => cb(v)),
        ),
      );

  Widget _button(String text, VoidCallback cb) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: SizedBox(height: 38, width: double.infinity, child: FilledButton(onPressed: cb, child: Text(text))),
      );

  @override
  Widget build(BuildContext context) {
    // The overlay sits in the game's Stack with no Scaffold above it: sliders
    // and switches need a Material ancestor (and text its default style), or
    // they paint the red "No Material widget found" error instead.
    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: const Color.fromRGBO(0, 0, 0, 0.6),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Menu', style: TextStyle(fontSize: 36, color: Colors.white)),
              const SizedBox(height: 6),
              const Text(
                'WASD move · Space jump / climb walls · Shift sprint · Ctrl sneak\nLMB mine / attack · RMB place / use · E inventory + craft\n1-9 hotbar · Q drop · H eat · V camera · G glide · R ability · M map · J journal · F1 debug',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              _slider('Render distance (chunks)', 4.0, 10.0, game.world.loadRadius.toDouble(), (v) {
                if (v.round() != game.world.loadRadius) game.applyRenderDistance(v.round());
              }),
              _slider('Mouse sensitivity', 0.3, 3.0, settings.sensitivity, (v) {
                settings.sensitivity = v;
                settings.applyGlobals();
              }),
              _slider('Field of view', 60.0, 100.0, settings.fov, (v) {
                settings.fov = v;
                settings.applyGlobals();
              }),
              _slider('Master volume', 0.0, 1.0, settings.volume, (v) {
                settings.volume = v;
                settings.applyGlobals();
              }),
              _check('Weather (off = always clear)', settings.weather, (on) {
                settings.weather = on;
                game.weather.setEnabled(on);
              }),
              _check('Show FPS', settings.showFps, (on) => settings.showFps = on),
              _button('Resume', () {
                settings.save();
                game.closeScreen();
              }),
              _button('Save', () {
                settings.save();
                game.saveGame();
                game.notify('Game saved');
                game.closeScreen();
              }),
              _button('Save & Quit', () async {
                settings.save();
                await game.saveGame();
                exit(0);
              }),
              _button('Quit without saving', () => exit(0)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class DeathScreen extends StatefulWidget {
  const DeathScreen({super.key, required this.game});
  final Game game;

  @override
  State<DeathScreen> createState() => _DeathScreenState();
}

class _DeathScreenState extends State<DeathScreen> {
  @override
  void initState() {
    super.initState();
    GameState.instance.deaths += 1;
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: const Color.fromRGBO(102, 0, 0, 0.6),
      alignment: Alignment.center,
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You died', style: TextStyle(fontSize: 42, color: Colors.white)),
            Text('Level ${game.player.level} · ${GameState.instance.mobsKilled} kills', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  game.player.respawn();
                  game.closeScreen();
                },
                child: const Text('Respawn'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
