import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/items/item_amount.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// An item that is a BLUEPRINT — the port of `ItemBuildableData.cs`.
///
/// It carries one field the base item does not: the id of the world object it
/// builds. Everything else about placing it — where it may land, and what
/// happens when it does — belongs to `WorldPlacementHelper` (FP4.3b), because
/// the same questions are asked of a blueprint the player holds and of one the
/// world grows on its own.
///
/// PORT DELTA — the hierarchy above it, now one link shorter. The spec reads
/// `ItemBuildableData : IItemActionData : ItemCraftableData : ItemData`. At
/// 0.35.0 both middle links were missing and this extended [ItemData]
/// directly; FP4.5 inserted [ItemCraftableData], so a blueprint carries its
/// own recipe — which is what the smelter's has authored all along (5 logs,
/// 5 copper ore, 5 coal, made by hand). `IItemActionData` remains collapsed:
/// its reach was lifted onto [ItemData] at 0.27.0 (`action_range`) for the
/// same reason `tool_type` was, and there is nothing else on it to give a
/// class of its own to.
class ItemBuildableData extends ItemCraftableData {
  ItemBuildableData({
    required super.id,
    required this.blueprintId,
    super.ingredients,
    super.craftedAt,
    super.craftTime,
    super.craftAmount,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.tier,
    super.groups,
    super.materialType,
    super.maxStack,
    super.spriteScale,
    super.magnetSpeed,
    super.pickupDelay,
    super.toolType,
    super.attackDamage,
    super.actionRange,
  }) {
    _validate();
  }

  ItemBuildableData.fromReader(super.reader)
      : blueprintId = reader.requiredString('blueprint_id'),
        super.fromReader() {
    _validate();
  }

  factory ItemBuildableData.fromJson(Map<String, Object?> json) =>
      ItemBuildableData.fromReader(JsonReader(json, 'ItemBuildableData'));

  void _validate() {
    assert(
      blueprintId.isNotEmpty,
      '[$runtimeType($id)] blueprint_id is empty — a buildable that builds '
      'nothing is content that cannot be authored, not an item with a missing '
      'field (rule 5)',
    );
  }

  /// The id of the world object this item puts into the world.
  final String blueprintId;

  /// What this item builds (rule 2 — resolved through a registry, never a
  /// parsed file).
  ///
  /// PORT DELTA in the LOOKUP, not in the answer: the spec asks one
  /// `WorldObjectRegistry` that holds every world object and then asks the
  /// result what it is. This port splits that database by family
  /// ([PropRegistry], [GroundRegistry]), so the family is found by asking
  /// which one holds the id — and the answer is the same `IWorldObjectData`
  /// the spec hands back, so [isPropBlueprint] and [isGroundBlueprint] stay
  /// type tests over it rather than a remembered lookup.
  ///
  /// An id in neither registry is a content bug and crashes here, at the first
  /// read, exactly as the spec's own `get_blueprint()` throws.
  IWorldObjectData get blueprint {
    final props = locator<PropRegistry>();
    if (props.has(blueprintId)) return props.getProp(blueprintId);
    final grounds = locator<GroundRegistry>();
    if (grounds.has(blueprintId)) return grounds.getGround(blueprintId);
    throw StateError(
      '[ItemBuildableData($id)] blueprint "$blueprintId" is in no registry — '
      'a blueprint names an authored prop or ground',
    );
  }

  /// Whether [blueprint] is a prop, which decides which half of
  /// `WorldPlacementHelper` answers for it.
  bool get isPropBlueprint => blueprint is PropData;

  /// Whether [blueprint] is a terrain tile — the other half.
  bool get isGroundBlueprint => blueprint is GroundBuildableData;

  @override
  ItemBuildableData clone() => ItemBuildableData(
        id: id,
        blueprintId: blueprintId,
        ingredients: List<ItemAmount>.of(ingredients),
        craftedAt: craftedAt,
        craftTime: craftTime,
        craftAmount: craftAmount,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        tier: tier,
        groups: List<String>.of(groups),
        materialType: materialType,
        maxStack: maxStack,
        spriteScale: spriteScale,
        magnetSpeed: magnetSpeed,
        pickupDelay: pickupDelay,
        toolType: toolType,
        attackDamage: attackDamage,
        actionRange: actionRange,
      );
}
