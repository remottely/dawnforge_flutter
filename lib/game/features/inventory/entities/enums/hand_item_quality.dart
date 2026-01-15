enum HandItemQuality {
  normal,
  silver,
  gold,
  iridium,
  unknown;

  String get displayName {
    switch (this) {
      case HandItemQuality.normal:
        return 'Normal';
      case HandItemQuality.silver:
        return 'Silver';
      case HandItemQuality.gold:
        return 'Gold';
      case HandItemQuality.iridium:
        return 'Iridium';
      case HandItemQuality.unknown:
        return 'Unknown';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case HandItemQuality.normal:
        return 1.0;
      case HandItemQuality.silver:
        return 1.25;
      case HandItemQuality.gold:
        return 1.5;
      case HandItemQuality.iridium:
        return 2.0;
      case HandItemQuality.unknown:
        return 1.0;
    }
  }

  int get starCount {
    switch (this) {
      case HandItemQuality.normal:
        return 0;
      case HandItemQuality.silver:
        return 1;
      case HandItemQuality.gold:
        return 2;
      case HandItemQuality.iridium:
        return 3;
      case HandItemQuality.unknown:
        return 0;
    }
  }

  String toJson() => name;

  static HandItemQuality fromJson(String json) {
    return HandItemQuality.values.firstWhere(
      (q) => q.name == json,
      orElse: () => HandItemQuality.unknown,
    );
  }

  @override
  String toString() => displayName;
}
