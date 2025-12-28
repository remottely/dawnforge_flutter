import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/shield_defense_component.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_view.dart';

abstract class DDDefensePlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDCombatPlayerView<C, M> {
  DDDefensePlayerView({
    required super.config,
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.baseSpeed,
  });

  @override
  void update(double dt) {
    if (isDead) return;

    controller.update(dt);

    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDefending) {
      showDamage(
        0,
        config: const TextStyle(color: Color(0xFF00FFFF), fontSize: 12),
      );
      return;
    }

    super.onReceiveDamage(attacker, damage, id);
  }

  ShieldDefenseComponent? _defenseComponent;

  bool _isDefending = false;

  bool get isDefending => _isDefending;

  bool startShieldDefense() {
    return startDefense();
  }

  void stopShieldDefense() {
    stopDefense();
  }

  bool startDefense() {
    if (_isDefending) return true;

    // Check if player has a shield equipped in the main hand
    final mainHandItem = EquipmentManager.instance.getEquippedItem(
      EquipmentSlotType.mainHand,
    );

    if (mainHandItem == null || mainHandItem is! MainHandItem) {
      return false;
    }

    if (!mainHandItem.equippedHandType.isDefense) {
      return false;
    }

    _isDefending = true;

    if (_defenseComponent == null) {
      _defenseComponent = ShieldDefenseComponent(player: this);
      gameRef.add(_defenseComponent!);
    }

    _defenseComponent!.activate();

    return true;
  }

  void stopDefense() {
    if (!_isDefending) return;

    _stopDefenseInternal();
  }

  void _stopDefenseInternal() {
    _isDefending = false;

    if (_defenseComponent != null) {
      _defenseComponent!.deactivate();
      _defenseComponent!.removeFromParent();
      _defenseComponent = null;
    }
  }
}
