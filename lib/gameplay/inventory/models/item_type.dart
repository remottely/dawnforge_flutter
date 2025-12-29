enum ItemType {
  weapon,
  tool,
  consumable,
  material,
  cropSeed,
  equipment,
  quest,
  treasure;

  String toJson() => name;

  static ItemType fromJson(String json) => values.byName(json);
}
