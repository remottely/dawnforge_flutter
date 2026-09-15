import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/production/i_producer_data.dart';
import 'package:dawnforge/src/core/resources/production/production_state.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_interactable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// A prop you make things at — the Dart port of `PropWorkstationData.cs`.
///
/// It is an INTERACTABLE prop first (FP4.5e): the pack authors
/// `interaction_range` and `interaction_prompt` on every station document,
/// and `PropInteractableData` is where those two live.
///
/// Recipe discovery is **item-centric**, which is the design worth keeping:
/// a station holds no recipe list of its own. It asks the item registry which
/// items name it, so authoring a new recipe is authoring one document and
/// touching nothing else. The pack's smelter has said `workstation_type:
/// SMELTER` since it was imported; this is the first class to read it.
///
/// What a station is DOING — the running batch, its allocated materials, its
/// progress — lives here too, below the authored half, because it is MUTABLE
/// GAME STATE and rule 8 gives that exactly one home. `WorkstationComponent`
/// is the behaviour over it and keeps nothing of its own.
class PropWorkstationData extends PropInteractableData with IProducerData {
  PropWorkstationData({
    required super.id,
    required this.workstationType,
    super.displayNameKey,
    super.descriptionKey,
    this.productionSpeedMultiplier = 1.0,
    super.interactionRange,
    super.interactionPrompt,
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
    super.currentHealth,
    super.hasIdleSway,
    super.isPushable,
    super.weight,
    super.heatRadius,
    super.respawnTime,
    super.hidesActors,
  }) {
    _validate();
  }

  PropWorkstationData.fromReader(super.reader)
      : workstationType = reader.enumOr(
          'workstation_type',
          WorkstationType.values,
          WorkstationType.none,
        ),
        productionSpeedMultiplier =
            reader.doubleOr('production_speed_multiplier', 1),
        super.fromReader() {
    _validate();
  }

  factory PropWorkstationData.fromJson(Map<String, Object?> json) =>
      PropWorkstationData.fromReader(
        JsonReader(json, 'PropWorkstationData'),
      );

  void _validate() {
    // PORT DELTA — the spec asserts neither of these, and both are worth it.
    //
    // A station typed NONE would match the recipes made BY HAND, so it would
    // stand in the world offering the one list it must never own. That is a
    // content bug with no symptom, which is the kind rule 5 exists for.
    assert(
      workstationType != WorkstationType.none,
      '[$runtimeType($id)] workstation_type is NONE — that is the value a '
      'RECIPE uses to say "made by hand", and a station that answers to it '
      'would offer the hand list',
    );
    // The spec guards this INLINE, every time it divides: `multiplier > 0 ?
    // multiplier : 1.0`. That is a fallback patched over bad data at the point
    // of use (rules 5 and 20). Asserted once here instead, so the division
    // downstream is plain arithmetic that cannot be handed a zero.
    assert(
      productionSpeedMultiplier > 0,
      '[$runtimeType($id)] production_speed_multiplier must be > 0',
    );
  }

  /// Which recipes name this station. Tier 1 = 1.0, tier 5 = 5.0 in the pack.
  final WorkstationType workstationType;

  /// How much faster than the authored time this station works: the effective
  /// time is the base time DIVIDED by this, so bigger is faster.
  @override
  final double productionSpeedMultiplier;

  // ---------------------------------------------------------------------------
  // PRODUCTION STATE — what the station is DOING (rule 8: it lives here).
  // ---------------------------------------------------------------------------

  /// The batch this station is making — the state, and the invariants over
  /// it, in the one class both benches share (`ProductionState`, 0.76.0).
  @override
  final ProductionState production = ProductionState();

  @override
  WorkstationType get productionType => workstationType;

  @override
  String get producerName => id;

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        ...production.serialize(),
      };

  /// Copies every field, the production state included: a clone is a full
  /// copy, the same bargain `currentHealth` makes one class up. The registry
  /// template is never producing, so the factory's clone starts idle; a save
  /// restoring a mid-batch station is FP6's, and lands on these same fields.
  @override
  PropWorkstationData clone() =>
      _cloneAuthored()..production.adoptFrom(production);

  PropWorkstationData _cloneAuthored() => PropWorkstationData(
        id: id,
        displayNameKey: displayNameKey,
        descriptionKey: descriptionKey,
        workstationType: workstationType,
        productionSpeedMultiplier: productionSpeedMultiplier,
        interactionRange: interactionRange,
        interactionPrompt: interactionPrompt,
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
        currentHealth: currentHealth,
        hasIdleSway: hasIdleSway,
        isPushable: isPushable,
        weight: weight,
        heatRadius: heatRadius,
        respawnTime: respawnTime,
        hidesActors: hidesActors,
      );
}
