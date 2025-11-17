import '../models/item.dart';
import '../models/item_category.dart';
import '../models/item_quality.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

/// Item representing harvested crops from farming.
///
/// CropItems are different from MaterialItems because they:
/// - Have quality levels (normal, silver, gold, iridium)
/// - Can be eaten to restore energy
/// - Are used in cooking recipes
/// - Are part of the farming collection
///
/// Examples: Parsnip, Cauliflower, Melon, Pumpkin, Corn
final class CropItem extends Item {
  /// Category of this crop (vegetables, fruits, flowers)
  final ItemCategory category;

  /// Quality of this crop harvest
  final ItemQuality quality;

  /// Energy restored when eaten (base value, modified by quality)
  final int energyRestore;

  /// Health restored when eaten (base value, modified by quality)
  final int healthRestore;

  /// Season this crop grows in (spring, summer, fall, winter, any)
  final String season;

  /// Whether this crop regrows after harvest (like corn, berries)
  final bool regrows;

  /// Days between regrowth harvests (0 if doesn't regrow)
  final int regrowthDays;

  /// Creates a crop item
  const CropItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    super.isDroppable = true,
    super.isTradeable = true,
    this.category = ItemCategory.vegetables,
    this.quality = ItemQuality.normal,
    this.energyRestore = 13,
    this.healthRestore = 5,
    required this.season,
    this.regrows = false,
    this.regrowthDays = 0,
  });

  /// Sell value with quality multiplier applied
  @override
  int get sellValue => (baseValue * quality.priceMultiplier).round();

  /// Energy restore with quality bonus
  int get effectiveEnergyRestore {
    // Quality doesn't affect energy/health in Stardew Valley
    return energyRestore;
  }

  /// Health restore with quality bonus
  int get effectiveHealthRestore {
    return healthRestore;
  }

  /// Can this crop be eaten?
  bool get isEdible => category.isEdible;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'category': category.toJson(),
      'rarity': rarity.toJson(),
      'quality': quality.toJson(),
      'baseValue': baseValue,
      'iconPath': iconPath,
      'maxStackSize': maxStackSize,
      'isStackable': isStackable,
      'isDroppable': isDroppable,
      'isTradeable': isTradeable,
      'energyRestore': energyRestore,
      'healthRestore': healthRestore,
      'season': season,
      'regrows': regrows,
      'regrowthDays': regrowthDays,
    };
  }

  /// Creates crop from JSON
  factory CropItem.fromJson(Map<String, dynamic> json) {
    return CropItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String? ?? 'common'),
      category: ItemCategory.fromJson(
        json['category'] as String? ?? 'vegetables',
      ),
      quality: ItemQuality.fromJson(json['quality'] as String? ?? 'normal'),
      maxStackSize: json['maxStackSize'] as int? ?? 999,
      isStackable: json['isStackable'] as bool? ?? true,
      isDroppable: json['isDroppable'] as bool? ?? true,
      isTradeable: json['isTradeable'] as bool? ?? true,
      energyRestore: json['energyRestore'] as int? ?? 13,
      healthRestore: json['healthRestore'] as int? ?? 5,
      season: json['season'] as String,
      regrows: json['regrows'] as bool? ?? false,
      regrowthDays: json['regrowthDays'] as int? ?? 0,
    );
  }

  @override
  CropItem copyWith({
    String? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    ItemCategory? category,
    ItemQuality? quality,
    int? maxStackSize,
    bool? isStackable,
    bool? isDroppable,
    bool? isTradeable,
    int? energyRestore,
    int? healthRestore,
    String? season,
    bool? regrows,
    int? regrowthDays,
  }) {
    return CropItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      quality: quality ?? this.quality,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      isStackable: isStackable ?? this.isStackable,
      isDroppable: isDroppable ?? this.isDroppable,
      isTradeable: isTradeable ?? this.isTradeable,
      energyRestore: energyRestore ?? this.energyRestore,
      healthRestore: healthRestore ?? this.healthRestore,
      season: season ?? this.season,
      regrows: regrows ?? this.regrows,
      regrowthDays: regrowthDays ?? this.regrowthDays,
    );
  }

  /// Create copy with different quality level
  CropItem withQuality(ItemQuality newQuality) {
    return copyWith(quality: newQuality);
  }

  @override
  String toString() {
    final qualityStr = quality != ItemQuality.normal
        ? ' (${quality.displayName})'
        : '';
    return 'CropItem(id: $id, name: $name$qualityStr, category: ${category.displayName}, season: $season)';
  }
}
