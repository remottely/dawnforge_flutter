/// Quality level of farming items (crops, animal products, foraged items).
///
/// In Stardew Valley, quality affects the sell price of items:
/// - Normal: base price
/// - Silver: 1.25x base price
/// - Gold: 1.5x base price
/// - Iridium: 2x base price
///
/// Quality is determined by:
/// - Farming skill level
/// - Fertilizer used
/// - Random chance
enum ItemQuality {
  /// Normal quality (no star)
  normal,

  /// Silver quality (1 star)
  silver,

  /// Gold quality (2 stars)
  gold,

  /// Iridium quality (3 stars)
  iridium;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ItemQuality.normal:
        return 'Normal';
      case ItemQuality.silver:
        return 'Silver';
      case ItemQuality.gold:
        return 'Gold';
      case ItemQuality.iridium:
        return 'Iridium';
    }
  }

  /// Price multiplier for this quality
  double get priceMultiplier {
    switch (this) {
      case ItemQuality.normal:
        return 1.0;
      case ItemQuality.silver:
        return 1.25;
      case ItemQuality.gold:
        return 1.5;
      case ItemQuality.iridium:
        return 2.0;
    }
  }

  /// Star count for UI display
  int get starCount {
    switch (this) {
      case ItemQuality.normal:
        return 0;
      case ItemQuality.silver:
        return 1;
      case ItemQuality.gold:
        return 2;
      case ItemQuality.iridium:
        return 3;
    }
  }

  /// Serialize to JSON
  String toJson() => name;

  /// Deserialize from JSON
  static ItemQuality fromJson(String json) {
    return ItemQuality.values.firstWhere(
      (q) => q.name == json,
      orElse: () => ItemQuality.normal,
    );
  }

  @override
  String toString() => displayName;
}
