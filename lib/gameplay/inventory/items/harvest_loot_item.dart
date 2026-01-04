import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/enums/loot_category.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class HarvestLootItem extends HandItem {
  final LootCategory category;
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
    super.quality = HandItemQuality.normal,
    super.type = HandItemType.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    super.isDroppable = true,
    super.isTradeable = true,
    super.iconData,
    this.category = LootCategory.vegetable,
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

  bool get isEdible => category.isEdible;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'category': category.toJson(),
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
      quality: HandItemQuality.fromJson(json['quality'] as String? ?? 'common'),
      type: HandItemType.fromJson(
        json['type'] as String? ??
            'weapon', // TODO(kevin): change this default value
      ),
      category: LootCategory.fromJson(
        json['category'] as String? ??
            'vegetables', // TODO(kevin): change this default value
      ),
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
    HandItemQuality? quality,
    HandItemType? type,
    LootCategory? category,
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
      quality: quality ?? this.quality,
      type: type ?? this.type,
      category: category ?? this.category,
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

  HarvestLootItem withQuality(HandItemQuality newQuality) {
    return copyWith(quality: newQuality);
  }

  @override
  String toString() {
    final rarityStr = quality != HandItemQuality.normal
        ? ' (${quality.displayName})'
        : '';
    return 'CropItem(id: ${id.name}, name: $name$rarityStr, type: ${type.name}, category: ${category.displayName}, season: $season)';
  }
}
