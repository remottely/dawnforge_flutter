import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/generated/component_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rule 16 proof: the generated constants and the runtime container keys are
/// the same names, derived from the same class declarations.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  test('a factory actor answers to every generated key', () {
    locator<ActorRegistry>()
        .registerJson(<String, Object?>{'id': 't1_actor_probe'});
    final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);

    expect(actor.hasComponent(ComponentKeys.direction), isTrue);
    expect(actor.hasComponent(ComponentKeys.movement), isTrue);
    expect(actor.hasComponent(ComponentKeys.health), isTrue);
    expect(actor.getComponent(ComponentKeys.health), same(actor.health));
  });
}
