import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// A prop a player can REACH FOR rather than swing at — the data half of
/// `i_prop_interactable.gd`, and the reason `InteractableComponent` knows how
/// far its host answers from.
///
/// It is its own class rather than two more fields on [PropData] because the
/// pack already draws the line that way: a rock and a grass tuft author
/// neither field, every workstation, soil and crop authors both. A prop that
/// carries an interaction range is making a promise about a verb, and the
/// type is where a promise belongs (rule 7).
///
/// PORT DELTA — the spec's `can_interact` is NOT here. It is a mutable flag
/// the spec keeps on the component (its own rule 8 broken) and nothing in
/// either tree ever writes it. A gate with no hand on it is a gate that
/// always says yes, which rule 5 calls a fallback; it lands the day a
/// consumer turns a station off.
class PropInteractableData extends PropData {
  PropInteractableData({
    required super.id,
    this.interactionRange = EngineConstants.interactionRange,
    this.interactionPrompt = '',
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
    _validateInteraction();
  }

  PropInteractableData.fromReader(super.reader)
      : interactionRange = reader.doubleOr(
          'interaction_range',
          EngineConstants.interactionRange,
        ),
        interactionPrompt = reader.stringOr('interaction_prompt', ''),
        super.fromReader() {
    _validateInteraction();
  }

  factory PropInteractableData.fromJson(Map<String, Object?> json) =>
      PropInteractableData.fromReader(
        JsonReader(json, 'PropInteractableData'),
      );

  void _validateInteraction() {
    // 0 is legal and the pack means it: a wheat plant authors 0.5 and a soil
    // tile authors 0.0, which is "stand on it" — the reach is measured EDGE
    // TO EDGE, so a zero range still reaches a neighbouring tile's edge.
    assert(
      interactionRange >= 0,
      '[$runtimeType($id)] interaction_range negative',
    );
  }

  /// How far this prop answers from, in TILES as authored. The component
  /// converts once, on the way to a reach measured in pixels — the spec's own
  /// comment is about the conversion it forgot, and the number crosses the
  /// boundary exactly once here.
  final double interactionRange;

  /// What the indicator will say when the cursor is over this prop
  /// (`Harvest [E]`). Authored on every interactable document and read by
  /// nothing yet: the hover INDICATOR is FP5.1(e), and the string arrives
  /// from the pack in English until FP5.3 gives the pack a key to say it
  /// with (rule 19 is a rule about literals in code, and this is content).
  final String interactionPrompt;

  @override
  PropInteractableData clone() => PropInteractableData(
        id: id,
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
