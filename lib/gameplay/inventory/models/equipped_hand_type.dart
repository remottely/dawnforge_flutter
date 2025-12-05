enum EquippedHandType {
  ironSword,
  shovel,
  wateringCan,
  strawberry,
  harvestBasket,
  axe,
  spear,
  dagger,
  mace,
  bow,
  crossbow,
  staff,
  wand;

  String toJson() => name;

  static EquippedHandType fromJson(String json) {
    return EquippedHandType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => EquippedHandType.ironSword,
    );
  }
}
