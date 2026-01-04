import 'consumable_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/enums/loot_category.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';
import '../entities/item_icon_data.dart';

final class HarvestLootItem extends ConsumableItem {
  final LootCategory category;
  final String season;
  final bool regrows;
  final int regrowthDays;

  const HarvestLootItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    super.quality = HandItemQuality.normal,
    super.type = HandItemType.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    super.iconData,
    this.category = LootCategory.vegetable,
    super.isDroppable = true,
    super.isTradeable = true,
    super.healthRestore = 5,
    super.staminaRestore = 13,
    required this.season,
    this.regrows = false,
    this.regrowthDays = 0,
  });

  @override
  int get sellValue => (baseValue * quality.priceMultiplier).round();

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
      'maxStackSize': maxStackSize,
      'isStackable': isStackable,
      'isDroppable': isDroppable,
      'isTradeable': isTradeable,
      'staminaRestore': staminaRestore,
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
      staminaRestore: json['staminaRestore'] as int? ?? 13,
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
    HandItemQuality? quality,
    int? maxStackSize,
    int? healthRestore,
    int? staminaRestore,
    int? duration,
    ItemIconData? iconData,
    // Extra fields specific to HarvestLootItem
    HandItemType? type,
    LootCategory? category,
    bool? isStackable,
    bool? isDroppable,
    bool? isTradeable,
    String? season,
    bool? regrows,
    int? regrowthDays,
  }) {
    return HarvestLootItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      type: type ?? this.type,
      category: category ?? this.category,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      isStackable: isStackable ?? this.isStackable,
      isDroppable: isDroppable ?? this.isDroppable,
      isTradeable: isTradeable ?? this.isTradeable,
      staminaRestore: staminaRestore ?? this.staminaRestore,
      healthRestore: healthRestore ?? this.healthRestore,
      season: season ?? this.season,
      regrows: regrows ?? this.regrows,
      regrowthDays: regrowthDays ?? this.regrowthDays,
      iconData: iconData ?? this.iconData,
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
