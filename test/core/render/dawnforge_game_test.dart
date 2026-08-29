import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/render/debug_overlay.dart';
import 'package:dawnforge/src/core/render/ground_chunk_renderer.dart';
import 'package:dawnforge/src/core/render/world_object_renderer.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/ui/game_overlays.dart';
import 'package:dawnforge/src/core/ui/interface/hotbar_view.dart';
import 'package:dawnforge/src/core/ui/interface/inventory_panel_view.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
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
      await tester.pumpWidget(
        // The app's own overlay table, not a copy: the boot has to prove the
        // interface reaches the screen, and Flame refuses an overlay name it
        // has no builder for.
        GameWidget<DawnforgeGame>(
          game: game,
          overlayBuilderMap: gameOverlays(),
        ),
      );
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
        // The population is the seed's own (FP4.1d): the player plus
        // whatever the boot window scattered — count equality between hosts
        // and renderers is the readiness signal, not a hand-counted number.
        return game.simObjects.length > 1 &&
            renderers.length == game.simObjects.length &&
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

    // Content booted from the generated assets; the boot window scattered
    // procedural props around the player (FP4.1d).
    expect(locator<ActorRegistry>().count, greaterThan(0));
    expect(locator<LocalizationSystem>().isLoaded, isTrue);
    expect(game.simObjects.length, greaterThan(1),
        reason: 'the boot window scattered no props');
    // The player is its own authored actor (FP4.2b), not the boar that stood
    // in for one. The bag is the reason it had to stop being a boar: a boar
    // authors `inventory_size: 0`, so every pickup in the running game was
    // refused for want of a slot to land in.
    expect(game.player.actorData.id, GameConstants.playerActorId);
    expect(game.player.inventory.maxSlots, 30);
    expect(game.player.inventory.maxSlots % GameConstants.slotsPerRow, 0,
        reason: 'the bag must be a whole number of rows for the grid to page');
    // And it boots holding something (FP4.3a): the bag starts empty, so the
    // hand is the innate one the pack authors. Proven here rather than only
    // against a probe, because this is the one test that resolves the id
    // against the REAL item registry — a renamed hand item fails here.
    expect(
      game.player.heldItem.currentItem?.id,
      GameConstants.innateHandItemId(game.player.actorData.tier),
    );

    // The render half of the gate: renderers must land inside `world` (the
    // ONLY subtree the CameraComponent renders — Flame's default FlameGame
    // wiring). A renderer added to the game root instead is silently never
    // drawn: no exception, just a background-colored screen. This caught
    // exactly that regression once already.
    final worldRenderers = game.world.children.whereType<WorldObjectRenderer>();
    expect(worldRenderers.length, game.simObjects.length);
    expect(game.children.whereType<WorldObjectRenderer>(), isEmpty);

    // The scatter registered its occupancy: every scattered prop's anchor
    // tile maps back to its own host (FP4.1d).
    final gridForProps = locator<GridManager>();
    for (final host in game.simObjects.whereType<Prop>()) {
      final anchor = gridForProps.worldToGrid(host.position);
      expect(identical(gridForProps.getPropAt(anchor), host), isTrue,
          reason: '${host.data.id} at $anchor is not the grid occupant');
    }

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

    // The FP3.6 proof instrument publishes real numbers in screen space.
    final overlay =
        game.camera.viewport.children.whereType<DebugOverlay>().single;
    expect(overlay.lines, hasLength(3));
    expect(overlay.lines[0], startsWith('fps '));
    expect(
      overlay.lines[2],
      contains('${groundLayer.bakedChunkCount} baked'),
    );

    // The interface reached the screen (FP4.2b). It is a FLUTTER widget over
    // the game surface, so it is found in the widget tree and not among the
    // Flame children — which is exactly why the boot test mounts the app's own
    // overlay table instead of a bare GameWidget.
    expect(find.byType(HotbarView), findsOneWidget);
    expect(game.overlays.isActive(DawnforgeGame.hotbarOverlay), isTrue);

    // The bag opens and closes for real (FP4.2b), through the whole chain the
    // app uses: a key raises an intent, the shell mounts the overlay, the
    // panel registers as a surface, and the back press reaches it only
    // because the arbiter routed it there (rule 25).
    locator<InputHelper>().handleKeyEvent(const KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyI,
      logicalKey: LogicalKeyboardKey.keyI,
      timeStamp: Duration.zero,
    ));
    await tester.pump();
    expect(find.byType(InventoryPanelView), findsOneWidget);
    expect(locator<UIStateMachine>().state, UIState.menu);
    // Rule 30 at the level that matters: the player is stopped from acting and
    // the game is not stopped. There is no pause in this codebase to call.
    expect(locator<GameInputManager>().isGameplayEnabled, isFalse);

    locator<InputHelper>().handleKeyEvent(const KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    ));
    await tester.pump();
    expect(find.byType(InventoryPanelView), findsNothing);
    expect(locator<GameInputManager>().isGameplayEnabled, isTrue);
    expect(find.byType(HotbarView), findsOneWidget,
        reason: 'the bar comes back with the screen');

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

    // THE CURSOR (FP4.3a). A tap aims and acts in one press: the cursor goes
    // where the pointer went down, and the intent fires from there. A finger
    // and a mouse reach the same two lines, which is what makes touch parity
    // structural rather than a second path (rule 12).
    var actions = 0;
    locator<InputHelper>().primaryActionPressed.connect(() => actions++);
    game.onTapDown(
      TapDownEvent(
        1,
        game,
        TapDownDetails(
          globalPosition: const Offset(120, 90),
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    expect(actions, 1, reason: 'one press, one intent (rule 24)');

    // And the world position is COMPUTED, not remembered: the camera moves
    // under a cursor that has not, so a player walking with the mouse held
    // still is aiming somewhere new every frame.
    final aimedBefore = locator<InputHelper>().getCursorWorldPos();
    game.camera.viewfinder.position += Vector2(64, 0);
    final aimedAfter = locator<InputHelper>().getCursorWorldPos();
    expect(aimedAfter.x, greaterThan(aimedBefore.x));
    expect(locator<InputHelper>().getCursorScreenPos().x, 120,
        reason: 'the pointer itself did not move');
  });
}
