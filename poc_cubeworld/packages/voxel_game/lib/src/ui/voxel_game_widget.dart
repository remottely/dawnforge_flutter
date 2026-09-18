import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voxel_scene/voxel_scene.dart';

import '../core/voxel_game.dart';
import '../input/voxel_action.dart';
import '../spec/voxel_game_spec.dart';
import 'default_hud.dart';
import 'inventory_screen.dart';
import '../world/world_save.dart';

/// Builds an overlay over the running game; rebuilt every frame, so keep it
/// light. It never receives pointer events (they are the game's).
typedef HudBuilder = Widget Function(BuildContext context, VoxelGame game);

/// Loads the renderer and runs [spec] full screen: the one call a game's
/// `main` needs.
///
/// ```dart
/// void main() => runVoxelGame(myGame);
/// ```
///
/// With [saveSlot] the world is kept in that slot of the app's support
/// folder (`worlds/<slot>`): loaded when it exists, saved every minute and
/// when the widget goes away.
Future<void> runVoxelGame(VoxelGameSpec spec, {String title = 'Voxel game', HudBuilder? hud, String? saveSlot}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await VoxelGameWidget.loadResources();
  runApp(MaterialApp(
    title: title,
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(body: VoxelGameWidget(spec: spec, hud: hud, saveSlot: saveSlot)),
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
  const VoxelGameWidget({super.key, required this.spec, this.hud, this.onReady, this.saveSlot, this.saves, this.autosave = const Duration(minutes: 1)});

  /// The game.
  final VoxelGameSpec spec;

  /// The overlay; the default HUD when null.
  final HudBuilder? hud;

  /// Called once the game has started.
  final void Function(VoxelGame game)? onReady;

  /// The save slot the world lives in, or null for a world never saved.
  final String? saveSlot;

  /// Where the slots are; the app support folder's `worlds` when null.
  final WorldSaves? saves;

  /// How often the world is saved while it runs.
  final Duration autosave;

  /// The app's default saves: `<application support>/worlds`.
  static Future<WorldSaves> defaultSaves() async => WorldSaves(Directory('${(await getApplicationSupportDirectory()).path}/worlds'));

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

  WorldSaves? _saves;
  Timer? _autosave;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final slot = widget.saveSlot;
    SavedWorld? saved;
    if (slot != null) {
      final saves = _saves = widget.saves ?? await VoxelGameWidget.defaultSaves();
      if (saves.exists(slot)) saved = saves.read(slot);
    }
    final game = await VoxelGame.start(widget.spec, save: saved);
    if (_disposed) {
      game.dispose();
      return;
    }
    game.input.attachDevices();
    game.openScreen.addListener(_screenChanged);
    setState(() => _game = game);
    if (slot != null) _autosave = Timer.periodic(widget.autosave, (_) => _save());
    widget.onReady?.call(game);
  }

  void _save() {
    final game = _game, saves = _saves, slot = widget.saveSlot;
    if (game == null || saves == null || slot == null || !game.ready) return;
    saves.save(game, slot);
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _save();
    _disposed = true;
    _game?.openScreen.removeListener(_screenChanged);
    _game?.dispose();
    _focus.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _screenChanged() {
    final game = _game;
    if (game == null) return;
    if (game.openScreen.value != null) game.input.release();
    setState(() {});
  }

  void _closeScreen(VoxelGame game) {
    game.openScreen.value = null;
    game.input.capture();
  }

  void _tick(VoxelGame game, double dt) {
    final input = game.input;
    if (game.openScreen.value != null && (input.justPressed(VoxelAction.inventory) || input.justPressed(VoxelAction.pause))) {
      _closeScreen(game);
    } else if (input.justPressed(VoxelAction.pause) && input.wantCapture) {
      input.release();
    }
    if (input.captureLost) {
      input.captureLost = false;
      input.releaseKeys();
    }
    game.gameplay = (input.wantCapture || game.playWithoutCapture) && game.openScreen.value == null;
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
          if (game.openScreen.value != null) return;
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
            if (game.openScreen.value != null)
              InventoryScreen(game: game, station: game.openScreen.value!, onClose: () => _closeScreen(game)),
          ],
        ),
      ),
    );
  }
}
