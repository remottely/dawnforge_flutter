# Inventory System Refactoring - Stardew Valley Rules

## Overview

The inventory system has been refactored to follow Stardew Valley's professional patterns and game design rules, providing a realistic farming RPG experience.

## Key Additions

### 1. **Item Quality System**

Following Stardew Valley's star rating system:

```dart
enum ItemQuality {
  normal,   // No star - 1.0x price
  silver,   // 1 star - 1.25x price
  gold,     // 2 stars - 1.5x price
  iridium,  // 3 stars - 2.0x price
}
```

**Quality Determination:**

- Based on farming skill level
- Enhanced by fertilizer quality
- Random chance system per harvest

### 2. **Detailed Item Categories**

Expanded from 5 generic types to 22 specific categories:

```dart
enum ItemCategory {
  // Farming
  vegetables, fruits, flowers,

  // Foraging
  forage, seeds,

  // Animal Products
  animalProducts, artisanGoods,

  // Fishing
  fish, fishingEquipment,

  // Mining
  ores, minerals, geodes,

  // Crafting
  craftingMaterials, resources,

  // Cooking
  cookingIngredients, cookedFood,

  // Equipment
  weapons, tools, equipment,

  // Special
  furniture, questItems, trash, misc
}
```

### 3. **CropItem Class**

New specialized class for harvested crops:

```dart
class CropItem extends Item {
  final ItemCategory category;
  final ItemQuality quality;
  final int energyRestore;
  final int healthRestore;
  final String season;
  final bool regrows;  // Like corn, berries
  final int regrowthDays;
}
```

**Features:**

- Quality-based pricing
- Energy/health restoration
- Season awareness
- Regrowth support

### 4. **Professional Price Service**

Dynamic pricing system with profession bonuses:

```dart
class ItemPriceService {
  int calculateSellPrice(Item item, {
    bool isShippingBin = true,
    ItemQuality? quality,
  });

  ItemQuality determineHarvestQuality({
    required int farmingLevel,
    int fertilizerQualityBoost = 0,
  });
}
```

**Profession Bonuses:**

- **Tiller**: +10% for crops
- **Rancher**: +20% for animal products
- **Artisan**: +40% for artisan goods
- **Angler**: +50% for fish

### 5. **Expandable Inventory**

Stardew Valley's backpack upgrade system:

```dart
class InventoryManager {
  // Starting: 12 slots
  // First upgrade: 24 slots
  // Second upgrade: 36 slots

  bool upgradeInventory();
  bool get canUpgrade;
}
```

### 6. **Comprehensive Constants**

All Stardew Valley values centralized:

```dart
class InventoryConstants {
  // Inventory sizes
  static const kDefaultInventorySize = 12;
  static const kFirstUpgradeSize = 24;
  static const kSecondUpgradeSize = 36;
  static const kMaxInventorySize = 36;

  // Stack sizes
  static const kDefaultStackSize = 999;
  static const kSeedStackSize = 999;
  static const kResourceStackSize = 999;

  // Quality multipliers
  static const kNormalQualityMultiplier = 1.0;
  static const kSilverQualityMultiplier = 1.25;
  static const kGoldQualityMultiplier = 1.5;
  static const kIridiumQualityMultiplier = 2.0;

  // Profession bonuses
  static const kTillerProfessionBonus = 0.10;
  static const kRancherProfessionBonus = 0.20;
  static const kArtisanProfessionBonus = 0.40;
  static const kAnglerProfessionBonus = 0.50;

  // Energy/health values
  static const kLowTierEnergyRestore = 13;
  static const kMidTierEnergyRestore = 25;
  static const kHighTierEnergyRestore = 38;
}
```

## New Structure

### Before

```
inventory/
├── inventory_manager.dart
├── item_factory.dart
├── equipment_manager.dart
├── models/
│   ├── item.dart
│   ├── item_type.dart (5 types)
│   └── item_rarity.dart
└── items/
    ├── weapon_item.dart
    ├── tool_item.dart
    ├── consumable_item.dart
    ├── material_item.dart
    └── seed_item.dart
```

### After

```
inventory/
├── constants/
│   └── inventory_constants.dart     ✅ NEW
├── services/
│   └── item_price_service.dart      ✅ NEW
├── models/
│   ├── item.dart
│   ├── item_type.dart
│   ├── item_rarity.dart
│   ├── item_quality.dart            ✅ NEW
│   ├── item_category.dart           ✅ NEW (22 categories)
│   ├── inventory_slot.dart
│   └── equipment_slot.dart
├── items/
│   ├── weapon_item.dart
│   ├── tool_item.dart
│   ├── consumable_item.dart
│   ├── material_item.dart
│   ├── seed_item.dart
│   └── crop_item.dart               ✅ NEW
├── inventory_manager.dart           ♻️ Enhanced
├── item_factory.dart                ♻️ Enhanced
└── equipment_manager.dart
```

## Usage Examples

### 1. Creating Quality Crops

```dart
// Create a gold quality parsnip
final parsnip = CropItem(
  id: 'parsnip',
  name: 'Parsnip',
  description: 'A spring crop with a nice earthy flavor.',
  baseValue: 35,
  iconPath: 'crops/parsnip.png',
  category: ItemCategory.vegetables,
  quality: ItemQuality.gold,  // 1.5x price
  season: 'spring',
  energyRestore: 25,
  healthRestore: 11,
);

print(parsnip.sellValue);  // 52 (35 * 1.5)
```

### 2. Determining Harvest Quality

