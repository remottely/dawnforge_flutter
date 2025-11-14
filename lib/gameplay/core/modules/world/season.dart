/// Enum representing the four seasons in the game
enum Season {
  /// Spring season (Days 1-28)
  spring,

  /// Summer season (Days 29-56)
  summer,

  /// Fall/Autumn season (Days 57-84)
  fall,

  /// Winter season (Days 85-112)
  winter;

  /// Convert enum to JSON string
  String toJson() => name;

  /// Create enum from JSON string
  static Season fromJson(String json) => values.byName(json);

  /// Get display name for the season
  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
    }
  }
}
