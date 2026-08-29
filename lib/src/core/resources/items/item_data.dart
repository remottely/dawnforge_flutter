import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// Data of every item — port of `ItemData.cs` (faithful slice: identity,
/// stacking, world-sprite scale; tool actions, tactical powers and hand
/// animation arrive with the item-hand system). Extends the VISUAL base, not
/// the world-object one — an item in the world is a pickup, not a placeable.
class ItemData extends IVisualObjectData {
  ItemData({
    required super.id,
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
    this.materialType = MaterialType.stone,
    this.maxStack = 1000000000,
    this.spriteScale = 0.5,
    this.magnetSpeed = 200,
    this.pickupDelay = 0.5,
    this.toolType,
    this.attackDamage = 0,
    this.actionRange = EngineConstants.interactionRange,
  }) {
    _validate();
  }

  ItemData.fromReader(super.reader)
      : materialType = reader.enumOr(
          'material_type',
          MaterialType.values,
          MaterialType.stone,
        ),
        maxStack = reader.intOr('max_stack', 1000000000),
        spriteScale = reader.doubleOr('sprite_scale', 0.5),
        magnetSpeed = reader.doubleOr('magnet_speed', 200),
        pickupDelay = reader.doubleOr('pickup_delay', 0.5),
        toolType = reader.enumOrNull('tool_type', ToolType.values),
        attackDamage = reader.doubleOr('attack_damage', 0),
        actionRange = reader.doubleOr(
          'action_range',
          EngineConstants.interactionRange,
        ),
        super.fromReader() {
    _validate();
  }

  factory ItemData.fromJson(Map<String, Object?> json) =>
      ItemData.fromReader(JsonReader(json, 'ItemData'));

  void _validate() {
    assert(maxStack > 0, '[$runtimeType($id)] max_stack must be > 0');
    assert(spriteScale > 0, '[$runtimeType($id)] sprite_scale must be > 0');
    assert(magnetSpeed > 0, '[$runtimeType($id)] magnet_speed must be > 0');
    assert(pickupDelay >= 0, '[$runtimeType($id)] pickup_delay must be >= 0');
  }

  final MaterialType materialType;
  final int maxStack;

  /// Scale of the world-drop sprite relative to the tile.
  final double spriteScale;

  /// Magnet flight speed of this item's pickup, in TILES per second.
  final double magnetSpeed;

  /// Which tool this item IS, or null when it is not one.
  ///
  /// Null is a real answer, not a missing value: a plank is not a tool, and
  /// swinging it satisfies no object's `allowedTools`. The spec expresses the
  /// same thing by putting `tool_type` on the tool SUBCLASSES only, which our
  /// single `ItemData` cannot do until that hierarchy is ported.
  final ToolType? toolType;

  /// What one blow with this item takes off its target.
  ///
  /// Zero for everything that is not a weapon or a tool, and zero is a real
  /// number here rather than a missing one: a swing that deals nothing is
  /// still a swing. It never becomes a way to break something for free —
  /// [toolType] decides whether the blow is allowed at all, and a plank
  /// carries neither.
  ///
  /// Authored under `IItemToolData` in the pack, like [toolType], and lifted
  /// onto `ItemData` for the same reason (0.27.0): the tool subclasses the
  /// spec declares it on are not ported yet.
  final double attackDamage;

  /// How far this item reaches, in TILES — bare hands one tile, a spear more.
  /// The declared default is the spec's `EngineConstants.InteractionRange`,
  /// which is what an item that names no reach of its own is worth.
  final double actionRange;

  /// Seconds after landing before this pickup may be collected.
  ///
  /// Small and easy to mistake for a nicety; it is the only thing that makes
  /// putting something DOWN possible. A dropped item lands at the dropper's
  /// own feet, well inside the magnet radius, so without a delay it is
  /// reserved and flown back on the very next step and the bag never lets go.
  final double pickupDelay;

  @override
  ItemData clone() => ItemData(
        id: id,
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
