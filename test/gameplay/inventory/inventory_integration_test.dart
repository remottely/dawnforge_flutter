// import 'package:dawnforge/features/core/modules/save/game_state_collector.dart';
// import 'package:dawnforge/features/inventory/entities/equipment_slot.dart';
// import 'package:dawnforge/features/inventory/managers/equipment_manager.dart';
// import 'package:dawnforge/features/inventory/managers/inventory_manager.dart';
// import 'package:dawnforge/features/inventory/config/inventory_service_locator.dart';
// import 'package:dawnforge/features/inventory/services/item_factory_service.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     await getIt<ItemFactoryService>().initialize();
//   });

//   setUp(() {
//     InventoryManager.instance.reset();
//     EquipmentManager.instance.reset();
//   });

//   group('Inventory Integration Tests', () {
//     test('complete_save_load_cycle_with_inventory', () {
//       // 1. Adicionar itens ao inventário
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final axe = getIt<ItemFactoryService>().createItem('steel_axe')!;
//       final potion = getIt<ItemFactoryService>().createItem('health_potion')!;
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;
//       final seeds = getIt<ItemFactoryService>().createItem('tomato_seeds')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(axe);
//       InventoryManager.instance.addItem(potion, 10);
//       InventoryManager.instance.addItem(wood, 250);
//       InventoryManager.instance.addItem(seeds, 20);

//       // 2. Equipar itens
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // 3. Coletar estado do jogo
//       final saveData = GameStateCollector.collectCurrentGameState();

//       // 4. Verificar que dados do inventário foram coletados
//       expect(saveData.inventoryData.isNotEmpty, isTrue);
//       expect(saveData.inventoryData['inventory'], isNotNull);
//       expect(saveData.inventoryData['equipment'], isNotNull);

//       // 5. Resetar managers
//       InventoryManager.instance.reset();
//       EquipmentManager.instance.reset();

//       expect(InventoryManager.instance.usedSlots, equals(0));
//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);

//       // 6. Restaurar estado
//       final restored = GameStateCollector.restoreGameState(saveData);
//       expect(restored, isTrue); // 7. Verificar inventário restaurado
//       expect(InventoryManager.instance.hasItem('health_potion', 10), isTrue);
//       expect(InventoryManager.instance.getItemQuantity('wood'), equals(250));
//       expect(
//         InventoryManager.instance.getItemQuantity('tomato_seeds'),
//         equals(20),
//       );

//       // 8. Verificar equipamentos restaurados
//       expect(
//         EquipmentManager.instance
//             .getEquippedItem(EquipmentSlotType.mainHand)
//             ?.id,
//         equals('iron_sword'),
//       );

//       // 9. Verificar stats calculados
//       expect(EquipmentManager.instance.getTotalDamage(), greaterThan(0));
//       expect(EquipmentManager.instance.getTotalDps(), greaterThan(0));
//     });

//     test('serialization_roundtrip_with_full_inventory', () {
//       // Encher inventário com vários itens (12 slots = kDefaultInventorySize)
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;
//       final stone = getIt<ItemFactoryService>().createItem('stone')!;
//       final iron = getIt<ItemFactoryService>().createItem('iron_ore')!;

//       // Adicionar 4 slots de cada item (4*3 = 12 slots total)
//       for (var i = 0; i < 4; i++) {
//         InventoryManager.instance.addItem(wood, 999);
//       }
//       for (var i = 0; i < 4; i++) {
//         InventoryManager.instance.addItem(stone, 999);
//       }
//       for (var i = 0; i < 4; i++) {
//         InventoryManager.instance.addItem(iron, 999);
//       }

//       // Coletar e restaurar
//       final saveData = GameStateCollector.collectCurrentGameState();
//       InventoryManager.instance.reset();
//       GameStateCollector.restoreGameState(saveData);

//       // Verificar totais (4 slots * 999 cada = 3996 por item)
//       expect(InventoryManager.instance.getItemQuantity('wood'), equals(3996));
//       expect(InventoryManager.instance.getItemQuantity('stone'), equals(3996));
//       expect(
//         InventoryManager.instance.getItemQuantity('iron_ore'),
//         equals(3996),
//       );
//       expect(InventoryManager.instance.usedSlots, equals(12)); // Full inventory
//     });

