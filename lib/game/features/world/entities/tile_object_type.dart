/// Types of objects that can be placed on a grid tile
enum TileObjectType {
  /// Empty tile (no object)
  empty,

  /// Farm-related objects (soil, crops)
  farm,

  /// Furniture (bed, table, chair, etc.)
  furniture,

  /// Fences and walls
  fence,

  /// Decorative objects (flowers, stones, etc.)
  decoration,

  /// Interactive objects (chests, doors, etc.)
  interactive,

  /// Buildings and structures
  building,

  /// Natural terrain features (trees, rocks, water)
  terrain,

  /// Other custom objects
  custom,
  unknown;

  String toJson() => name;

  static TileObjectType fromJson(String json) {
    return TileObjectType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => TileObjectType.unknown,
    );
  }
}
