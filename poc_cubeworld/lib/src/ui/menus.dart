import 'dart:io';

import 'package:flutter/material.dart';

import '../game/game.dart';
import '../game/game_state.dart';
import '../player/player.dart';

/// Pause: resume, save, save & quit. The world keeps running behind it.
class PauseMenu extends StatefulWidget {
  const PauseMenu({super.key, required this.game});
  final Game game;

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  Game get game => widget.game;

  Widget _slider(String text, double lo, double hi, double value, void Function(double) cb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$text: ${value.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13, color: Colors.white)),
        Slider(min: lo, max: hi, value: value.clamp(lo, hi), onChanged: (v) => setState(() => cb(v))),
      ],
    );
  }

  Widget _button(String text, VoidCallback cb) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(height: 44, width: double.infinity, child: FilledButton(onPressed: cb, child: Text(text))),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.6),
      alignment: Alignment.center,
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paused', style: TextStyle(fontSize: 36, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'WASD move · Space jump / climb walls · Shift sprint · Ctrl sneak\nLMB mine / attack · RMB place / use · E inventory + craft\n1-9 hotbar · Q drop · H eat · V camera · G glide · R ability · F1 debug',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            _slider('Mouse sensitivity', 0.3, 3.0, Player.sensitivityScale, (v) => Player.sensitivityScale = v),
            _slider('Render distance (chunks)', 4.0, 14.0, game.world.loadRadius.toDouble(), (v) {
              game.world.loadRadius = v.toInt();
              game.world.unloadRadius = v.toInt() + 2;
              game.world.refresh();
            }),
            _slider('Field of view', 60.0, 100.0, Player.baseFov, (v) => Player.baseFov = v),
            _button('Resume', () => game.closeScreen()),
            _button('Save', () {
              game.saveGame();
              game.notify('Game saved');
              game.closeScreen();
            }),
            _button('Save & Quit', () async {
              await game.saveGame();
              exit(0);
            }),
            _button('Quit without saving', () => exit(0)),
          ],
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
    return Container(
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
    );
  }
}
