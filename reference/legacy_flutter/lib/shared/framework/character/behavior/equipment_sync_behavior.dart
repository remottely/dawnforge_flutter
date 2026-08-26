// lib/shared/framework/character/behavior/equipment_sync_behavior.dart
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

/// Behavior que sincroniza CharacterData.equippedItemId com EquipmentManager
class EquipmentSyncBehavior extends CharacterBehavior {
  late EquipmentManager _equipmentManager;

  @override
  void onAttach() {
    super.onAttach();
    _equipmentManager = EquipmentManager.instance;

    // Escuta mudanças no equipamento
    _equipmentManager.selectedSlotIndexNotifier.addListener(
      _onEquipmentChanged,
    );

    // Sincroniza inicial
    _syncEquipment();
  }

  void _onEquipmentChanged() {
    _syncEquipment();
  }

  void _syncEquipment() {
    final equippedItem = _equipmentManager.getEquippedItem();
    character.data.setEquipment(equippedItem?.id);
  }

  @override
  void dispose() {
    _equipmentManager.selectedSlotIndexNotifier.removeListener(
      _onEquipmentChanged,
    );
    super.dispose();
  }
}
