import 'package:darkness_dungeon/gameplay/inventory/entities/inventory_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/usecases/add_item_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes using Mocktail (G2)
class MockInventoryManager extends Mock implements InventoryManager {}

class MockItemFactoryService extends Mock implements ItemFactoryService {}

// Fake class for Item fallback
class FakeItem extends Fake implements HandItem {}

void main() {
  setUpAll(() {
    // Register fallback for Item type (required by Mocktail)
    registerFallbackValue(FakeItem());
  });

  group('AddItemUseCase', () {
    late MockInventoryManager mockInventoryManager;
    late MockItemFactoryService mockItemFactory;
    late AddItemUseCase addItemUseCase;

    setUp(() {
      mockInventoryManager = MockInventoryManager();
      mockItemFactory = MockItemFactoryService();
      addItemUseCase = AddItemUseCase(mockInventoryManager, mockItemFactory);
    });

    test('should return false when quantity is zero or negative', () {
      // Arrange
      const itemId = HandItemType.sword;

      // Act & Assert
      expect(addItemUseCase(itemId, 0), false);
      expect(addItemUseCase(itemId, -1), false);

      // Verify no interaction with mocks
      verifyNever(() => mockItemFactory.createItem(any()));
      verifyNever(() => mockInventoryManager.updateSlot(any(), any()));
    });

    test('should return false when item does not exist', () {
      // Arrange
      const itemId = HandItemType.apple;
      when(() => mockItemFactory.createItem(itemId.name)).thenReturn(null);

      // Act
      final result = addItemUseCase(itemId, 1);

      // Assert
      expect(result, false);
      verify(() => mockItemFactory.createItem(itemId.name)).called(1);
      verifyNever(() => mockInventoryManager.updateSlot(any(), any()));
    });

    test('should add item to inventory when valid', () {
      // Arrange
      const itemId = HandItemType.ironSword;
      const quantity = 2;

      const mockItem = MainHandItem(
        id: HandItemType.ironSword,
        name: 'Iron Sword',
        description: 'A basic sword',
        baseValue: 100,
        iconPath: 'path/to/icon',
        damage: 10,
        equippedHandType: HandItemType.ironSword,
      );

      // Mock empty slots
      final emptySlots = List.generate(
        10,
        (index) => InventorySlot(index: index),
      );

      when(() => mockItemFactory.createItem(itemId.name)).thenReturn(mockItem);
      when(() => mockInventoryManager.slots).thenReturn(emptySlots);
      when(
        () => mockInventoryManager.updateSlot(any(), any()),
      ).thenReturn(null);

      // Act
      final result = addItemUseCase(itemId, quantity);

      // Assert
      expect(result, true);
      verify(() => mockItemFactory.createItem(itemId.name)).called(1);
      verify(() => mockInventoryManager.updateSlot(any(), any())).called(1);
    });

    test('should return false when inventory is full', () {
      // Arrange
      const itemId = HandItemType.sword;
      const quantity = 1;

      const mockItem = MainHandItem(
        id: HandItemType.sword,
        name: 'Iron Sword',
        description: 'A basic sword',
        baseValue: 100,
        iconPath: 'path/to/icon',
        damage: 10,
        equippedHandType: HandItemType.ironSword,
      );

      // Mock full slots (all slots have items)
      final fullSlots = List.generate(
        10,
        (index) => InventorySlot(index: index, item: mockItem, quantity: 1),
      );

      when(() => mockItemFactory.createItem(itemId.name)).thenReturn(mockItem);
      when(() => mockInventoryManager.slots).thenReturn(fullSlots);

      // Act
      final result = addItemUseCase(itemId, quantity);

      // Assert
      expect(result, false);
      verify(() => mockItemFactory.createItem(itemId.name)).called(1);
    });
  });
}
