import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_scene/scene.dart' hide Material;

import '../game/game.dart';
import 'hud.dart';
import 'inventory_screen.dart';
import 'menus.dart';

/// The play session: the 3D view, the HUD painted over it, and whichever
/// screen is open (inventory, pause, death). Keyboard focus lives here.
class GameView extends StatefulWidget {
  const GameView({super.key, required this.args, required this.saveDir});
  final Map<String, String> args;
  final String saveDir;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final Game game;
  final FocusNode _focus = FocusNode(debugLabel: 'game');
  final GlobalKey _boundary = GlobalKey();
  final Minimap _minimap = Minimap();
  Camera? _camera;
  String? _error;

  @override
  void initState() {
    super.initState();
    game = Game(args: widget.args, saveDir: widget.saveDir);
    game.screenshotter = _screenshot;
    game.addListener(_onGameChanged);
    game.init().then((_) {
      if (mounted) setState(() {});
    }).catchError((Object e, StackTrace st) {
      debugPrint('[game] init failed: $e\n$st');
      if (mounted) setState(() => _error = '$e');
    });
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _screenshot(String path) async {
    // Called from the simulation tick, so wait for this frame to be painted
    // before reading the boundary back.
    await WidgetsBinding.instance.endOfFrame;
    final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final f = File(path);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }

  @override
  void dispose() {
    game.removeListener(_onGameChanged);
    game.shutdown();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Failed to start: $_error', style: const TextStyle(color: Colors.red))));
    }
    if (!game.ready) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(20, 26, 41, 1),
        body: Center(child: Text('Building the world...', style: TextStyle(color: Colors.white70, fontSize: 18))),
      );
    }
    final input = game.input;
    Widget? overlay;
    switch (game.screen) {
      case ScreenKind.inventory:
        overlay = InventoryScreen(game: game);
      case ScreenKind.pause:
        overlay = PauseMenu(game: game);
      case ScreenKind.death:
        overlay = DeathScreen(game: game);
      case ScreenKind.none:
        overlay = null;
    }
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: input.onKey,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          _focus.requestFocus();
          if (game.screen == ScreenKind.none) {
            if (!input.isCaptured && !game.player.isDead) input.capture();
            input.onPointerDown(e);
          }
        },
        onPointerUp: input.onPointerUp,
        onPointerMove: input.onPointerMove,
        onPointerSignal: (e) {
          if (game.screen == ScreenKind.none) input.onPointerSignal(e);
        },
        child: MouseRegion(
          cursor: game.screen == ScreenKind.none && input.isCaptured ? SystemMouseCursors.none : SystemMouseCursors.basic,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                key: _boundary,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SceneView(
                      game.scene,
                      cameraBuilder: (elapsed) => _camera = game.player.camera(),
                      onTick: (elapsed, dt) {
                        game.onFrame(dt);
                        _minimap.update(dt, game);
                      },
                    ),
                    CustomPaint(painter: HudPainter(game, _camera, _minimap, repaint: game.frame)),
                    ?overlay,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
