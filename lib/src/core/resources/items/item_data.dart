import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
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
    super.groups,
    this.materialType = MaterialType.stone,
    this.maxStack = 1000000000,
    this.spriteScale = 0.5,
    this.magnetSpeed = 200,
    this.pickupDelay = 0.5,
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
        groups: List<String>.of(groups),
        materialType: materialType,
        maxStack: maxStack,
        spriteScale: spriteScale,
        magnetSpeed: magnetSpeed,
        pickupDelay: pickupDelay,
      );
}
