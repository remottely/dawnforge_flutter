enum EquippedHandType {
  /// Seeds
  cabbage,
  radish,
  carrot,
  strawberry,
  wheat,
  pepper,
  turnip,
  cotton,
  onion,
  cauliflower,
  corn,
  tomato,
  grape,
  prickly_pear,
  coffee,
  zuchini,
  pumpkin,
  pineapple,
  watermelon,

  /// Tools
  shovel,
  wateringCan,
  harvestBasket,
  axe,

  /// Weapons // TODO(Kevin): deprecated, remove this
  ironSword,
  staff,
  spear,
  dagger,
  mace,
  bow,
  crossbow,
  wand;

  String toJson() => name;

  static EquippedHandType fromJson(String json) {
    return EquippedHandType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => EquippedHandType.ironSword,
    );
  }

  bool get isSeed =>
      this == cabbage ||
      this == radish ||
      this == carrot ||
      this == strawberry ||
      this == wheat ||
      this == pepper ||
      this == turnip ||
      this == cotton ||
      this == onion ||
      this == cauliflower ||
      this == corn ||
      this == tomato ||
      this == grape ||
      this == prickly_pear ||
      this == coffee ||
      this == zuchini ||
      this == pumpkin ||
      this == pineapple ||
      this == watermelon;

  bool get isFarmTool =>
      this == shovel ||
      this == wateringCan ||
      this == harvestBasket ||
      this == axe; // TODO(Kevin): define axe isFarmTool?

  bool get isCombatWeapon =>
      this == ironSword ||
      this == axe || // TODO(Kevin): define axe isCombatWeapon?
      this == spear ||
      this == dagger ||
      this == mace ||
      this == bow ||
      this == crossbow ||
      this == staff ||
      this == wand;

  bool get isEquippable => isSeed || isFarmTool || isCombatWeapon;

  bool get canBeEquippedInWeaponSlot => isEquippable;
}
