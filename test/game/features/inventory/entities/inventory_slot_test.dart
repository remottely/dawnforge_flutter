import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/inventory_slot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_builders.dart';

void main() {
  group('InventorySlot', () {
    group('emptiness', () {
      test('no item → empty', () {
        expect(aSlot().isEmpty, isTrue);
      });

      test('item present but quantity zero → still empty', () {
        expect(aSlot(item: anItem(), quantity: 0).isEmpty, isTrue);
      });

      test('item with quantity → occupied', () {
        final slot = aSlot(item: anItem(), quantity: 1);

        expect(slot.isEmpty, isFalse);
        expect(slot.isOccupied, isTrue);
      });
    });

    group('isFull', () {
      test('quantity at max stack → full', () {
        final slot = aSlot(item: anItem(maxStackSize: 10), quantity: 10);

        expect(slot.isFull, isTrue);
      });

      test('below max stack → not full', () {
        final slot = aSlot(item: anItem(maxStackSize: 10), quantity: 9);

        expect(slot.isFull, isFalse);
      });

      test('empty slot → not full', () {
        expect(aSlot().isFull, isFalse);
      });

      test('non-stackable item with one unit → full', () {
        final slot = aSlot(item: aNonStackableItem(), quantity: 1);

        expect(slot.isFull, isTrue);
      });
    });

    group('canAddItem', () {
      test('empty slot accepts anything', () {
        expect(aSlot().canAddItem(anItem(), 50), isTrue);
      });

      test('different item id → rejected', () {
        final slot = aSlot(item: anItem(id: HandItemId.wood), quantity: 1);

        expect(slot.canAddItem(anItem(id: HandItemId.stone), 1), isFalse);
      });

      test('same id but non-stackable → rejected', () {
        final tool = aNonStackableItem();
        final slot = aSlot(item: tool, quantity: 1);

        expect(slot.canAddItem(tool, 1), isFalse);
      });

      test('would exceed the stack → rejected', () {
        final item = anItem(maxStackSize: 10);
        final slot = aSlot(item: item, quantity: 8);

        expect(slot.canAddItem(item, 3), isFalse);
      });

      test('exactly fills the stack → accepted', () {
        final item = anItem(maxStackSize: 10);
        final slot = aSlot(item: item, quantity: 8);

        expect(slot.canAddItem(item, 2), isTrue);
      });
    });

    group('addQuantity', () {
      test('increases the quantity', () {
        final slot = aSlot(item: anItem(), quantity: 3);

        expect(slot.addQuantity(4).quantity, 7);
      });

      test('clamps at the max stack size', () {
        final slot = aSlot(item: anItem(maxStackSize: 10), quantity: 8);

        expect(slot.addQuantity(50).quantity, 10);
      });

      test('empty slot → unchanged (no item to stack onto)', () {
        final slot = aSlot();

        expect(slot.addQuantity(5), same(slot));
      });

      test('keeps the slot index', () {
        final slot = aSlot(index: 7, item: anItem(), quantity: 1);

        expect(slot.addQuantity(1).index, 7);
      });
    });

    group('removeQuantity', () {
      test('decreases the quantity', () {
        final slot = aSlot(item: anItem(), quantity: 5);

        expect(slot.removeQuantity(2).quantity, 3);
      });

      test('removing everything empties the slot', () {
        final slot = aSlot(index: 3, item: anItem(), quantity: 5);

        final emptied = slot.removeQuantity(5);

        expect(emptied.isEmpty, isTrue);
        expect(emptied.item, isNull);
        expect(emptied.index, 3);
      });

      test('removing more than available also empties the slot', () {
        final slot = aSlot(item: anItem(), quantity: 2);

        expect(slot.removeQuantity(99).isEmpty, isTrue);
      });

      test('empty slot → unchanged', () {
        final slot = aSlot();

        expect(slot.removeQuantity(1), same(slot));
      });
    });

    group('serialization', () {
      test('round-trips through a resolver', () {
        final item = anItem(id: HandItemId.wood);
        final slot = aSlot(index: 2, item: item, quantity: 5);

        final restored = InventorySlot.fromJson(
          slot.toJson(),
          (id) => id == HandItemId.wood ? item : null,
        );

        expect(restored.index, 2);
        expect(restored.quantity, 5);
        expect(restored.item?.id, HandItemId.wood);
      });

      test('empty slot serializes a null item id', () {
        final json = aSlot(index: 1).toJson();

        expect(json['itemId'], isNull);
        expect(json['quantity'], 0);
      });

      test('resolver returning null → slot restored without item', () {
        final slot = aSlot(index: 0, item: anItem(), quantity: 3);

        final restored = InventorySlot.fromJson(slot.toJson(), (_) => null);

        expect(restored.item, isNull);
        expect(restored.isEmpty, isTrue);
      });

      test('missing quantity defaults to zero', () {
        final restored = InventorySlot.fromJson(<String, dynamic>{
          'index': 0,
          'itemId': null,
        }, (_) => null);

        expect(restored.quantity, 0);
      });
    });

    group('equality', () {
      test('same index, item and quantity → equal', () {
        final item = anItem();

        expect(
          aSlot(index: 1, item: item, quantity: 2),
          aSlot(index: 1, item: item, quantity: 2),
        );
      });

      test('different quantity → not equal', () {
        final item = anItem();

        expect(
          aSlot(index: 1, item: item, quantity: 2),
          isNot(aSlot(index: 1, item: item, quantity: 3)),
        );
      });
    });
  });

  group('HandItem', () {
    test('maxStackSize above one → stackable', () {
      expect(anItem(maxStackSize: 99).isStackable, isTrue);
    });

    test('maxStackSize of one → not stackable', () {
      expect(anItem(maxStackSize: 1).isStackable, isFalse);
    });

    group('sellValue', () {
      test('normal quality → base value unchanged', () {
        expect(anItem(baseValue: 100).sellValue, 100);
      });

      test('applies the quality multiplier and rounds', () {
        final item = anItem(baseValue: 33, quality: HandItemQuality.silver);

        expect(item.sellValue, 41); // 33 * 1.25 = 41.25 → 41
      });

      test('iridium doubles the base value', () {
        final item = anItem(baseValue: 50, quality: HandItemQuality.iridium);

        expect(item.sellValue, 100);
      });
    });
  });
}