//     test('equipment_persists_across_save_load', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final axe = getIt<ItemFactoryService>().createItem('steel_axe')!;
//       final legendary = getIt<ItemFactoryService>().createItem(
//         'legendary_blade',
//       )!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(axe);
//       InventoryManager.instance.addItem(legendary);

//       // Equipar todos
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // Trocar weapon
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, legendary);

//       // Capturar damage antes do save
//       final damageBeforeSave = EquipmentManager.instance.getTotalDamage();

//       // Save/Load
//       final saveData = GameStateCollector.collectCurrentGameState();
//       GameStateCollector.resetAllManagers();
//       GameStateCollector.restoreGameState(saveData);

//       // Verificar que legendary está equipado (não sword)
//       expect(
//         EquipmentManager.instance
//             .getEquippedItem(EquipmentSlotType.mainHand)
//             ?.id,
//         equals('legendary_blade'),
//       );

//       // Verificar que sword voltou para inventário
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);

//       // Verificar que damage foi restaurado corretamente
//       expect(
//         EquipmentManager.instance.getTotalDamage(),
//         equals(damageBeforeSave),
//       );
//     });

//     test('empty_inventory_saves_and_loads_correctly', () {
//       // Inventário vazio
//       final saveData = GameStateCollector.collectCurrentGameState();

//       // Adicionar algo
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;
//       InventoryManager.instance.addItem(wood, 100);

//       // Restaurar estado vazio
//       GameStateCollector.restoreGameState(saveData);

//       // Deve estar vazio
//       expect(InventoryManager.instance.usedSlots, equals(0));
//       expect(InventoryManager.instance.hasItem('wood'), isFalse);
//     });

//     test('concurrent_inventory_equipment_operations', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final potion = getIt<ItemFactoryService>().createItem('health_potion')!;

//       // Adicionar e equipar simultaneamente
//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(potion, 5);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // Verificar que sword saiu do inventário
//       expect(InventoryManager.instance.hasItem('iron_sword'), isFalse);

//       // Desequipar
//       EquipmentManager.instance.unequip(EquipmentSlotType.mainHand);

//       // Verificar que voltou
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);

//       // Save/Load neste estado
//       final saveData = GameStateCollector.collectCurrentGameState();
//       GameStateCollector.resetAllManagers();
//       GameStateCollector.restoreGameState(saveData);

//       // Ambos devem estar no inventário
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
//       expect(InventoryManager.instance.hasItem('health_potion', 5), isTrue);
//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
//     });

//     test('game_state_summary_includes_inventory', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(wood, 100);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final summary = GameStateCollector.getCurrentStateSummary();

//       // Verificar que summary inclui informações do inventário
//       expect(summary.contains('Inventory Slots Used'), isTrue);
//       expect(summary.contains('Equipment Slots Used'), isTrue);
//       expect(summary.contains('Total Damage'), isTrue);
//       expect(summary.contains('Total DPS'), isTrue);
//     });

//     test('reset_all_managers_clears_inventory_and_equipment', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(wood, 500);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       expect(InventoryManager.instance.usedSlots, greaterThan(0));
//       expect(
//         EquipmentManager.instance.getAllEquippedItems().isNotEmpty,
//         isTrue,
//       );

//       GameStateCollector.resetAllManagers();

//       expect(InventoryManager.instance.usedSlots, equals(0));
//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
//     });

//     test('invalid_inventory_data_handled_gracefully', () {
//       // Criar save data com inventoryData inválido
//       final saveData = GameStateCollector.collectCurrentGameState();

//       // Criar cópia com dados inválidos
//       final invalidSaveData = saveData.copyWith(
//         inventoryData: {
//           'inventory': {'invalid': 'data'},
//           'equipment': {'corrupted': true},
//         },
//       );

//       // Não deve causar crash
//       final restored = GameStateCollector.restoreGameState(invalidSaveData);

//       // Pode ter sucesso parcial (outros managers OK)
//       // Mas inventário deve estar vazio ou resetado
//       // (comportamento específico depende da implementação do fromJson)
//       expect(restored, isNotNull);
//     });
//   });
// }
