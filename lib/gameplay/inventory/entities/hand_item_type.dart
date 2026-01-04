enum HandItemType {
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

  /// Inventory seed items (non-equip variants)
  carrot_seeds,
  wheat_seeds,
  tomato_seeds,
  pumpkin_seeds,
  ancient_seeds,
  tomato_seed_bag,
  grape_seed_bag,
  prickly_pear_seed_bag,
  coffee_seed_bag,
  carrot,
  zuchini_seed_bag,
  pumpkin_seed_bag,
  pineapple_seed_bag,
  watermelon_seed_bag,

  strawberry,
  apple,
  tomato,
  radish,
  harvestBasket,

  /// Tools
  shovel,
  wateringCan,
  axe,
  staff_fire,
  sword,
  wand,

  /// Weapons
  ironSword,
  staff,

  /// Inventory tools/items
  iron_pickaxe,
  steel_pickaxe,
  wooden_axe,
  basic_hoe,

  /// Consumables
  health_potion,
  stamina_potion,
  super_health_potion,
  cooked_meat,
  strength_elixir,
  carrot_item,
  strawberry_item,
  potato_item,
  pumpkin_item,
  turnip_item,
  radish_item,
  tomato_item,
  corn_item,
  apple_item,

  /// Materials
  wood,
  stone,
  iron_ore,
  gold_ore,
  fiber,
  dungeon_key,
  wheat_item;

  static HandItemType fromString(String json) {
    return HandItemType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => HandItemType.harvestBasket,
    );
  }

  String toJson() => name;

  static HandItemType fromJson(String json) => fromString(json);

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
      this == staff_fire ||
      // this == axe || // TODO(Kevin): define axe isCombatWeapon?
      this == staff;

  bool get canDefense => this == ironSword;

  bool get isEquippable => isSeed || isFarmTool || isCombatWeapon;

  bool get canBeEquippedInMainHandSlot =>
      isSeed || isFarmTool || isCombatWeapon;
}
