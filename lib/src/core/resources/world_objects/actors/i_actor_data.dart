import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/inventory/inventory_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// Data of every actor (player, creature, NPC) — port of `IActorData.cs`
/// (faithful slice: movement + held item + AI disposition; equipment,
/// cosmetics and dodge arrive with their systems).
class IActorData extends IWorldObjectData {
  IActorData({
    required super.id,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.groups,
    super.gridWidth,
    super.gridHeight,
    super.isFlat,
    super.hasCollision,
    super.allowsActorOverlap,
    super.isProjectilePassable,
    super.baseMaxHealth,
    super.drops,
    super.inventorySize,
    InventoryData? inventory,
    super.currentHealth,
    this.heldItemId = '',
    this.baseActionSpeed = 1.0,
    this.moveSpeed = EngineConstants.baseMoveSpeed,
    this.acceleration = EngineConstants.baseAcceleration,
    this.friction = EngineConstants.baseFriction,
    this.aiBehavior = AIBehavior.neutral,
    this.aiCombatStyle = AICombatStyle.meleePrimary,
  }) {
    this.inventory = inventory ?? InventoryData(slotCount: inventorySize);
    _validate();
  }

  IActorData.fromReader(super.reader)
      : heldItemId = reader.stringOr('held_item_id', ''),
        baseActionSpeed = reader.doubleOr('base_action_speed', 1),
        moveSpeed =
            reader.doubleOr('move_speed', EngineConstants.baseMoveSpeed),
        acceleration =
            reader.doubleOr('acceleration', EngineConstants.baseAcceleration),
        friction = reader.doubleOr('friction', EngineConstants.baseFriction),
        aiBehavior = reader.enumOr(
          'ai_behavior',
          AIBehavior.values,
          AIBehavior.neutral,
        ),
        aiCombatStyle = reader.enumOr(
          'ai_combat_style',
          AICombatStyle.values,
          AICombatStyle.meleePrimary,
        ),
        super.fromReader() {
    inventory = InventoryData(slotCount: inventorySize);
    _validate();
  }

  factory IActorData.fromJson(Map<String, Object?> json) =>
      IActorData.fromReader(JsonReader(json, 'IActorData'));

  void _validate() {
    // 0 is legal: a stationary actor simply never moves/acts.
    assert(moveSpeed >= 0, '[$runtimeType($id)] move_speed negative');
    assert(baseActionSpeed >= 0, '[$runtimeType($id)] base_action_speed negative');
  }

  /// The actor's container STATE (rule 8) — sized by the authored
  /// `inventory_size`, mutated only through `InventoryComponent`. `late` only
  /// so the constructor BODY can size it from the inherited field; both
  /// constructors assign it exactly once.
  late final InventoryData inventory;

  final String heldItemId;
  final double baseActionSpeed;

  /// Tiles per second.
  final double moveSpeed;
  final double acceleration;
  final double friction;
  final AIBehavior aiBehavior;
  final AICombatStyle aiCombatStyle;

  @override
  IActorData clone() => IActorData(
        id: id,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        groups: List<String>.of(groups),
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        isFlat: isFlat,
        hasCollision: hasCollision,
        allowsActorOverlap: allowsActorOverlap,
        isProjectilePassable: isProjectilePassable,
        baseMaxHealth: baseMaxHealth,
        drops: List<DropEntry>.of(drops),
        inventorySize: inventorySize,
        inventory: inventory.clone(),
        currentHealth: currentHealth,
        heldItemId: heldItemId,
        baseActionSpeed: baseActionSpeed,
        moveSpeed: moveSpeed,
        acceleration: acceleration,
        friction: friction,
        aiBehavior: aiBehavior,
        aiCombatStyle: aiCombatStyle,
      );

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        if (inventory.hasAnyItem) 'inventory': inventory.serialize(),
      };
}
