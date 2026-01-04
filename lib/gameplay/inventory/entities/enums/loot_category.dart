enum LootCategory { // TODO(Kevin): refact this
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
      case LootCategory.vegetable:
        return 'Vegetable';
      case LootCategory.fruit:
        return 'Fruit';
      case LootCategory.flower:
        return 'Flower';
      // case ItemCategory.forage:
      //   return 'Forage';
      // case ItemCategory.seed:
      //   return 'Seed';
      case LootCategory.animalProduct:
        return 'Animal Product';
      case LootCategory.artisanGood:
        return 'Artisan Good';
      case LootCategory.fish:
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
      case LootCategory.misc:
        return 'Miscellaneou';
    }
  }

  bool get canHaveQuality {
    return [
      LootCategory.vegetable,
      LootCategory.fruit,
      LootCategory.flower,
      // ItemCategory.forage,
      LootCategory.animalProduct,
      LootCategory.fish,
      // ItemCategory.ore,
      // ItemCategory.mineral,
    ].contains(this);
  }

  bool get isEdible {
    return [
      LootCategory.vegetable,
      LootCategory.fruit,
      // ItemCategory.forage,
      LootCategory.animalProduct,
      LootCategory.fish,
      // ItemCategory.cookedFood,
    ].contains(this);
  }

  // bool get isPlantable {
  //   return this == ItemCategory.seed;
  // }

  String toJson() => name;

  static LootCategory fromJson(String json) {
    return LootCategory.values.firstWhere(
      (c) => c.name == json,
      orElse: () => LootCategory.misc,
    );
  }

  @override
  String toString() => displayName;
}
