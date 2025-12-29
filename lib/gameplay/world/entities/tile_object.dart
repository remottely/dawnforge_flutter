import 'tile_object_type.dart';

/// Abstract base class for any object that can be placed on a GridTile
/// This enables farm soil, furniture, fences, crops, and any other game object
/// to be placed on the world grid in a unified way.
abstract class TileObject {
  /// Unique identifier for this object type (e.g., "carrot_crop", "wooden_bed")
  String get objectId;

  /// Human-readable name
  String get name;

  /// Type category of this object
  TileObjectType get type;

  /// Whether this object blocks movement
  bool get blocksMovement;

  /// Whether this object can be interacted with
  bool get isInteractable;

  /// Whether this object should use Y-sorting for rendering
  bool get shouldUseYSorting;

  /// Sprite/visual information for rendering
  Map<String, dynamic> get visualData;

  /// Serialize to JSON
  Map<String, dynamic> toJson();

  /// Get a copy of this object with modifications
  TileObject copyWith();

  @override
  String toString() => '$runtimeType(id: $objectId, name: $name)';
}
