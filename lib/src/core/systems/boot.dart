import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/timing/sim_clock.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:get_it/get_it.dart';

/// The service locator — the Dart port of the Godot `[autoload]` table.
/// Everything registered in [registerCoreSystems] exists from before the first
/// frame until teardown, so a registered system is NEVER null (rule 28):
/// call `locator<Events>()` plainly; an `isRegistered` guard is a fallback in
/// disguise. The one exception is a teardown path, commented as such.
final GetIt locator = GetIt.instance;

/// Registers every core system, in dependency order. Called exactly once at
/// boot (and per-test via a fresh scope); registering twice is a crash, which
/// GetIt already enforces.
void registerCoreSystems() {
  locator
    ..registerSingleton<Events>(Events())
    ..registerSingleton<SimClock>(SimClock())
    ..registerSingleton<GridManager>(GridManager())
    ..registerSingleton<GameInputManager>(GameInputManager())
    ..registerSingleton<ActorRegistry>(ActorRegistry())
    ..registerSingleton<PropRegistry>(PropRegistry())
    ..registerSingleton<GroundRegistry>(GroundRegistry())
    ..registerSingleton<ItemRegistry>(ItemRegistry());
}

/// Tears down every registration — tests only; the app never unboots.
Future<void> resetCoreSystems() => locator.reset();
