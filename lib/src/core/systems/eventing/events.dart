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
}
