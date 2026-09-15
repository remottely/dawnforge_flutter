import 'package:dawnforge/src/core/domain/production/production_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5 slice 4: the tick arithmetic of a running batch.
void main() {
  test('progress is time over effective time', () {
    expect(ProductionRules.progressIncrement(0.5, 2), 0.25);
    expect(ProductionRules.progressIncrement(2, 2), 1);
  });

  test('a unit is complete at one, and not a hair before', () {
    expect(ProductionRules.isItemComplete(0.999), isFalse);
    expect(ProductionRules.isItemComplete(1), isTrue);
    expect(ProductionRules.isItemComplete(1.3), isTrue);
  });

  test('the unit on the bench counts from one, for a player', () {
    // Five ordered, five left: the first. Five ordered, one left: the fifth.
    expect(ProductionRules.currentItemNumber(5, 5), 1);
    expect(ProductionRules.currentItemNumber(5, 3), 3);
    expect(ProductionRules.currentItemNumber(5, 1), 5);
  });

  test('a batch is complete when nothing is left', () {
    expect(ProductionRules.isBatchComplete(1), isFalse);
    expect(ProductionRules.isBatchComplete(0), isTrue);
  });

  test('an allocated line cannot owe', () {
    expect(ProductionRules.reduceAllocatedAmount(10, 5), 5);
    expect(ProductionRules.reduceAllocatedAmount(3, 5), 0);
  });
}
