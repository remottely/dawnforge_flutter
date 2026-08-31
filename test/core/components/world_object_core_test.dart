import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/components/world_object_core.dart';
import 'package:flutter_test/flutter_test.dart';

final class _HealthProbe extends IComponent {
  double ticked = 0;

  @override
  void update(double dt) => ticked += dt;
}

final class _EnergyProbe extends IComponent {}

final class _LazyProbe extends IComponent {}

void main() {
  group('WorldObjectCore', () {
    test('keys components by class name and returns them typed', () {
      final core = WorldObjectCore();
      final health = core.addComponent(_HealthProbe());

      expect(health.componentKey, '_HealthProbe');
      expect(core.getComponent<_HealthProbe>('_HealthProbe'), same(health));
      expect(core.hasComponent('_HealthProbe'), isTrue);
      expect(core.componentCount, 1);
    });

    test('absent component is null, not a crash — the caller decides', () {
      final core = WorldObjectCore();
      expect(core.getComponent<_EnergyProbe>('_EnergyProbe'), isNull);
    });

    test('lazy materializer builds on first read, from any reader', () {
      final core = WorldObjectCore()
        ..setLazyMaterializer(
          (key) => key == '_LazyProbe' ? _LazyProbe() : null,
        );
      final sibling = core.addComponent(_HealthProbe());

      // A sibling read must trigger materialization too (Godot repo §4.5).
      final lazy = sibling.getSiblingComponent<_LazyProbe>('_LazyProbe');

      expect(lazy, isNotNull);
      expect(core.hasComponent('_LazyProbe'), isTrue);
      // Second read returns the same instance — built once.
      expect(core.getComponent<_LazyProbe>('_LazyProbe'), same(lazy));
    });

    test('update fans out the fixed step to every component', () {
      final core = WorldObjectCore();
      final health = core.addComponent(_HealthProbe());

      core.update(0.25);

      expect(health.ticked, 0.25);
    });

    test('removeComponent detaches and forgets', () {
      final core = WorldObjectCore();
      final health = core.addComponent(_HealthProbe());

      core.removeComponent('_HealthProbe');

      expect(core.hasComponent('_HealthProbe'), isFalse);
      expect(health.isRegistered, isFalse);
    });
  });
}
