// import 'package:dawnforge/features/inventory/entities/equipment_slot.dart';
// import 'package:dawnforge/features/inventory/managers/equipment_manager.dart';
// import 'package:dawnforge/features/inventory/managers/inventory_manager.dart';
// import 'package:dawnforge/features/inventory/config/inventory_service_locator.dart';
// import 'package:dawnforge/features/inventory/items/main_hand_item.dart';
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

//   group('EquipmentManager Tests', () {
//     test('initial_state_all_slots_empty', () {
//       for (final slotType in EquipmentSlotType.values) {
//         expect(EquipmentManager.instance.isSlotOccupied(slotType), isFalse);
//         expect(EquipmentManager.instance.getEquippedItem(slotType), isNull);
//       }
//     });

//     test('equip_weapon_success', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);

//       final result = EquipmentManager.instance.equip(
//         EquipmentSlotType.mainHand,
//         sword,
//       );

//       expect(result, isTrue);
//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isTrue,
//       );
//       expect(
//         EquipmentManager.instance.getEquippedItem(EquipmentSlotType.mainHand),
//         equals(sword),
//       );
//       expect(InventoryManager.instance.hasItem('iron_sword'), isFalse);
//     });

//     test('equip_returns_false_when_item_not_in_inventory', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;

//       final result = EquipmentManager.instance.equip(
//         EquipmentSlotType.mainHand,
//         sword,
//       );

//       expect(result, isFalse);
//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isFalse,
//       );
//     });

//     test('equip_returns_false_for_wrong_slot_type', () {
//       final wood = getIt<ItemFactoryService>().createItem('wood')!;
//       InventoryManager.instance.addItem(wood);

//       final result = EquipmentManager.instance.equip(
//         EquipmentSlotType.mainHand,
//         wood,
//       );

//       expect(result, isFalse);
//       expect(InventoryManager.instance.hasItem('wood'), isTrue);
//     });

//     test('equip_replaces_existing_item', () {
//       final sword1 = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final sword2 = getIt<ItemFactoryService>().createItem('steel_axe')!;

//       InventoryManager.instance.addItem(sword1);
//       InventoryManager.instance.addItem(sword2);

//       // Equipar primeira espada
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword1);
//       expect(
//         EquipmentManager.instance
//             .getEquippedItem(EquipmentSlotType.mainHand)
//             ?.id,
//         equals('iron_sword'),
//       );

//       // Equipar segunda espada (deve trocar)
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword2);
//       expect(
//         EquipmentManager.instance
//             .getEquippedItem(EquipmentSlotType.mainHand)
//             ?.id,
//         equals('steel_axe'),
//       );
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
//       expect(InventoryManager.instance.hasItem('steel_axe'), isFalse);
//     });

//     test('unequip_returns_item_to_inventory', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final unequippedItem = EquipmentManager.instance.unequip(
//         EquipmentSlotType.mainHand,
//       );

//       expect(unequippedItem, isNotNull);
//       expect(unequippedItem?.id, equals('iron_sword'));
//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isFalse,
//       );
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
//     });

//     test('unequip_returns_null_when_slot_empty', () {
//       final result = EquipmentManager.instance.unequip(
//         EquipmentSlotType.mainHand,
//       );
//       expect(result, isNull);
//     });

//     test('unequip_returns_null_when_inventory_full', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final stone = getIt<ItemFactoryService>().createItem('stone')!;

//       // Equipar espada primeiro
//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // Encher inventário com itens empilháveis
//       for (var i = 0; i < 30; i++) {
//         InventoryManager.instance.addItem(stone, 999);
//       }

//       // Tentar desequipar (inventário cheio)
//       final result = EquipmentManager.instance.unequip(
//         EquipmentSlotType.mainHand,
//       );
//       expect(result, isNull);
//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isTrue,
//       );
//     });

//     test('get_all_equipped_items_returns_all', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final axe = getIt<ItemFactoryService>().createItem('steel_axe')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(axe);

//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final equipped = EquipmentManager.instance.getAllEquippedItems();
//       expect(equipped.length, equals(1));
//       expect(equipped.any((item) => item.id == 'iron_sword'), isTrue);
//     });

//     test('get_total_damage_sums_weapons', () {
//       final sword =
//           getIt<ItemFactoryService>().createItem('iron_sword')! as MainHandItem;

//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final totalDamage = EquipmentManager.instance.getTotalDamage();
//       expect(totalDamage, equals(sword.damage));
//     });

//     test('get_total_dps_sums_weapons', () {
//       final sword =
//           getIt<ItemFactoryService>().createItem('iron_sword')! as MainHandItem;

//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final totalDps = EquipmentManager.instance.getTotalDps();
//       expect(totalDps, closeTo(sword.dps, 0.1));
//     });

//     test('get_total_stats_returns_all_stats', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final stats = EquipmentManager.instance.getTotalStats();
//       expect(stats['damage'], greaterThan(0));
//       expect(stats['dps'], greaterThan(0));
//       expect(stats['defense'], equals(0)); // Não há armadura ainda
//     });

//     test('unequip_all_moves_all_items_to_inventory', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final axe = getIt<ItemFactoryService>().createItem('steel_axe')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(axe);

//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       final result = EquipmentManager.instance.unequipAll();
//       expect(result, isTrue);

//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
//       expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
//       expect(InventoryManager.instance.hasItem('steel_axe'), isTrue);
//     });

//     test('unequip_all_fails_when_inventory_full', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final stone = getIt<ItemFactoryService>().createItem('stone')!;

//       // Equipar espada
//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // Encher inventário completamente
//       for (var i = 0; i < 30; i++) {
//         InventoryManager.instance.addItem(stone, 999);
//       }

//       final result = EquipmentManager.instance.unequipAll();
//       expect(result, isFalse);
//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isTrue,
//       );
//     });

//     test('serialization_roundtrip', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       final axe = getIt<ItemFactoryService>().createItem('steel_axe')!;

//       InventoryManager.instance.addItem(sword);
//       InventoryManager.instance.addItem(axe);

//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       // Serializar
//       final json = EquipmentManager.instance.toJson();
//       expect(json['equipmentSlots'], isNotEmpty);

//       // Resetar e restaurar
//       EquipmentManager.instance.reset();
//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);

//       EquipmentManager.instance.fromJson(json);

//       // Verificar que foi restaurado
//       expect(
//         EquipmentManager.instance
//             .getEquippedItem(EquipmentSlotType.mainHand)
//             ?.id,
//         equals('iron_sword'),
//       );
//     });

//     test('weapon_can_be_equipped_in_weapon_slot', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);

//       final result = EquipmentManager.instance.equip(
//         EquipmentSlotType.mainHand,
//         sword,
//       );
//       expect(result, isTrue);
//     });

//     test('offhand_slot_is_locked', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);

//       final result = EquipmentManager.instance.equip(
//         EquipmentSlotType.offHand,
//         sword,
//       );

//       expect(result, isFalse);
//     });

//     test('reset_clears_all_equipment', () {
//       final sword = getIt<ItemFactoryService>().createItem('iron_sword')!;
//       InventoryManager.instance.addItem(sword);
//       EquipmentManager.instance.equip(EquipmentSlotType.mainHand, sword);

//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isTrue,
//       );

//       EquipmentManager.instance.reset();

//       expect(
//         EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.mainHand),
//         isFalse,
//       );
//       expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
//     });
//   });
// }
