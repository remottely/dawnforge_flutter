enum HandLootCategory { // TODO(Kevin): refact this
  vegetable,
  fruit,
  flower,
  // forage,
  // seeds,
  animalProduct,
  artisanGood,
  fish,
  // fishingEquipment,
  // ore,
  // mineral,
  // geode,
  // craftingMaterial,
  // resource,
  // cookingIngredient,
  // cookedFood,
  // weapon,
  // tool,
  // equipment,
  // furniture,
  // questItem,
  // trash,
  misc
  ;

  String get displayName {
    switch (this) {
      case HandLootCategory.vegetable:
        return 'Vegetable';
      case HandLootCategory.fruit:
        return 'Fruit';
      case HandLootCategory.flower:
        return 'Flower';
      // case ItemCategory.forage:
      //   return 'Forage';
      // case ItemCategory.seed:
      //   return 'Seed';
      case HandLootCategory.animalProduct:
        return 'Animal Product';
      case HandLootCategory.artisanGood:
        return 'Artisan Good';
      case HandLootCategory.fish:
        return 'Fish';
      // case ItemCategory.fishingEquipment:
      //   return 'Fishing Equipment';
      // case ItemCategory.ore:
      //   return 'Ore';
      // case ItemCategory.mineral:
      //   return 'Mineral';
      // case ItemCategory.geode:
      //   return 'Geode';
      // case ItemCategory.craftingMaterial:
      //   return 'Crafting Material';
      // case ItemCategory.resource:
      //   return 'Resource';
      // case ItemCategory.cookingIngredient:
      //   return 'Cooking Ingredient';
      // case ItemCategory.cookedFood:
      //   return 'Cooked Food';
      // case ItemCategory.weapon:
      //   return 'Weapon';
      // case ItemCategory.tool:
      //   return 'Tool';
      // case ItemCategory.equipment:
      //   return 'Equipment';
      // case ItemCategory.furniture:
      //   return 'Furniture';
      // case ItemCategory.quest:
      //   return 'Quest Item';
      // case ItemCategory.trash:
      //   return 'Trash';
      case HandLootCategory.misc:
        return 'Miscellaneou';
    }
  }

  bool get canHaveQuality {
    return [
      HandLootCategory.vegetable,
      HandLootCategory.fruit,
      HandLootCategory.flower,
      // ItemCategory.forage,
      HandLootCategory.animalProduct,
      HandLootCategory.fish,
      // ItemCategory.ore,
      // ItemCategory.mineral,
    ].contains(this);
  }

  bool get isEdible {
    return [
      HandLootCategory.vegetable,
      HandLootCategory.fruit,
      // ItemCategory.forage,
      HandLootCategory.animalProduct,
      HandLootCategory.fish,
      // ItemCategory.cookedFood,
    ].contains(this);
  }

  // bool get isPlantable {
  //   return this == ItemCategory.seed;
  // }

  String toJson() => name;

  static HandLootCategory fromJson(String json) {
    return HandLootCategory.values.firstWhere(
      (c) => c.name == json,
      orElse: () => HandLootCategory.misc,
    );
  }

  @override
  String toString() => displayName;
}
