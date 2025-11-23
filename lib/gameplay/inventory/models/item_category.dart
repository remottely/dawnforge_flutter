/// Detailed item categories following Stardew Valley's classification system.
///
/// Items are organized into categories that affect:
/// - Shop organization
/// - Bundles and quests
/// - Gifting preferences
/// - Collection achievements
enum ItemCategory {
  // ========== FARMING ==========
  /// Vegetables grown from seeds
  vegetables,

  /// Fruits from trees and crops
  fruits,

  /// Flowers for decoration and gifts
  flowers,

  // ========== FORAGING ==========
  /// Items found while foraging
  forage,

  /// Seeds found or purchased
  seeds,

  // ========== ANIMAL PRODUCTS ==========
  /// Products from animals (milk, eggs, wool)
  animalProducts,

  /// Artisan goods (cheese, mayo, cloth)
  artisanGoods,

  // ========== FISHING ==========
  /// Fish caught in water
  fish,

  /// Bait and tackle
  fishingEquipment,

  // ========== MINING ==========
  /// Ores and bars
  ores,

  /// Gems and minerals
  minerals,

  /// Geodes
  geodes,

  // ========== CRAFTING ==========
  /// Raw materials for crafting
  craftingMaterials,

  /// Resources (wood, stone, fiber)
  resources,

  // ========== COOKING ==========
  /// Ingredients for cooking
  cookingIngredients,

  /// Cooked dishes
  cookedFood,

  // ========== EQUIPMENT ==========
  /// Weapons for combat
  weapons,

  /// Tools (hoe, watering can, axe, pickaxe)
  tools,

  /// Boots and rings
  equipment,

  // ========== SPECIAL ==========
  /// Furniture and decorations
  furniture,

  /// Quest items
  questItems,

  /// Trash and junk
  trash,

  /// Miscellaneous
  misc;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ItemCategory.vegetables:
        return 'Vegetables';
      case ItemCategory.fruits:
        return 'Fruits';
      case ItemCategory.flowers:
        return 'Flowers';
      case ItemCategory.forage:
        return 'Forage';
      case ItemCategory.seeds:
        return 'Seeds';
      case ItemCategory.animalProducts:
        return 'Animal Products';
      case ItemCategory.artisanGoods:
        return 'Artisan Goods';
      case ItemCategory.fish:
        return 'Fish';
      case ItemCategory.fishingEquipment:
        return 'Fishing Equipment';
      case ItemCategory.ores:
        return 'Ores';
      case ItemCategory.minerals:
        return 'Minerals';
      case ItemCategory.geodes:
        return 'Geodes';
      case ItemCategory.craftingMaterials:
        return 'Crafting Materials';
      case ItemCategory.resources:
        return 'Resources';
      case ItemCategory.cookingIngredients:
        return 'Cooking Ingredients';
      case ItemCategory.cookedFood:
        return 'Cooked Food';
      case ItemCategory.weapons:
        return 'Weapons';
      case ItemCategory.tools:
        return 'Tools';
      case ItemCategory.equipment:
        return 'Equipment';
      case ItemCategory.furniture:
        return 'Furniture';
      case ItemCategory.questItems:
        return 'Quest Items';
      case ItemCategory.trash:
        return 'Trash';
      case ItemCategory.misc:
        return 'Miscellaneous';
    }
  }

  /// Whether items in this category can have quality stars
  bool get canHaveQuality {
    return [
      ItemCategory.vegetables,
      ItemCategory.fruits,
      ItemCategory.flowers,
      ItemCategory.forage,
      ItemCategory.animalProducts,
      ItemCategory.fish,
      ItemCategory.ores,
      ItemCategory.minerals,
    ].contains(this);
  }

  /// Whether items in this category are edible
  bool get isEdible {
    return [
      ItemCategory.vegetables,
      ItemCategory.fruits,
      ItemCategory.forage,
      ItemCategory.animalProducts,
      ItemCategory.fish,
      ItemCategory.cookedFood,
    ].contains(this);
  }

  /// Whether items in this category can be planted
  bool get isPlantable {
    return this == ItemCategory.seeds;
  }

  /// Serialize to JSON
  String toJson() => name;

  /// Deserialize from JSON
  static ItemCategory fromJson(String json) {
    return ItemCategory.values.firstWhere(
      (c) => c.name == json,
      orElse: () => ItemCategory.misc,
    );
  }

  @override
  String toString() => displayName;
}
