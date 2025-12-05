enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  String toJson() => name;

  static ItemRarity fromJson(String json) => values.byName(json);

  double get sellValueMultiplier {
    switch (this) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.5;
      case ItemRarity.rare:
        return 2.5;
      case ItemRarity.epic:
        return 5.0;
      case ItemRarity.legendary:
        return 10.0;
    }
  }
}
