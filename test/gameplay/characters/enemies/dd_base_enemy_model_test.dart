import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Implementação concreta para testes
class TestEnemyModel extends DDBaseEnemyModel {
  TestEnemyModel({
    required super.attackDamage,
    required super.visionRadius,
    required super.attackInterval,
  });
}

void main() {
  group('DDBaseEnemyModel', () {
    late TestEnemyModel model;

    setUp(() {
      model = TestEnemyModel(
        attackDamage: 25.0,
        visionRadius: 100.0,
        attackInterval: 500,
      );
    });

    group('Initialization', () {
      test('should initialize with correct values', () {
        expect(model.attackDamage, equals(25.0));
        expect(model.visionRadius, equals(100.0));
        expect(model.attackInterval, equals(500));
      });
    });

    group('Property Mutations', () {
      test('should allow attackDamage to be modified', () {
        model.attackDamage = 50.0;
        expect(model.attackDamage, equals(50.0));
      });

      test('should allow visionRadius to be modified', () {
        model.visionRadius = 200.0;
        expect(model.visionRadius, equals(200.0));
      });

      test('should allow attackInterval to be modified', () {
        model.attackInterval = 1000;
        expect(model.attackInterval, equals(1000));
      });
    });

    group('Edge Cases', () {
      test('should handle zero attack damage', () {
        final zeroModel = TestEnemyModel(
          attackDamage: 0.0,
          visionRadius: 100.0,
          attackInterval: 500,
        );
        expect(zeroModel.attackDamage, equals(0.0));
      });

      test('should handle very large vision radius', () {
        final largeVisionModel = TestEnemyModel(
          attackDamage: 25.0,
          visionRadius: 10000.0,
          attackInterval: 500,
        );
        expect(largeVisionModel.visionRadius, equals(10000.0));
      });

      test('should handle very short attack interval', () {
        final fastAttackModel = TestEnemyModel(
          attackDamage: 25.0,
          visionRadius: 100.0,
          attackInterval: 1,
        );
        expect(fastAttackModel.attackInterval, equals(1));
      });
    });
  });
}
