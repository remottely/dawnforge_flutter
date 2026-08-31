import 'package:dawnforge/src/core/components/world_object_core.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';

/// Base of every behavior component (ECS-lite, Godot repo §4.5). World objects
/// are containers; game logic lives in `IComponent` subclasses.
///
/// The container key is the concrete class name, resolved at registration —
/// the Dart port of "the key is the `class_name`" (rule 16). `ComponentKeys`
/// (generated, pipeline step 10) restates the same names, so the constant a
/// caller passes and the key the container stores cannot drift.
abstract class IComponent {
  WorldObjectCore? _core;

  /// The container this component was added to. Crash on read before
  /// registration (rule 5) — a component outside a container is invalid state.
  WorldObjectCore get core {
    final owner = _core;
    assert(owner != null, '[$runtimeType] read core before registration');
    return owner!;
  }

  bool get isRegistered => _core != null;

  /// The container key: the concrete class name (rule 16).
  String get componentKey => runtimeType.toString();

  /// Called by [WorldObjectCore.addComponent] — never directly.
  void attach(WorldObjectCore owner) {
    assert(_core == null, '[$runtimeType] attached twice');
    _core = owner;
    onAttach();
  }

  /// Called by [WorldObjectCore.removeComponent] — never directly.
  void detach() {
    assert(_core != null, '[$runtimeType] detached while unattached');
    onDetach();
    _core = null;
  }

  /// Lifecycle hook: the component joined its container.
  void onAttach() {}

  /// Lifecycle hook: the component is leaving its container.
  void onDetach() {}

  /// Fixed-step simulation tick (SimClock cadence, never render dt).
  void update(double dt) {}

  /// A sibling on the same container, `null` when absent — absence is a
  /// legitimate answer; a component you require is asserted at the call site.
  T? getSiblingComponent<T extends IComponent>(String key) =>
      core.getComponent<T>(key);

  /// The host's data soul — where ALL mutable game state lives (rule 8).
  /// Components read through this on every access, never cache.
  IWorldObjectData get data => core.data;
}
