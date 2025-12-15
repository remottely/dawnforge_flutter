enum ItemType {
  weapon,
  tool,
  consumable,
  material,
  seed,
  equipment,
  quest,
  treasure;

  String toJson() => name;

  static ItemType fromJson(String json) => values.byName(json);
}
