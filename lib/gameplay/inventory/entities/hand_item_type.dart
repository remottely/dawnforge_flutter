enum HandItemType {
  weapon,
  tool,
  consumable,
  material,
  cropSeed,
  equipment,
  quest,
  treasure;

  String toJson() => name;

  static HandItemType fromJson(String json) => values.byName(json);
}
