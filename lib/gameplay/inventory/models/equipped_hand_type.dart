enum EquippedHandType {
  /// Seeds
  apple_seed_bag,
  cabbage_seed_bag,
  radish_seed_bag,
  carrot_seed_bag,
  strawberry_seed_bag,
  wheat_seed_bag,
  pepper_seed_bag,
  turnip_seed_bag,
  cotton_seed_bag,
  onion_seed_bag,
  cauliflower_seed_bag,
  corn_seed_bag,
  tomato_seed_bag,
  grape_seed_bag,
  prickly_pear_seed_bag,
  coffee_seed_bag,
  zuchini_seed_bag,
  pumpkin_seed_bag,
  pineapple_seed_bag,
  watermelon_seed_bag,

  strawberry,
  apple,
  tomato,

  /// Tools
  shovel,
  wateringCan,
  harvestBasket,
  axe,
  sword,
  wand,

  /// Weapons
  ironSword,
  staff;

  String toJson() => name;

  static EquippedHandType fromJson(String json) {
    return EquippedHandType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => EquippedHandType.harvestBasket,
    );
  }

  bool get isSeed =>
      this == apple_seed_bag ||
      this == cabbage_seed_bag ||
      this == radish_seed_bag ||
      this == carrot_seed_bag ||
      this == strawberry_seed_bag ||
      this == wheat_seed_bag ||
      this == pepper_seed_bag ||
      this == turnip_seed_bag ||
      this == cotton_seed_bag ||
      this == onion_seed_bag ||
      this == cauliflower_seed_bag ||
      this == corn_seed_bag ||
      this == tomato_seed_bag ||
      this == grape_seed_bag ||
      this == prickly_pear_seed_bag ||
      this == coffee_seed_bag ||
      this == zuchini_seed_bag ||
      this == pumpkin_seed_bag ||
      this == pineapple_seed_bag ||
      this == watermelon_seed_bag;

  bool get isFarmTool =>
      this == shovel ||
      this == wateringCan ||
      this == harvestBasket ||
      this == axe; // TODO(Kevin): define axe isFarmTool?

  bool get isCombatWeapon =>
      this == ironSword ||
      this == sword ||
      this == wand ||
      // this == axe || // TODO(Kevin): define axe isCombatWeapon?
      this == staff;

  bool get canDefense => this == ironSword;

  bool get isEquippable => isSeed || isFarmTool || isCombatWeapon;

  bool get canBeEquippedInMainHandSlot =>
      isSeed || isFarmTool || isCombatWeapon;
}
