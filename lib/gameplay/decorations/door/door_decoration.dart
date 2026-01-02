import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/decorations/door/door_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key/door_key_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';

class DoorDecorationView extends GameDecoration {
  bool _isOpen = false;

  DoorDecorationView({required super.position, required super.size})
    : super.withSprite(sprite: DoorDecorationDef.loadSpriteClosed());

  @override
  Future<void> onLoad() {
    add(DoorDecorationDef.createHitbox(this));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is SimplePlayer) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _handlePlayerCollision(SimplePlayer player) {
    if (_isOpen) return;

    final keySlotIndex = _getSelectedKeySlotIndex();
    if (keySlotIndex != null) {
      _consumeKey(keySlotIndex);
      _triggerDoorOpening();
    } else {
      _showKeyRequiredMessage(player);
    }
  }

  int? _getSelectedKeySlotIndex() {
    final selectedIndex =
        getIt<EquipmentManager>().currentMainHandSlotIndex;
    final slot = getIt<InventoryManager>().getSlotByIndex(selectedIndex);

    if (slot == null || slot.item == null) return null;

    final isKeySelected = slot.item!.id == DoorKeyDecorationDef.kItemId;
    final hasQuantity = slot.quantity > 0;
    return isKeySelected && hasQuantity ? selectedIndex : null;
  }

  void _consumeKey(int slotIndex) {
    final slot = getIt<InventoryManager>().getSlotByIndex(slotIndex);
    if (slot == null) return;
    getIt<InventoryManager>().updateSlot(slotIndex, slot.removeQuantity(1));
  }

  void _triggerDoorOpening() {
    _isOpen = true;
    _playAnimationDoorOpening();
  }

  void _playAnimationDoorOpening() {
    playSpriteAnimationOnce(
      DoorDecorationDef.loadAnimationOpening(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  void _showKeyRequiredMessage(Player player) {
    if (!UIStateManager.instance.isShowingConversation) {
      UIStateManager.instance.isShowingConversation = true;
      _showConversation(player);
    }
  }

  void _showConversation(Player player) {
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: DoorDecorationDef.createConversationSequence(),
      onCloseConversation: () {
        UIStateManager.instance.isShowingConversation = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
