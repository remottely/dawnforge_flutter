import '../entities/hand/hand_item.dart';
import '../entities/hand/hand_item_id.dart';
import '../models/item_category.dart';
import '../models/item_quality.dart';
import '../entities/hand/hand_item_rarity.dart';
import '../entities/hand/hand_item_type.dart';

final class HarvestLootItem extends HandItem {
  final ItemCategory lootCategory;
  final ItemQuality quality;
  final int energyRestore;
  final int healthRestore;
  final String season;
  final bool regrows;
  final int regrowthDays;

  const HarvestLootItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = HandItemRarity.common,
    super.category = HandItemCategory.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    super.isDroppable = true,
    super.isTradeable = true,
    super.iconData,
    this.lootCategory = ItemCategory.vegetables,
    this.quality = ItemQuality.normal,
    this.energyRestore = 13,
    this.healthRestore = 5,
    required this.season,
    this.regrows = false,
    this.regrowthDays = 0,
  });

  @override
  int get sellValue => (baseValue * quality.priceMultiplier).round();

  int get effectiveEnergyRestore {
    return energyRestore;
  }

  int get effectiveHealthRestore {
    return healthRestore;
  }

  bool get isEdible => lootCategory.isEdible;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'name': name,
      'description': description,
      'category': category.toJson(),
      'lootCategory': lootCategory.toJson(),
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

  factory HarvestLootItem.fromJson(Map<String, dynamic> json) {
    return HarvestLootItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: HandItemRarity.fromJson(json['rarity'] as String? ?? 'common'),
      category: HandItemCategory.fromJson(
        json['category'] as String? ??
            'weapon', // TODO(kevin): change this default value
      ),
      lootCategory: ItemCategory.fromJson(
        json['category'] as String? ??
            'vegetables', // TODO(kevin): change this default value
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
  HarvestLootItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    HandItemRarity? rarity,
    HandItemCategory? category,
    ItemCategory? lootCategory,
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
    return HarvestLootItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      lootCategory: lootCategory ?? this.lootCategory,
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

  HarvestLootItem withQuality(ItemQuality newQuality) {
    return copyWith(quality: newQuality);
  }

  @override
  String toString() {
    final qualityStr = quality != ItemQuality.normal
        ? ' (${quality.displayName})'
        : '';
    return 'CropItem(id: ${id.name}, name: $name$qualityStr, category: ${category.name}, lootCategory: ${lootCategory.displayName}, season: $season)';
  }
}
