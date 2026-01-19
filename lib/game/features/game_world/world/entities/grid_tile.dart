import 'package:equatable/equatable.dart';

import 'tile_object.dart';

/// Generic grid tile that can hold any type of object in the game world.
/// Replaces the old FarmTile with a more flexible system that supports
/// farm objects, furniture, fences, decorations, and more.
final class GridTile extends Equatable {
  /// X coordinate in the grid
  final int x;

  /// Y coordinate in the grid
  final int y;

  /// The object placed on this tile (farm soil, furniture, fence, etc.)
  /// Null means the tile is empty
  final TileObject? object;

  /// Additional metadata for this tile (e.g., last watered day for farm tiles)
  final Map<String, dynamic>? metadata;

  const GridTile({
    required this.x,
    required this.y,
    this.object,
    this.metadata,
  });

  /// Check if tile is empty (no object)
  bool get isEmpty => object == null;

  /// Check if tile is occupied (has an object)
  bool get isOccupied => object != null;

  /// Check if tile blocks movement
  bool get blocksMovement => object?.blocksMovement ?? false;

  /// Check if tile can be interacted with
  bool get isInteractable => object?.isInteractable ?? false;

  /// Get metadata value by key
  T? getMetadata<T>(String key) {
    return metadata?[key] as T?;
  }

  /// Set metadata value
  GridTile setMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata ?? {});
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  /// Remove metadata value
  GridTile removeMetadata(String key) {
    if (metadata == null) return this;
    final newMetadata = Map<String, dynamic>.from(metadata!);
    newMetadata.remove(key);
    return copyWith(metadata: newMetadata.isEmpty ? null : newMetadata);
  }

  /// Place an object on this tile
  GridTile placeObject(TileObject newObject) {
    return copyWith(object: newObject);
  }

  /// Remove the object from this tile
  GridTile removeObject() {
    return copyWith(object: null, metadata: null);
  }

  /// Serialization
  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'object': object?.toJson(), 'metadata': metadata};
  }

  /// Deserialization (requires object factory)
  static GridTile fromJson(
    Map<String, dynamic> json,
    TileObject? Function(Map<String, dynamic>?) objectFactory,
  ) {
    final objectData = json['object'] as Map<String, dynamic>?;
    return GridTile(
      x: json['x'] as int,
      y: json['y'] as int,
      object: objectFactory(objectData),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create a copy with modifications
  GridTile copyWith({
    int? x,
    int? y,
    TileObject? object,
    Map<String, dynamic>? metadata,
  }) {
    return GridTile(
      x: x ?? this.x,
      y: y ?? this.y,
      object: object ?? this.object,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [x, y, object, metadata];

  @override
  String toString() => 'GridTile(x: $x, y: $y, object: $object)';
}
