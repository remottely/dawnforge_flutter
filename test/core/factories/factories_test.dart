import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/ground_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  group('ActorFactory', () {
    test('registry data → shell → injected CLONE of the soul (rules 1-3)', () {
      locator<ActorRegistry>().registerJson(<String, Object?>{
        'id': 't1_actor_slime',
        'base_max_health': 8,
      });

      final actor =
          ActorFactory.create('t1_actor_slime', const WorldPos(32, 48));

      expect(actor.isInitialized, isTrue);
      expect(actor.actorData.id, 't1_actor_slime');
      expect(actor.position, const WorldPos(32, 48));

      // The soul is a clone: hurting the instance never touches the registry.
      actor.actorData.takeDamage(5);
      expect(
        locator<ActorRegistry>().getActor('t1_actor_slime').currentHealth,
        8.0,
      );
    });

    test('unknown id crashes at creation (rule 5)', () {
      expect(
        () => ActorFactory.create('t9_actor_ghost', const WorldPos(0, 0)),
        throwsStateError,
      );
    });
  });

  group('PropFactory', () {
    test('creates an initialized prop host', () {
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_bush',
        'has_idle_sway': true,
      });

      final prop = PropFactory.create('t1_prop_bush', const WorldPos(0, 0));

      expect(prop.propData.hasIdleSway, isTrue);
    });
  });

  group('GroundFactory', () {
    test('takes a tile address and derives world position via GridManager', () {
      locator<GroundRegistry>().registerJson(<String, Object?>{
        'id': 't1_ground_grass',
      });

      final ground = GroundFactory.create('t1_ground_grass', const GridPos(2, 3));

      expect(
        ground.position,
        const WorldPos(
          2.0 * GameConstants.tileDimension,
          3.0 * GameConstants.tileDimension,
        ),
      );
    });
  });
}
