import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/game.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:flutter/material.dart';

class GameStateManager extends GameComponent {
  bool showGameOver = false;
  @override
  void update(double dt) {
    if (checkInterval('gameOver', 100, dt)) {
      if (gameRef.player != null && gameRef.player?.isDead == true) {
        if (!showGameOver) {
          showGameOver = true;
          _displayGameOverDialog();
        }
      }
    }
    super.update(dt);
  }

  void _displayGameOverDialog() {
    showGameOver = true;
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Game()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
