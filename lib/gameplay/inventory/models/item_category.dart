enum ItemCategory { // TODO(Kevin): refact this
  vegetables,
  fruits,
  flowers,
  // forage,
  // seeds,
  animalProducts,
  artisanGoods,
  fish,
  // fishingEquipment,
  // ores,
  // minerals,
  // geodes,
  // craftingMaterials,
  // resources,
  // cookingIngredients,
  // cookedFood,
  // weapon,
  // tools,
  // equipment,
  // furniture,
  // questItems,
  // trash,
  misc
  ;

  String get displayName {
    switch (this) {
      case ItemCategory.vegetables:
        return 'Vegetables';
      case ItemCategory.fruits:
        return 'Fruits';
      case ItemCategory.flowers:
        return 'Flowers';
      // case ItemCategory.forage:
      //   return 'Forage';
      // case ItemCategory.seeds:
      //   return 'Seeds';
      case ItemCategory.animalProducts:
        return 'Animal Products';
      case ItemCategory.artisanGoods:
        return 'Artisan Goods';
      case ItemCategory.fish:
        return 'Fish';
      // case ItemCategory.fishingEquipment:
      //   return 'Fishing Equipment';
      // case ItemCategory.ores:
      //   return 'Ores';
      // case ItemCategory.minerals:
      //   return 'Minerals';
      // case ItemCategory.geodes:
      //   return 'Geodes';
      // case ItemCategory.craftingMaterials:
      //   return 'Crafting Materials';
      // case ItemCategory.resources:
      //   return 'Resources';
      // case ItemCategory.cookingIngredients:
      //   return 'Cooking Ingredients';
      // case ItemCategory.cookedFood:
      //   return 'Cooked Food';
      // case ItemCategory.weapon:
      //   return 'Weapon';
      // case ItemCategory.tools:
      //   return 'Tools';
      // case ItemCategory.equipment:
      //   return 'Equipment';
      // case ItemCategory.furniture:
      //   return 'Furniture';
      // case ItemCategory.questItems:
      //   return 'Quest Items';
      // case ItemCategory.trash:
      //   return 'Trash';
      case ItemCategory.misc:
        return 'Miscellaneous';
    }
  }

  bool get canHaveQuality {
    return [
      ItemCategory.vegetables,
      ItemCategory.fruits,
      ItemCategory.flowers,
      // ItemCategory.forage,
      ItemCategory.animalProducts,
      ItemCategory.fish,
      // ItemCategory.ores,
      // ItemCategory.minerals,
    ].contains(this);
  }

  bool get isEdible {
    return [
      ItemCategory.vegetables,
      ItemCategory.fruits,
      // ItemCategory.forage,
      ItemCategory.animalProducts,
      ItemCategory.fish,
      // ItemCategory.cookedFood,
    ].contains(this);
  }

  // bool get isPlantable {
  //   return this == ItemCategory.seeds;
  // }

  String toJson() => name;

  static ItemCategory fromJson(String json) {
    return ItemCategory.values.firstWhere(
      (c) => c.name == json,
      orElse: () => ItemCategory.misc,
    );
  }

  @override
  String toString() => displayName;
}
