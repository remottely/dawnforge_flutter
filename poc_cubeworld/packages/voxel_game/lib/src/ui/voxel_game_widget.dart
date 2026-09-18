import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:voxel_scene/voxel_scene.dart';

import '../core/voxel_game.dart';
import '../input/voxel_action.dart';
import '../spec/voxel_game_spec.dart';
import 'default_hud.dart';

/// Builds an overlay over the running game; rebuilt every frame, so keep it
/// light. It never receives pointer events (they are the game's).
typedef HudBuilder = Widget Function(BuildContext context, VoxelGame game);

/// Loads the renderer and runs [spec] full screen: the one call a game's
/// `main` needs.
///
/// ```dart
/// void main() => runVoxelGame(myGame);
/// ```
Future<void> runVoxelGame(VoxelGameSpec spec, {String title = 'Voxel game', HudBuilder? hud}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await VoxelGameWidget.loadResources();
  runApp(MaterialApp(
    title: title,
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(body: VoxelGameWidget(spec: spec, hud: hud)),
  ));
}

/// A running [VoxelGameSpec]: the 3D view, the controls (keyboard, mouse with
/// pointer lock, gamepad) and a HUD. Click to play, Escape to free the mouse.
///
/// Call [loadResources] once before the first one is built (`runVoxelGame`
/// does).
class VoxelGameWidget extends StatefulWidget {
  /// A game of [spec] with [hud] over it ([DefaultHud] when null);
  /// [onReady] receives the game once it runs.
  const VoxelGameWidget({super.key, required this.spec, this.hud, this.onReady});

  /// The game.
  final VoxelGameSpec spec;

  /// The overlay; the default HUD when null.
  final HudBuilder? hud;

  /// Called once the game has started.
  final void Function(VoxelGame game)? onReady;

  /// Loads flutter_scene's static resources and the terrain shader.
  static Future<void> loadResources() async {
    await Scene.initializeStaticResources();
    await TerrainMaterial.loadLibrary();
  }

  @override
  State<VoxelGameWidget> createState() => _VoxelGameWidgetState();
}

class _VoxelGameWidgetState extends State<VoxelGameWidget> {
  VoxelGame? _game;
  final FocusNode _focus = FocusNode();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    VoxelGame.start(widget.spec).then((game) {
      if (_disposed) {
        game.dispose();
        return;
      }
      game.input.attachDevices();
      setState(() => _game = game);
      widget.onReady?.call(game);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _game?.dispose();
    _focus.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(VoxelGame game, double dt) {
    final input = game.input;
    if (input.justPressed(VoxelAction.pause) && input.wantCapture) input.release();
    if (input.captureLost) {
      input.captureLost = false;
      input.releaseKeys();
    }
    game.gameplay = input.wantCapture;
    game.frame(dt);
    _frame.value++;
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    if (game == null) {
      return const ColoredBox(color: Color(0xFF0E1420), child: Center(child: Text('Generating the world...')));
    }
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: game.input.onKey,
      child: Listener(
        onPointerDown: (e) {
          _focus.requestFocus();
          if (!game.input.wantCapture) {
            game.input.capture();
            return;
          }
          game.input.onPointerDown(e);
        },
        onPointerUp: game.input.onPointerUp,
        onPointerMove: game.input.onPointerMove,
        onPointerSignal: game.input.onPointerSignal,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SceneView(game.scene!, cameraBuilder: (elapsed) => game.camera(), onTick: (elapsed, dt) => _tick(game, dt)),
            IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: _frame,
                builder: (context, _, _) => (widget.hud ?? DefaultHud.builder)(context, game),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
