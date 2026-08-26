import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
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
    return const MaterialApp(
      title: 'Dawnforge',
      home: Scaffold(
        body: GameWidget<DawnforgeGame>.controlled(
          gameFactory: DawnforgeGame.new,
        ),
      ),
    );
  }
}
