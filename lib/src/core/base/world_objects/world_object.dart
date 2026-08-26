import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/components/world_object_core.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Base of every world-object HOST — the shell that owns a data soul and a
/// component container. Pure Dart: the Flame render binding wraps hosts in
/// FP3; the simulation below never imports Flame.
///
/// The injection contract (rule 3): a host is constructed empty by its
/// FACTORY (rule 1), receives its soul via [initialize] — always a clone, each
/// instance owns its state — and is unusable before that (crash, rule 5).
abstract class WorldObject {
  /// The single component container (rule 15). Hosts forward to it; nothing
  /// else may declare a component map.
  final WorldObjectCore core = WorldObjectCore();

  IWorldObjectData? _data;
  bool get isInitialized => _data != null;

  /// The data soul. Crash on read before [initialize] (rule 5).
  IWorldObjectData get data {
    final soul = _data;
    assert(soul != null, '[$runtimeType] read data before initialize()');
    return soul!;
  }

  WorldPos position = const WorldPos(0, 0);

  /// Injects the soul. Called by the factory, exactly once, with an instance
  /// the factory already cloned (rule 3).
  void initialize(IWorldObjectData initialData) {
    assert(_data == null, '[$runtimeType] already initialized');
    _data = initialData;
    setupComponents();
  }

  /// Composes this host's components (Godot repo §4.5). Runs once, at the end
  /// of [initialize]; dependency order is the override's responsibility.
  void setupComponents() {}

  // The host forwards; it never keeps a container of its own (rule 15).
  T addComponent<T extends IComponent>(T component) =>
      core.addComponent(component);
  T? getComponent<T extends IComponent>(String key) =>
      core.getComponent<T>(key);
  bool hasComponent(String key) => core.hasComponent(key);
  void removeComponent(String key) => core.removeComponent(key);

  /// Fixed-step simulation tick.
  void update(double dt) {
    assert(isInitialized, '[$runtimeType] update before initialize()');
    core.update(dt);
  }

  /// The shared save envelope (Godot repo §7): data + position; hosts add only
  /// what is genuinely their own on top.
  Map<String, Object?> serializeEnvelope() => <String, Object?>{
        'data': data.serialize(),
        'position': <String, Object?>{'x': position.x, 'y': position.y},
      };
}
