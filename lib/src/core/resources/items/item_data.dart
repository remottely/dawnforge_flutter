import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';

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
    this.materialType = 0,
    this.maxStack = 1000000000,
    this.spriteScale = 0.5,
  }) {
    _validate();
  }

  ItemData.fromReader(super.reader)
      : materialType = reader.intOr('material_type', 0),
        maxStack = reader.intOr('max_stack', 1000000000),
        spriteScale = reader.doubleOr('sprite_scale', 0.5),
        super.fromReader() {
    _validate();
  }

  factory ItemData.fromJson(Map<String, Object?> json) =>
      ItemData.fromReader(JsonReader(json, 'ItemData'));

  void _validate() {
    assert(maxStack > 0, '[$runtimeType($id)] max_stack must be > 0');
    assert(spriteScale > 0, '[$runtimeType($id)] sprite_scale must be > 0');
  }

  final int materialType;
  final int maxStack;

  /// Scale of the world-drop sprite relative to the tile.
  final double spriteScale;

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
      );
}
