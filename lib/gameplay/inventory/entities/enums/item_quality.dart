enum ItemQuality {
  normal,
  silver,
  gold,
  iridium;

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

  String toJson() => name;

  static ItemQuality fromJson(String json) {
    return ItemQuality.values.firstWhere(
      (q) => q.name == json,
      orElse: () => ItemQuality.normal,
    );
  }

  @override
  String toString() => displayName;
}
