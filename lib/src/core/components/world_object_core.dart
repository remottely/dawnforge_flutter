import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';

/// The single component container every world object owns (rule 15). Hosts
/// forward `addComponent`/`getComponent`/... to their core; nothing else may
/// declare a component map. A UI widget never owns a core.
///
/// Ported from the Godot `WorldObjectCore`, including the lazy materializer:
/// ground tiles build hover/life components on first use, so the builder is
/// registered on the core rather than on the host — that way *every* reader
/// triggers it, including a sibling read through [IComponent.getSiblingComponent].
final class WorldObjectCore {
  final Map<String, IComponent> _components = <String, IComponent>{};

  IComponent? Function(String key)? _lazyMaterializer;

  IWorldObjectData Function()? _dataProvider;

  /// Wired by the host's `initialize()` so components reach the data soul
  /// without the core knowing the host type (rule 8: state lives in data;
  /// components read through here, never cache).
  void setDataProvider(IWorldObjectData Function() provider) {
    assert(_dataProvider == null, '[WorldObjectCore] data provider set twice');
    _dataProvider = provider;
  }

  /// The host's data soul. Crash when unwired — a component reading data on a
  /// host that never initialized is invalid state (rule 5).
  IWorldObjectData get data {
    final provider = _dataProvider;
    assert(provider != null, '[WorldObjectCore] read data before initialize()');
    return provider!();
  }

  /// Registers a builder consulted before reporting any miss (see class doc).
  void setLazyMaterializer(IComponent? Function(String key) materializer) {
    assert(_lazyMaterializer == null, '[WorldObjectCore] materializer set twice');
    _lazyMaterializer = materializer;
  }

  /// Adds [component], keyed by its class name (rule 16). Adding a duplicate
  /// key is invalid state — crash, not replace (rule 5).
  T addComponent<T extends IComponent>(T component) {
    final key = component.componentKey;
    assert(
      !_components.containsKey(key),
      '[WorldObjectCore] duplicate component: $key',
    );
    _components[key] = component;
    component.attach(this);
    return component;
  }

  /// The component under [key], or `null` when absent — absence is a
  /// legitimate answer (not every host has mana); a component the caller
  /// *requires* is asserted at the call site, never assumed.
  T? getComponent<T extends IComponent>(String key) {
    final existing = _components[key];
    if (existing != null) {
      assert(existing is T, '[WorldObjectCore] $key is not a $T');
      return existing as T;
    }
    final materializer = _lazyMaterializer;
    if (materializer != null) {
      final built = materializer(key);
      if (built != null) {
        assert(
          built.componentKey == key,
          '[WorldObjectCore] materializer built ${built.componentKey} for $key',
        );
        _components[key] = built;
        built.attach(this);
        assert(built is T, '[WorldObjectCore] $key is not a $T');
        return built as T;
      }
    }
    return null;
  }

  bool hasComponent(String key) => _components.containsKey(key);

  void removeComponent(String key) {
    final component = _components.remove(key);
    assert(component != null, '[WorldObjectCore] removing absent component: $key');
    component!.detach();
  }

  /// Fixed-step tick fan-out, iteration-safe against mid-tick add/remove.
  void update(double dt) {
    for (final component in List<IComponent>.of(_components.values)) {
      if (component.isRegistered) {
        component.update(dt);
      }
    }
  }

  int get componentCount => _components.length;
}
