enum HandItemCategory {
  weapon,
  tool,
  consumable,
  material,
  cropSeed,
  equipment,
  quest,
  treasure;

  String toJson() => name;

  static HandItemCategory fromJson(String json) => values.byName(json);
}
