import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_view.dart';

/// Abstract view for players with dual-hand equipment system.
///
/// Extends hybrid combat player to add equipment management through a
/// dual-hand system. This class coordinates combat actions with equipped
/// items, delegating attack execution to the appropriate hand/item based
/// on the attack trigger type.
///
/// Features:
/// - Dual-hand equipment management (left/right slots)
/// - Attack routing through equipment system
/// - Equipment-based combat execution
/// - Customizable equipment loadouts
///
/// Type Parameters:
/// - [C] The specific controller type extending DDHybridCombatPlayerController
/// - [M] The specific model type extending DDHybridCombatPlayerModel
abstract class DDEquippablePlayerView<
  C extends DDHybridCombatPlayerController<M>,
  M extends DDHybridCombatPlayerModel
>
    extends DDHybridCombatPlayerView<C, M> {
  final KnightHandLoadoutSetup _equipmentLoadout;
  late final KnightHandManager _handEquipmentManager = KnightHandManager(
    owner: this,
  );

  DDEquippablePlayerView({
    required super.position,
    required super.model,
    required super.animation,
    required super.size,
    required super.life,
    required super.speed,
    required KnightHandLoadoutSetup equipmentLoadout,
  }) : _equipmentLoadout = equipmentLoadout;

  // ============================================================================
  // Lifecycle Override - Equipment Initialization
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _handEquipmentManager.applyLoadout(_equipmentLoadout);
  }

  @override
  void update(double dt) {
    if (isDead) return;

    // Update controller (handles stamina regen, enemy detection)
    controller.update(dt);

    // Update equipment system
    _handEquipmentManager.update(dt, velocity);

    // Call parent update (handles movement and other SimplePlayer logic)
    super.update(dt);
  }

  @override
  void onRemove() {
    _handEquipmentManager.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Public Equipment API
  // ============================================================================

  /// Retrieves the hand item controller for the specified hand slot.
  ///
  /// Allows external systems to interact with or query equipped items
  /// in either the left or right hand.
  ///
  /// [slot] The hand slot to query (left or right).
  ///
  /// Returns the controller for the equipped item, or `null` if the slot is empty.
  KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
      _handEquipmentManager.handControllerFor(slot);

  // ============================================================================
  // Combat Execution - Equipment System Delegation
  // ============================================================================

  @override
  bool executePrimaryAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.primary, damage);

  @override
  bool executeRangedAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.fireball, damage);

  /// Routes attack execution to the appropriate equipped item.
  ///
  /// This method serves as the central routing point for all attack triggers,
  /// allowing the equipment system to determine which hand/item should respond
  /// to each trigger type.
  ///
  /// [trigger] The type of attack being triggered.
  /// [damage] The damage value to apply.
  ///
  /// Returns `true` if any equipped item successfully handled the attack.
  bool _executeAttackForTrigger(KnightAttackTrigger trigger, double damage) {
    return _handEquipmentManager.executeAttack(trigger, damage);
  }
}
