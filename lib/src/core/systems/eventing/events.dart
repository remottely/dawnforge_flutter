import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// The global signal bus — the Dart port of the Godot `Events` autoload.
/// All cross-system communication goes through here; systems never hold direct
/// references to each other for notification purposes.
///
/// Registered once at boot in the service locator and never null after
/// (rule 28): call `Events` plainly, never guard it.
///
/// Signals are added here as their systems are ported — one declaration per
/// event, typed payloads, named after the fact that happened (past tense).
final class Events {
  /// A world object finished initializing and entered the world.
  final worldObjectSpawned = EventSignal<Object>();

  /// A world object's health reached zero.
  final worldObjectDied = EventSignal<Object>();

  /// A user-facing notification was queued (rule 33: a tool that refuses says so).
  final notificationAdded = EventSignal<String>();

  /// A pickup entered the world (payload: the `ItemWorld` host — `Object` on
  /// purpose, like [worldObjectSpawned]: the bus never imports host types).
  /// The render layer listens and binds a renderer.
  final pickupSpawned = EventSignal<Object>();

  /// A world object left the world (its chunk unloaded, it was destroyed).
  /// The render layer listens and unbinds the renderer.
  final worldObjectDespawned = EventSignal<Object>();

  /// The GROUND at a tile became something else (FP4.3b: a bridge laid over
  /// water). Typed, unlike the host payloads above — a [GridPos] is a
  /// definition, not a host, so naming it costs the bus nothing.
  ///
  /// This is the seam a nodeless terrain needs and the spec does not: there,
  /// a placed tile is a NODE that adds itself to the scene and draws. Here the
  /// ground is baked a chunk at a time from the tile registry, so the tile
  /// changing and the screen changing are two facts, and this is the wire
  /// between them.
  final groundTileChanged = EventSignal<GridPos>();
}
