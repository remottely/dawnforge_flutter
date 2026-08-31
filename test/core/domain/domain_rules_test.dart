import 'package:dawnforge/src/core/domain/movement/direction_rules.dart';
import 'package:dawnforge/src/core/domain/movement/movement_rules.dart';
import 'package:dawnforge/src/core/domain/vitality/health_rules.dart';
import 'package:dawnforge/src/core/domain/vitality/vital_regen_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovementRules', () {
    test('perpendicular movement is NOT backpedaling (threshold -0.1)', () {
      const right = WorldPos.right;
      expect(
        MovementRules.isBackpedaling(const WorldPos(0, 1), right),
        isFalse, // perpendicular: dot == 0 > -0.1
      );
      expect(
        MovementRules.isBackpedaling(const WorldPos(-1, 0), right),
        isTrue, // opposite: dot == -1
      );
    });

    test('backpedal penalty halves speed', () {
      expect(
        MovementRules.applyBackpedalPenalty(4, isBackpedaling: true),
        2.0,
      );
      expect(
        MovementRules.applyBackpedalPenalty(4, isBackpedaling: false),
        4.0,
      );
    });

    test('target velocity converts tiles/s into world units/s', () {
      expect(
        MovementRules.calculateTargetVelocity(WorldPos.right, 3, 16),
        const WorldPos(48, 0),
      );
    });

    test('moving threshold is 0.625 tiles/s squared', () {
      expect(MovementRules.movingThresholdSquared(16), 100.0); // (10 px/s)²
    });
  });

  group('DirectionRules', () {
    test('direction follows horizontal velocity', () {
      expect(
        DirectionRules.directionFromVelocityX(5),
        ActorDirection.right,
      );
      expect(
        DirectionRules.directionFromVelocityX(-5),
        ActorDirection.left,
      );
    });

    test('a target to the left means facing left', () {
      expect(
        DirectionRules.directionFromTargetPosition(
          const WorldPos(-10, 0),
          WorldPos.zero,
        ),
        ActorDirection.left,
      );
    });
  });

  group('HealthRules', () {
    test('invulnerable or dead targets refuse damage', () {
      expect(HealthRules.canTakeDamage(5, isInvulnerable: true), isFalse);
      expect(HealthRules.canTakeDamage(0, isInvulnerable: false), isFalse);
      expect(HealthRules.canTakeDamage(5, isInvulnerable: false), isTrue);
    });

    test('no revive via heal', () {
      expect(HealthRules.canHeal(3, 0), isFalse);
      expect(HealthRules.canHeal(3, 1), isTrue);
    });

    test('impact intensity is floored and square-rooted', () {
      expect(
        HealthRules.impactIntensity(0, 10),
        EngineConstants.impactIntensityFloor,
      );
      expect(HealthRules.impactIntensity(10, 10), 1.0);
      expect(() => HealthRules.impactIntensity(1, 0), throwsArgumentError);
    });

    test('regeneration gates: rate, invulnerability, bounds', () {
      expect(
        HealthRules.shouldRegenerate(1, 3, 5, isInvulnerable: false),
        isTrue,
      );
      expect(
        HealthRules.shouldRegenerate(0, 3, 5, isInvulnerable: false),
        isFalse,
      );
      expect(
        HealthRules.shouldRegenerate(1, 3, 5, isInvulnerable: true),
        isFalse,
      );
      expect(
        HealthRules.shouldRegenerate(1, 5, 5, isInvulnerable: false),
        isFalse, // already full
      );
    });
  });

  group('VitalRegenRules', () {
    test('pays out only in whole steps, carrying the remainder', () {
      // 0.3/tick against a 0.5 step: pays 0.5 on the second tick.
      var (amount, acc) = VitalRegenRules.accumulateRegen(0.3, 1, 0, 0.5);
      expect(amount, 0.0);
      expect(acc, closeTo(0.3, 1e-9));

      (amount, acc) = VitalRegenRules.accumulateRegen(0.3, 1, acc, 0.5);
      expect(amount, 0.5);
      expect(acc, closeTo(0.1, 1e-9));
    });

    test('a non-positive step is a programming error', () {
      expect(
        () => VitalRegenRules.accumulateRegen(1, 1, 0, 0),
        throwsArgumentError,
      );
    });
  });
}
