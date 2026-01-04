enum HandItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  String toJson() => name;

  static HandItemRarity fromJson(String json) => values.byName(json);

  double get sellValueMultiplier {
    switch (this) {
      case HandItemRarity.common:
        return 1.0;
      case HandItemRarity.uncommon:
        return 1.5;
      case HandItemRarity.rare:
        return 2.5;
      case HandItemRarity.epic:
        return 5.0;
      case HandItemRarity.legendary:
        return 10.0;
    }
  }
}
