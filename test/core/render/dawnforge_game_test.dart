import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/render/ground_chunk_renderer.dart';
import 'package:dawnforge/src/core/render/world_object_renderer.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP3 gate in test form: the game boots from the REAL bundled assets,
/// generates a procedural world from a fixed seed, streams chunks around a
/// spawned player, and input moves it through the fixed step. (The visual
/// half of the gate — 60fps on device — is a hand-run, FP3.6.)
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  testWidgets('boots content, spawns the player, input moves it',
      (tester) async {
    final game = DawnforgeGame(worldSeed: 20260826);
    // Image decode is real async, which the fake-async test zone blocks —
    // boot the game inside runAsync so sprite sheets actually load.
    await tester.runAsync(() async {
      await tester.pumpWidget(GameWidget<DawnforgeGame>(game: game));
      // Wait on the FULL render-ready condition, not just the sim objects:
      // each renderer's sheet decodes after its host spawns, so a wait that
      // stops at simObjects raced the sprite-child assertions below — and
      // lost on a saturated machine (parallel test isolates, sibling
      // sessions building). The ceiling is generous on purpose: a broken
      // boot still fails, at the ceiling instead of by coin flip.
      bool renderReady() {
        final renderers =
            game.world.children.whereType<WorldObjectRenderer>().toList();
        final groundLayers =
            game.world.children.whereType<GroundChunkRenderer>().toList();
        return game.simObjects.length == 6 &&
            renderers.length == 6 &&
            renderers.every(
              (renderer) =>
                  renderer.children.whereType<SpriteComponent>().isNotEmpty ||
                  renderer.children
                      .whereType<SpriteAnimationGroupComponent<String>>()
                      .isNotEmpty,
            ) &&
            groundLayers.length == 1 &&
            groundLayers.single.bakedChunkCount > 0 &&
            // The whole boot window, not just the first baked chunk — the
            // spawn chunk bakes on frame one, the window takes a few more.
            locator<ChunkStreamingSystem>().isWindowLoaded();
      }

      for (var i = 0; i < 400 && !renderReady(); i++) {
        await tester.pump(const Duration(milliseconds: 25));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });

    // Content booted from the generated assets.
    expect(locator<ActorRegistry>().count, greaterThan(0));
    expect(locator<LocalizationSystem>().isLoaded, isTrue);
    expect(game.simObjects.length, 6); // 5 props + the player
    expect(game.player.actorData.id, 't1_actor_creature_boar');

    // The render half of the gate: renderers must land inside `world` (the
    // ONLY subtree the CameraComponent renders — Flame's default FlameGame
    // wiring). A renderer added to the game root instead is silently never
    // drawn: no exception, just a background-colored screen. This caught
    // exactly that regression once already.
    final worldRenderers = game.world.children.whereType<WorldObjectRenderer>();
    expect(worldRenderers.length, 6);
    expect(game.children.whereType<WorldObjectRenderer>(), isEmpty);

    // Each renderer actually finished loading its sheet and produced a
    // visible child — a silently-swallowed sprite-load failure would leave
    // the renderer mounted but empty.
    for (final renderer in worldRenderers) {
      expect(
        renderer.children.whereType<SpriteComponent>().isNotEmpty ||
            renderer.children
                .whereType<SpriteAnimationGroupComponent<String>>()
                .isNotEmpty,
        isTrue,
        reason: '${renderer.host.data.id} has no visible sprite child',
      );
    }

    // The procedural world exists around the player (FP3.4): the ground
    // under its feet is registered, the streaming window is whole, and the
    // ground layer holds baked chunks the camera can draw.
    final grid = locator<GridManager>();
    final playerTile = grid.worldToGrid(game.player.position);
    expect(grid.hasGroundAt(playerTile), isTrue,
        reason: 'the player stands on unregistered terrain');
    expect(locator<ChunkStreamingSystem>().isWindowLoaded(), isTrue,
        reason: 'the boot window never finished materializing');
    final groundLayer =
        game.world.children.whereType<GroundChunkRenderer>().single;
    expect(groundLayer.bakedChunkCount, greaterThan(0));

    // Feed a "D held" state straight into the input SSOT (a raw key event
    // needs a focused widget tree; the helper is the contract, so it is the
    // seam) and run the sim for half a second of frames.
    final startX = game.player.position.x;
    locator<InputHelper>().handleKeyEvent(
      const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyD,
        logicalKey: LogicalKeyboardKey.keyD,
        timeStamp: Duration.zero,
      ),
    );
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.player.position.x, greaterThan(startX));
    expect(game.player.movement.isMoving, isTrue);
  });
}