```dart
final priceService = ItemPriceService.instance;

// Player with farming level 10 and quality fertilizer
final quality = priceService.determineHarvestQuality(
  farmingLevel: 10,
  fertilizerQualityBoost: 2,  // Quality fertilizer
);

// Chances: 12% iridium, 7% gold, 2% silver, 79% normal
```

### 3. Calculating Prices with Professions

```dart
final priceService = ItemPriceService.instance;

// Enable Tiller profession (+10% for crops)
priceService.setProfessions(tiller: true);

final goldParsnip = CropItem(..., quality: ItemQuality.gold);

// Shipping bin price (full value)
final shippingPrice = priceService.calculateSellPrice(
  goldParsnip,
  isShippingBin: true,
);
// 57 = 35 * 1.5 (gold) * 1.1 (tiller)

// Shop price (50% of base)
final shopPrice = priceService.calculateSellPrice(
  goldParsnip,
  isShippingBin: false,
);
// 29 = 35 * 1.5 (gold) * 1.1 (tiller) * 0.5 (shop)
```

### 4. Upgrading Inventory

```dart
final inventory = InventoryManager.instance;

print(inventory.maxSlots);  // 12 (starting)

// Buy first backpack upgrade
inventory.upgradeInventory();
print(inventory.maxSlots);  // 24

// Buy second backpack upgrade
inventory.upgradeInventory();
print(inventory.maxSlots);  // 36

// Can't upgrade further
print(inventory.canUpgrade);  // false
```

### 5. Smart Item Factory

```dart
// items_database.json
{
  "parsnip": {
    "id": "parsnip",
    "name": "Parsnip",
    "type": "material",
    "category": "vegetables",  // Triggers CropItem creation
    "baseValue": 35,
    ...
  }
}

// Automatically creates CropItem for farming categories
final item = ItemFactory.createItem('parsnip');
if (item is CropItem) {
  print('Energy: ${item.energyRestore}');
  print('Quality: ${item.quality.displayName}');
}
```

## Stardew Valley Rules Implemented

### ✅ Inventory System

- [x] 12 starting slots
- [x] Backpack upgrades (12 → 24 → 36)
- [x] Stack limit of 999 for most items
- [x] Non-stackable equipment/tools

### ✅ Quality System

- [x] 4 quality levels (Normal, Silver, Gold, Iridium)
- [x] Quality-based price multipliers (1.0x, 1.25x, 1.5x, 2.0x)
- [x] Farming level affects quality chance
- [x] Fertilizer boosts quality

### ✅ Profession System

- [x] Tiller: +10% crop value
- [x] Rancher: +20% animal product value
- [x] Artisan: +40% artisan goods value
- [x] Angler: +50% fish value

### ✅ Pricing System

- [x] Shop sells at 50% of base value
- [x] Shipping bin gives full value
- [x] Quality multipliers apply
- [x] Profession bonuses apply

### ✅ Crop Properties

- [x] Season-specific crops
- [x] Energy/health restoration
- [x] Regrowth support (corn, berries, etc.)
- [x] Category-based organization

## Testing Examples

```dart
void testQualitySystem() {
  final service = ItemPriceService.instance;

  // Test quality determination
  for (var level = 0; level <= 15; level++) {
    final quality = service.determineHarvestQuality(
      farmingLevel: level,
      fertilizerQualityBoost: 0,
    );
    print('Level $level: ${quality.displayName}');
  }
}

void testProfessionBonuses() {
  final service = ItemPriceService.instance;
  final parsnip = CropItem(...);

  // Without profession
  print(service.calculateSellPrice(parsnip));  // 35

  // With Tiller
  service.setProfessions(tiller: true);
  print(service.calculateSellPrice(parsnip));  // 38 (+10%)
}

void testInventoryUpgrade() {
  final inventory = InventoryManager.instance;

  assert(inventory.maxSlots == 12);
  inventory.upgradeInventory();
  assert(inventory.maxSlots == 24);
  inventory.upgradeInventory();
  assert(inventory.maxSlots == 36);
  assert(!inventory.canUpgrade);
}
```

## Migration Guide

### For Existing Crops

**Old MaterialItem:**

```dart
final carrot = MaterialItem(
  id: 'carrot',
  name: 'Carrot',
  materialType: 'crop',
  ...
);
```

**New CropItem:**

```dart
final carrot = CropItem(
  id: 'carrot',
  name: 'Carrot',
  category: ItemCategory.vegetables,
  quality: ItemQuality.normal,
  season: 'spring',
  energyRestore: 25,
  ...
);
```

### For Price Calculation

**Old:**

```dart
final price = item.sellValue;
```

**New (with quality and professions):**

```dart
final price = ItemPriceService.instance.calculateSellPrice(
  item,
  isShippingBin: true,
);
```

## Future Enhancements

### Short Term

- [ ] Implement energy/stamina consumption on eating
- [ ] Add buff system for cooked food
- [ ] Implement trash category with negative values
- [ ] Add fishing quality system

### Medium Term

- [ ] Add bundle system (Community Center)
- [ ] Implement gifting with NPC preferences
- [ ] Add seasonal crop restrictions
- [ ] Create artisan goods conversion

### Long Term

- [ ] Full cooking system with recipes
- [ ] Animal product quality
- [ ] Preserve jar and keg mechanics
- [ ] Crop achievement tracking

## Conclusion

The inventory system now follows Stardew Valley's professional game design:

✅ **Quality System** - Items have value tiers
✅ **Profession Bonuses** - Specialization matters
✅ **Expandable Inventory** - Progression system
✅ **Detailed Categories** - 22 item classifications
✅ **Smart Pricing** - Context-aware values
✅ **Stardew Valley Constants** - Authentic values

The system is now production-ready for a farming RPG! 🌾⭐
