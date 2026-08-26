import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromJson', () {
    test('omitted fields keep the declared defaults (same contract as .tres)',
        () {
      final actor = IActorData.fromJson(<String, Object?>{'id': 't1_actor_x'});

      expect(actor.id, 't1_actor_x');
      expect(actor.moveSpeed, EngineConstants.baseMoveSpeed);
      expect(actor.baseMaxHealth, EngineConstants.defaultMaxHealth);
      expect(actor.aiBehavior, AIBehavior.neutral);
      expect(actor.allowsActorOverlap, isTrue);
    });

    test('present fields override, enums travel as int index', () {
      final actor = IActorData.fromJson(<String, Object?>{
        'id': 't2_actor_wolf',
        'move_speed': 4.5,
        'base_max_health': 12,
        'ai_behavior': 0, // offensive
      });

      expect(actor.moveSpeed, 4.5);
      expect(actor.maxHealth, 12.0);
      expect(actor.aiBehavior, AIBehavior.offensive);
    });

    test('a present field of the wrong type is invalid content — crash', () {
      expect(
        () => IActorData.fromJson(
          <String, Object?>{'id': 't1_actor_x', 'move_speed': 'fast'},
        ),
        throwsStateError,
      );
    });

    test('a missing id is invalid content — crash (rule 5)', () {
      expect(
        () => ItemData.fromJson(<String, Object?>{'max_stack': 3}),
        throwsStateError,
      );
    });

    test('ground farm knobs parse as tool enum list (rule 33)', () {
      final ground = GroundBuildableData.fromJson(<String, Object?>{
        'id': 't1_ground_soil',
        'farm_prop_id': 't1_prop_soil_tilled',
        'farm_tools': <int>[2], // hoe
      });

      expect(ground.farmTools, <ToolType>[ToolType.hoe]);
      expect(ground.farmPropId, 't1_prop_soil_tilled');
    });
  });

  group('health contract', () {
    test('spawns at full health; damage and heal clamp', () {
      final actor = IActorData.fromJson(<String, Object?>{
        'id': 't1_actor_x',
        'base_max_health': 10,
      });

      expect(actor.currentHealth, 10.0);
      actor.takeDamage(25);
      expect(actor.currentHealth, 0.0);
      expect(actor.isDead, isTrue);
      actor.heal(99);
      expect(actor.currentHealth, 10.0);
    });

    test('serialize carries mutable state only', () {
      final actor = IActorData.fromJson(<String, Object?>{'id': 't1_actor_x'})
        ..takeDamage(1);

      expect(actor.serialize(), <String, Object?>{
        'current_health': EngineConstants.defaultMaxHealth - 1,
      });
    });
  });

  group('clone', () {
    test('is a deep, state-carrying copy — each instance owns its state', () {
      final original = IActorData.fromJson(<String, Object?>{
        'id': 't1_actor_x',
        'base_max_health': 10,
      })
        ..takeDamage(4);

      final copy = original.clone()..takeDamage(4);

      expect(original.currentHealth, 6.0);
      expect(copy.currentHealth, 2.0);
    });
  });
}
