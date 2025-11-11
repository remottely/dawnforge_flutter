import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Implementação concreta para testes
class TestEnemyModel extends DDBaseEnemyModel {
  TestEnemyModel({
    required super.primaryAttackDamage,
    required super.closeVisionRadius,
    required super.primaryAttackInterval,
  });
}

void main() {
  group('DDBaseEnemyModel', () {
    late TestEnemyModel model;

    setUp(() {
      model = TestEnemyModel(
        closeVisionRadius: 100.0,
        primaryAttackDamage: 25.0,
        primaryAttackInterval: 500,
      );
    });

    group('Initialization', () {
      test('should initialize with correct values', () {
        expect(model.primaryAttackDamage, equals(25.0));
        expect(model.closeVisionRadius, equals(100.0));
        expect(model.primaryAttackInterval, equals(500));
      });
    });

    group('Edge Cases', () {
      test('should handle zero attack damage', () {
        final zeroModel = TestEnemyModel(
          closeVisionRadius: 100.0,
          primaryAttackDamage: 0.0,
          primaryAttackInterval: 500,
        );
        expect(zeroModel.primaryAttackDamage, equals(0.0));
      });

      test('should handle very large vision radius', () {
        final largeVisionModel = TestEnemyModel(
          closeVisionRadius: 10000.0,
          primaryAttackDamage: 25.0,
          primaryAttackInterval: 500,
        );
        expect(largeVisionModel.closeVisionRadius, equals(10000.0));
      });

      test('should handle very short attack interval', () {
        final fastAttackModel = TestEnemyModel(
          closeVisionRadius: 100.0,
          primaryAttackDamage: 25.0,
          primaryAttackInterval: 1,
        );
        expect(fastAttackModel.primaryAttackInterval, equals(1));
      });
    });
  });
}
