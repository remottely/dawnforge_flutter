import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
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
/// PORT DELTA — the hierarchy above it. The spec reads
/// `ItemBuildableData : IItemActionData : ItemCraftableData : ItemData`, and
/// the two middle links have no class here yet: `IItemActionData`'s reach was
/// lifted onto [ItemData] at 0.27.0 (`action_range`) for the same reason
/// `tool_type` was, and `ItemCraftableData`'s recipe fields arrive with
/// crafting (FP4.5). So this extends [ItemData] directly, and FP4.5 inserts
/// the missing link — the pack already authors all three blocks, unread until
/// then (nothing has shipped, rule 32: a re-parented class costs nothing).
class ItemBuildableData extends ItemData {
  ItemBuildableData({
    required super.id,
    required this.blueprintId,
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
