import 'dart:math' as math;

import 'package:dawnforge/src/core/domain/production/drop_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropRules', () {
    test('shouldRoll is inclusive at the chance boundary', () {
      expect(DropRules.shouldRoll(0.5, 0.5), isTrue);
      expect(DropRules.shouldRoll(0.500001, 0.5), isFalse);
      expect(DropRules.shouldRoll(0, 0.01), isTrue);
    });

    test('calculateAmount pays the fractional remainder probabilistically',
        () {
      // 1 × 1.5: the roll settles the half — never a silent floor back to 1.
      expect(DropRules.calculateAmount(1, 1.5, 0.4), 2);
      expect(DropRules.calculateAmount(1, 1.5, 0.6), 1);

      // A whole product ignores the roll entirely.
      expect(DropRules.calculateAmount(3, 2, 0), 6);
      expect(DropRules.calculateAmount(3, 2, 0.999), 6);
      expect(DropRules.calculateAmount(2, 1.5, 0.999), 3);

      // The neutral multiplier is exact, and a zero multiplier yields zero.
      expect(DropRules.calculateAmount(1, 1, 0.999), 1);
      expect(DropRules.calculateAmount(5, 0, 0.999), 0);
    });

    test('calculateSpreadPosition walks the angle by the distance', () {
      final east = DropRules.calculateSpreadPosition(WorldPos.zero, 0, 10);
      expect(east.x, closeTo(10, 1e-9));
      expect(east.y, closeTo(0, 1e-9));

      final south =
          DropRules.calculateSpreadPosition(WorldPos.zero, math.pi / 2, 10);
      expect(south.x, closeTo(0, 1e-9));
      expect(south.y, closeTo(10, 1e-9));
    });

    test('workstationDropPosition anchors at the front-center face', () {
      // A 2×1 workstation at origin, 16px tiles: the face midpoint is
      // (8, 16) — produce lands in front of it, never on its anchor tile.
      final anchor = DropRules.workstationDropPosition(
        WorldPos.zero,
        2,
        1,
        16,
        0,
        0,
      );
      expect(anchor.x, closeTo(8, 1e-9));
      expect(anchor.y, closeTo(16, 1e-9));
    });

    test('gridOffsetPosition scales with the footprint beyond one tile', () {
      final offset = DropRules.gridOffsetPosition(WorldPos.zero, 3, 2, 8);
      expect(offset.x, closeTo(16, 1e-9));
      expect(offset.y, closeTo(8, 1e-9));

      // A 1×1 prop drops at its own anchor.
      final anchor = DropRules.gridOffsetPosition(WorldPos.zero, 1, 1, 8);
      expect(anchor.x, closeTo(0, 1e-9));
      expect(anchor.y, closeTo(0, 1e-9));
    });
  });
}
