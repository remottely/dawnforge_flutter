enum HandItemQuality {
  normal,
  silver,
  gold,
  iridium;

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
    }
  }

  String toJson() => name;

  static HandItemQuality fromJson(String json) {
    return HandItemQuality.values.firstWhere(
      (q) => q.name == json,
      orElse: () => HandItemQuality.normal,
    );
  }

  @override
  String toString() => displayName;
}
