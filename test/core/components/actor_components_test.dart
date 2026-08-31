import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP1.5 slice: a factory-built actor moves, faces and takes damage through
/// its components, with all state living in the data soul (rule 8).
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  const step = GameConstants.simFixedStep;

  void registerTestActor({double maxHealth = 10}) {
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe',
      'base_max_health': maxHealth,
      'move_speed': 2.0,
      'acceleration': 1000.0, // effectively instant, keeps the maths readable
      'friction': 1000.0,
    });
  }

  group('movement + direction', () {
    test('input accelerates, integrates into position, updates facing', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);

      // Tick 1: still LOOKING right while moving left → backpedal, half speed.
      actor.movement.applyMovement(const WorldPos(-1, 0), step);
      expect(actor.movement.velocity.x, closeTo(-16, 1e-6));

      // Tick 2: facing followed the velocity, so now it is full speed:
      // 2 tiles/s * 16 px = 32 px/s to the left.
      actor.movement.applyMovement(const WorldPos(-1, 0), step);
      actor.update(step);
      expect(actor.movement.velocity.x, closeTo(-32, 1e-6));
      expect(actor.position.x, lessThan(0));
      expect(actor.direction.direction, ActorDirection.left);
      expect(actor.movement.isMoving, isTrue);
    });

    test('no input applies friction to a stop', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);

      actor.movement.applyMovement(WorldPos.right, step);
      actor.movement.applyMovement(WorldPos.zero, step);

      expect(actor.movement.velocity, WorldPos.zero);
      expect(actor.movement.isMoving, isFalse);
    });

    test('backpedaling halves the target speed', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);

      // Look right first, then move left: opposite to look = backpedal.
      actor.direction.lookDirection = WorldPos.right;
      actor.direction.faceMovement = false; // hold facing for the assertion
      actor.movement.applyMovement(const WorldPos(-1, 0), step);

      expect(actor.movement.isMovingBackwards, isTrue);
      expect(actor.movement.velocity.x, closeTo(-16, 1e-6)); // half of 32
    });
  });

  group('health', () {
    test('damage flows through the data soul and signals fire in order', () {
      registerTestActor(maxHealth: 4);
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);
      final log = <String>[];
      actor.health.damaged.connect((event) => log.add('damaged ${event.$1}'));
      actor.health.healthChanged
          .connect((event) => log.add('changed ${event.$1}'));
      actor.health.died.connect((_) => log.add('died'));

      expect(actor.health.takeDamage(3), isTrue);
      expect(actor.actorData.currentHealth, 1.0); // state lives in data
      expect(actor.health.takeDamage(3), isTrue);
      expect(actor.health.takeDamage(3), isFalse); // already dead — refused

      expect(log, [
        'damaged 3.0',
        'changed 1.0',
        'damaged 3.0',
        'changed 0.0',
        'died',
      ]);
    });

    test('invulnerability refuses the hit', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero)
        ..health.isInvulnerable = true;

      expect(actor.health.takeDamage(5), isFalse);
      expect(actor.actorData.currentHealth, 10.0);
    });

    test('regeneration pays in half-point steps via the fixed tick', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);
      actor.health
        ..takeDamage(5)
        ..regenerationRate = 1.0; // 1 hp/s

      // Half a second of fixed steps (+1: thirty sums of 1/60 land a hair
      // under 0.5 in floating point) → exactly one 0.5 payout.
      final ticks = (0.5 / step).round() + 1;
      for (var i = 0; i < ticks; i++) {
        actor.update(step);
      }

      expect(
        actor.actorData.currentHealth,
        closeTo(5 + EngineConstants.healthRegenStep, 1e-6),
      );
    });

    test('no revive: a dead actor never regenerates', () {
      registerTestActor();
      final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);
      actor.health
        ..takeDamage(10)
        ..regenerationRate = 100.0;

      actor.update(step);

      expect(actor.actorData.currentHealth, 0.0);
      expect(actor.actorData.isDead, isTrue);
    });
  });
}
