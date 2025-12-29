import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/usecases/add_item_use_case.dart';

// Mock classes using Mocktail (G2)
class MockInventoryManager extends Mock implements InventoryManager {}

class MockItemFactoryService extends Mock implements ItemFactoryService {}

// Fake class for Item fallback
class FakeItem extends Fake implements Item {}

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
      const itemId = 'sword';

      // Act & Assert
      expect(addItemUseCase(itemId, 0), false);
      expect(addItemUseCase(itemId, -1), false);

      // Verify no interaction with mocks
      verifyNever(() => mockItemFactory.createItem(any()));
      verifyNever(() => mockInventoryManager.addItem(any(), any()));
    });

    test('should return false when item does not exist', () {
      // Arrange
      const itemId = 'nonexistent_item';
      when(() => mockItemFactory.createItem(itemId)).thenReturn(null);

      // Act
      final result = addItemUseCase(itemId, 1);

      // Assert
      expect(result, false);
      verify(() => mockItemFactory.createItem(itemId)).called(1);
      verifyNever(() => mockInventoryManager.addItem(any(), any()));
    });

    test('should add item to inventory when valid', () {
      // Arrange
      const itemId = 'sword';
      const quantity = 2;

      const mockItem = MainHandItem(
        id: 'sword',
        name: 'Iron Sword',
        description: 'A basic sword',
        baseValue: 100,
        iconPath: 'path/to/icon',
        damage: 10,
        equippedHandType: EquippedHandType.ironSword,
      );

      when(() => mockItemFactory.createItem(itemId)).thenReturn(mockItem);
      when(() => mockInventoryManager.addItem(mockItem, quantity))
          .thenReturn(true);

      // Act
      final result = addItemUseCase(itemId, quantity);

      // Assert
      expect(result, true);
      verify(() => mockItemFactory.createItem(itemId)).called(1);
      verify(() => mockInventoryManager.addItem(mockItem, quantity)).called(1);
    });

    test('should return false when inventory is full', () {
      // Arrange
      const itemId = 'sword';
      const quantity = 1;

      const mockItem = MainHandItem(
        id: 'sword',
        name: 'Iron Sword',
        description: 'A basic sword',
        baseValue: 100,
        iconPath: 'path/to/icon',
        damage: 10,
        equippedHandType: EquippedHandType.ironSword,
      );

      when(() => mockItemFactory.createItem(itemId)).thenReturn(mockItem);
      when(() => mockInventoryManager.addItem(mockItem, quantity))
          .thenReturn(false);

      // Act
      final result = addItemUseCase(itemId, quantity);

      // Assert
      expect(result, false);
      verify(() => mockItemFactory.createItem(itemId)).called(1);
      verify(() => mockInventoryManager.addItem(mockItem, quantity)).called(1);
    });
  });
}
