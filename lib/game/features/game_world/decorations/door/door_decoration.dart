import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/ui/ui_state_manager.dart';
import 'package:dawnforge/game/features/game_world/decorations/door/door_decoration_config.dart';
import 'package:dawnforge/game/features/game_world/decorations/door_key/door_key_decoration_config.dart';
import 'package:dawnforge/game/core/systems/ui/dialog/binary_choice_dialog.dart';
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';

class DoorDecorationView extends GameDecoration {
  bool _isOpen = false;
  bool _isShowingChoice = false;

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
    if (_isOpen || UIStateManager.instance.isShowingConversation) return;

    final keySlotIndex = _getSelectedKeySlotIndex();
    if (keySlotIndex != null) {
      _showKeyFlow(player, keySlotIndex);
    } else {
      _showKeyRequiredMessage(player);
    }
  }

  int? _getSelectedKeySlotIndex() {
    final selectedIndex = EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);

    if (slot == null || slot.item == null) return null;

    final isKeySelected = slot.item!.id == DoorKeyDecorationDef.kItemId;
    final hasQuantity = slot.quantity > 0;
    return isKeySelected && hasQuantity ? selectedIndex : null;
  }

  void _consumeKey(int slotIndex) {
    InventoryManager.instance.consumeFromSlot(slotIndex, 1);
  }

  void _showKeyFlow(Player player, int slotIndex) {
    final slot = InventoryManager.instance.getSlotByIndex(slotIndex);
    final itemName = slot?.item?.name ?? 'dungeon_key';

    UIStateManager.instance.isShowingConversation = true;
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence:
          DoorDecorationDef.createConversationSequenceWithKey(),
      onCloseConversation: () {
        UIStateManager.instance.isShowingConversation = false;
        if (_isShowingChoice) return;
        // Defer to next microtask/frame to avoid Navigator lock during TalkDialog dispose
        Future.microtask(() {
          if (!_isShowingChoice) {
            _showUseKeyConfirmation(itemName: itemName, slotIndex: slotIndex);
          }
        });
      },
    );
  }

  Future<void> _showUseKeyConfirmation({
    required String itemName,
    required int slotIndex,
  }) async {
    _isShowingChoice = true;
    final result = await BinaryChoiceDialog.show(
      context: gameRef.context,
      question: 'Use $itemName to open?',
      yesLabel: 'Yes',
      noLabel: 'No',
    );

    _isShowingChoice = false;

    if (result == true) {
      _consumeKey(slotIndex);
      _triggerDoorOpening();
    }
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
