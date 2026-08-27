import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/ui/game_overlays.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Tessera-Dart boot shell: core systems register, then the Flame game runs.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerCoreSystems();
  runApp(const DawnforgeApp());
}

class DawnforgeApp extends StatelessWidget {
  const DawnforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawnforge',
      home: Scaffold(
        body: GameWidget<DawnforgeGame>.controlled(
          gameFactory: DawnforgeGame.new,
          // The interface is Flutter over the game surface, never inside it
          // (study §3.1). The game decides WHEN each overlay is on screen;
          // this map only says what each name draws.
          overlayBuilderMap: gameOverlays(),
        ),
      ),
    );
  }
}
