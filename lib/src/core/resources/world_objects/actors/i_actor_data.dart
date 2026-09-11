import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/inventory/inventory_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/production/i_producer_data.dart';
import 'package:dawnforge/src/core/resources/production/production_state.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// Data of every actor (player, creature, NPC) — port of `IActorData.cs`
/// (faithful slice: movement + held item + AI disposition; equipment,
/// cosmetics and dodge arrive with their systems).
class IActorData extends IWorldObjectData with IProducerData {
  IActorData({
    required super.id,
    super.displayNameKey,
    super.descriptionKey,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.tier,
    super.allowedTools,
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
  IActorData clone() => _cloneAuthored()..production.adoptFrom(production);

  IActorData _cloneAuthored() => IActorData(
        id: id,
        displayNameKey: displayNameKey,
        descriptionKey: descriptionKey,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        tier: tier,
        allowedTools: List<ToolType>.of(allowedTools),
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

  // ---------------------------------------------------------------------------
  // THE HAND-CRAFT — an actor is a bench of its own (`D-2`)
  // ---------------------------------------------------------------------------

  /// What this actor is making with its own two hands.
  ///
  /// A player is a bench at [WorkstationType.none] and speed 1.0, which is what
  /// the pack's `crafted_at: NONE` recipes — the smelter and the workshop among
  /// them — have always meant and what nothing until now could read. The state
  /// lives here because all mutable state does (rule 8), and it is the same
  /// class a station's batch lives in, so the two cannot drift.
  ///
  /// It is on `IActorData` and not on a player-only soul because there is no
  /// player-only soul: a player is an actor authored into the `player` group.
  /// The COMPONENT that ticks it is mounted by `ActorPlayer` alone, so a boar
  /// carries an idle batch it can never open — the same bargain `inventory`
  /// already makes for a creature that never picks anything up.
  @override
  final ProductionState production = ProductionState();

  /// Hands are the bench every recipe that names no station is made at.
  @override
  WorkstationType get productionType => WorkstationType.none;

  @override
  String get producerName => id;

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        if (inventory.hasAnyItem) 'inventory': inventory.serialize(),
        if (production.isProducing) ...production.serialize(),
      };
}
