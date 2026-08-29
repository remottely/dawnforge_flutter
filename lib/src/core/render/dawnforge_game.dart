import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:dawnforge/src/core/base/world_objects/actors/player/actor_player.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/render/debug_overlay.dart';
import 'package:dawnforge/src/core/render/ground_chunk_renderer.dart';
import 'package:dawnforge/src/core/render/item_world_renderer.dart';
import 'package:dawnforge/src/core/render/world_object_renderer.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/systems/spawning/procedural_spawn_system.dart';
import 'package:dawnforge/src/core/systems/timing/sim_clock.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

/// The Flame shell (FP3.1): boots content from the generated assets, drives
/// the fixed-step simulation, and binds hosts to renderers. Since FP3.4 the
/// world is procedural and chunked: the generator decides terrain, the
/// streaming materializes it around the player, and [GroundChunkRenderer]
/// bakes it to the screen.
///
/// Rule 30 lives here structurally: nothing ever calls a pause — a surface
/// that must hold the player pushes a GameInputManager blocker and this loop
/// keeps running.
final class DawnforgeGame extends FlameGame
    with KeyboardEvents, PointerMoveCallbacks, TapCallbacks {
  DawnforgeGame({this.locale = 'pt_BR', this.worldSeed = 0});

  final String locale;

  /// The seed this world is built from; 0 resolves through
  /// [ProceduralWorldManager.resolveNewWorldSeed] (debug pin or fresh roll).
  /// Tests pass a fixed one.
  final int worldSeed;

  /// Flame's name for the hotbar overlay. The interface is FLUTTER, not Flame
  /// components (study §3.1: widgets are Flutter's strongest suit and the
  /// spec's `Control` tree ports to them directly) — the overlay is the seam
  /// that lets a widget sit over the game surface without either side owning
  /// the other.
  static const String hotbarOverlay = 'hotbar';

  /// Flame's name for the inventory panel overlay.
  static const String inventoryOverlay = 'inventory';

  /// Every simulated host, ticked on the fixed step.
  final List<WorldObject> simObjects = <WorldObject>[];

  /// Live pickups (FP4.1): ticked against the player each fixed step,
  /// removed once collected. Every one is born through
  /// `WorldDropHelper.spawnPickup` and arrives via `Events.pickupSpawned`.
  final List<ItemWorld> pickups = <ItemWorld>[];

  late final ActorPlayer player;

  /// The chunked ground layer — typed access for the debug overlay and the
  /// gate test.
  late final GroundChunkRenderer groundLayer;

  /// The endless sea: water is never painted per tile — the background IS
  /// the water, exactly as the Godot renderer treats it. The color is the
  /// biome water base (`BiomeData.water_color_base`).
  static const _waterBase = Color(0xFF2B75A1);

  @override
  Color backgroundColor() => _waterBase;

  Future<Map<String, Object?>> _loadJson(String assetKey) async =>
      jsonDecode(await rootBundle.loadString(assetKey))!
          as Map<String, Object?>;

  @override
  Future<void> onLoad() async {
    const game = GameConstants.gameName;

    // Content boot: registries from the manifest, strings for the locale.
    final almanacRoot = ContentPaths.almanacRoot(game);
    final manifest = await _loadJson('$almanacRoot/manifest.json');
    final entries = <String, Map<String, Object?>>{};
    for (final raw
        in (manifest['entries']! as List).cast<Map<String, Object?>>()) {
      final path = raw['path']! as String;
      entries[path] = await _loadJson('$almanacRoot/$path');
    }
    const AlmanacLoader().loadFromManifest(manifest, (path) => entries[path]!);

    // The biome manifest (pipeline step 11) routes through the same loader.
    final biomesRoot = ContentPaths.worldBiomesRoot(game);
    final biomeManifest = await _loadJson('$biomesRoot/manifest.json');
    final biomeEntries = <String, Map<String, Object?>>{};
    for (final raw
        in (biomeManifest['entries']! as List).cast<Map<String, Object?>>()) {
      final path = raw['path']! as String;
      biomeEntries[path] = await _loadJson('$biomesRoot/$path');
    }
    const AlmanacLoader()
        .loadFromManifest(biomeManifest, (path) => biomeEntries[path]!);

    locator<LocalizationSystem>().loadLocale(
      locale,
      await _loadJson('${ContentPaths.localesRoot(game)}/$locale.json'),
    );

    // The procedural world (FP3.4): seed → generator → spawn → streaming.
    // The renderer mounts BEFORE streaming initializes so no chunkLoaded is
    // missed (it also seeds from loadedChunks — belt and braces). The spawn
    // system connects before it too, for the same reason: the boot window's
    // own chunkLoaded signals are its population trigger (FP4.1d).
    final worldManager = locator<ProceduralWorldManager>()
      ..initialize(ProceduralWorldManager.resolveNewWorldSeed(worldSeed));
    final spawnTile = worldManager.findSpawnTile();
    groundLayer = GroundChunkRenderer();
    await world.add(groundLayer);

    // Scattered content: hosts arrive/leave via the bus; renderers bind here.
    locator<Events>().worldObjectSpawned.connect((Object payload) {
      final host = payload as WorldObject;
      simObjects.add(host);
      final renderer = WorldObjectRenderer(host);
      _hostRenderers[host] = renderer;
      unawaited(Future<void>.sync(() => world.add(renderer)));
    });
    locator<Events>().worldObjectDespawned.connect((Object payload) {
      final host = payload as WorldObject;
      simObjects.remove(host);
      _hostRenderers.remove(host)?.removeFromParent();
    });
    locator<ProceduralSpawnSystem>().initialize(
      worldSeed: worldManager.worldSeed,
      biome: worldManager.activeBiome,
      // The spawn patch stays prop-free — the interim stand-in for the
      // actor-overlap clause until ActorOccupancyHelper (FP4.3a).
      reservedTiles: <GridPos>[
        for (var dx = -1; dx <= 1; dx++)
          for (var dy = -1; dy <= 1; dy++)
            GridPos(spawnTile.x + dx, spawnTile.y + dy),
      ],
    );
    locator<ChunkStreamingSystem>().initialize(spawnTile);

    // The FP3.6 proof instrument, in screen space above everything.
    await camera.viewport.add(DebugOverlay());

    // The player is an authored actor of its own (FP4.2b) — imported from the
    // spec's pack, where it is the one document that belongs to no biome. It
    // stood in as a boar until now, and a boar authors `inventory_size: 0`,
    // so nothing the world dropped could ever be picked up.
    player = ActorFactory.createPlayer(
      GameConstants.playerActorId,
      locator<GridManager>().gridToWorld(spawnTile),
    );
    final playerRenderer = ActorRenderer(player);
    simObjects.add(player);
    await world.add(playerRenderer);

    camera.viewfinder.zoom = 4;
    camera.follow(playerRenderer, snap: true);

    // Every pickup the simulation produces gets its render binding here —
    // the view listens to the sim, never the reverse (rule 18: the payload
    // is the declared host type, cast and trusted).
    locator<Events>().pickupSpawned.connect((Object payload) {
      final pickup = payload as ItemWorld;
      pickups.add(pickup);
      // Fire-and-forget mount: Flame queues the child; the renderer draws
      // on the frame its onLoad resolves.
      unawaited(Future<void>.sync(() => world.add(ItemWorldRenderer(pickup))));
    });

    // Which surfaces are ON SCREEN is the shell's job — a widget cannot mount
    // itself. What each one DOES once mounted is entirely its own, which is
    // why the panel closes itself through a callback rather than this class
    // reaching into it.
    locator<InputHelper>()
      // The one wire between the camera and the cursor (rule 11): the sim
      // asks `InputHelper` where the player is pointing and gets a WORLD
      // position, without any part of it ever touching a camera. Set here
      // rather than at boot because the camera it projects through only
      // exists once the game has loaded.
      ..screenToWorld = _cursorScreenToWorld
      // The press reaches the player and stops there: WHAT it means is the
      // player's own decision (aim, reach, cooldown), not this shell's.
      ..primaryActionPressed.connect(player.performPrimaryAction)
      ..inventoryToggled.connect(_toggleInventory)
      // Rule 25: the press is routed ONCE, by the machine, to whatever owns
      // the screen. This is the only listener of the key in the game, and it
      // does not decide anything — it asks.
      ..cancelPressed.connect(locator<UIStateMachine>().requestCancel);

    // Last, because the overlay reads `player.inventory` the moment it builds.
    overlays.add(hotbarOverlay);
  }

  /// The camera's own screen→world projection, handed to `InputHelper` at
  /// load. A method rather than a closure so the wiring above reads as one
  /// list of connections.
  WorldPos _cursorScreenToWorld(WorldPos screenPos) {
    final worldPos = camera.globalToLocal(Vector2(screenPos.x, screenPos.y));
    return WorldPos(worldPos.x, worldPos.y);
  }

  @override
  void onPointerMove(PointerMoveEvent event) =>
      locator<InputHelper>().handlePointerMove(event);

  /// A click or a tap. It goes to `InputHelper` and no further: what the press
  /// MEANS is decided by whoever subscribes to the intent it raises, which is
  /// how one press stays one action (rules 11 and 24).
  @override
  void onTapDown(TapDownEvent event) =>
      locator<InputHelper>().handleTapDown(event);

  void _toggleInventory() {
    if (overlays.isActive(inventoryOverlay)) {
      closeInventory();
    } else {
      overlays.add(inventoryOverlay);
    }
  }

  /// Takes the panel off screen. The panel itself calls this — through the
  /// callback it was handed — when the routed back press reaches it.
  void closeInventory() => overlays.remove(inventoryOverlay);

  /// Puts the whole of one of the player's slots on the ground at its feet.
  ///
  /// The pickup's authored `pickup_delay` is what stops it flying straight
  /// back into the bag it just left; without that field being read this would
  /// be a no-op the player watches happen (0.24.2).
  void dropSlotToWorld(int slotIndex) {
    final taken = player.inventory.removeItemAtIndex(
      slotIndex,
      player.inventory.slots[slotIndex].amount,
    );
    if (taken == null) return;
    // Landing resolution runs against the player's own tile as the origin, so
    // a drop made while standing in a sealed pocket answers to where the
    // player IS — the same honesty FP4.1c's landing rings were built on.
    WorldDropHelper.spawnPickup(
      locator<ItemRegistry>().getItem(taken.itemId),
      taken.amount,
      player.position,
      player.position,
    );
  }

  /// Renderer of every scattered host, for unbind on despawn. Renderers go
  /// into `world`, never the game root — the CameraComponent only renders
  /// `world`'s subtree (Flame 1.32 default wiring).
  final Map<WorldObject, WorldObjectRenderer> _hostRenderers =
      <WorldObject, WorldObjectRenderer>{};

  @override
  void update(double dt) {
    // Fixed-step simulation under a variable render loop (study risk #5).
    final dropped = locator<SimClock>().advance(dt, _simTick);
    assert(dropped == 0 || dt > 1, 'SimClock dropped $dropped steps');

    // Streaming runs on the RENDER frame, not the fixed step — what this
    // machine materializes is a view-side concern (mirror of the Godot
    // `_process` placement). The camera's visible rect widens the window
    // when zoomed out.
    final visible = camera.visibleWorldRect;
    locator<ChunkStreamingSystem>().update(
      playerTile: locator<GridManager>().worldToGrid(player.position),
      visibleWorldWidth: visible.width,
      visibleWorldHeight: visible.height,
    );
    super.update(dt);
  }

  void _simTick(double stepDt) {
    if (locator<GameInputManager>().isGameplayEnabled) {
      final input = locator<InputHelper>().getMovementVector();
      player.movement.applyMovement(input, stepDt);
    }
    for (final host in simObjects) {
      host.update(stepDt);
    }
    for (final pickup in pickups) {
      pickup.tick(
        stepDt,
        collectorPosition: player.position,
        collectorInventory: player.inventory,
      );
    }
    pickups.removeWhere((pickup) => pickup.collected);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    locator<InputHelper>().handleKeyEvent(event);
    return KeyEventResult.handled;
  }
}
