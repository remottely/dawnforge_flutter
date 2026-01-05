import 'consumable_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/enums/loot_category.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';
import '../entities/enums/season.dart';
import '../entities/item_icon_data.dart';

final class HarvestLootItem extends ConsumableItem {
  final LootCategory category;
  final SeasonType seasonType;
  final int regrowthDays; // TODO(Kevin): improve this behavior

  const HarvestLootItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.quality,
    required super.iconData,
    required super.healthRestore,
    required super.staminaRestore,
    required this.category,
    required this.seasonType,
    required this.regrowthDays,
  }) : super(type: HandItemType.material);

  @override
  int get sellValue => (baseValue * quality.priceMultiplier).round();

  bool get isRegrows => regrowthDays > 0;

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
      'season': seasonType.toJson(),
      'regrowthDays': regrowthDays,
    };
  }

  factory HarvestLootItem.fromJson(Map<String, dynamic> json) {
    return HarvestLootItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      category: LootCategory.fromJson(json['category'] as String),
      staminaRestore: json['staminaRestore'] as int,
      healthRestore: json['healthRestore'] as int,
      seasonType: SeasonType.fromJson(json['season'] as String? ?? 'any'),
      regrowthDays: json['regrowthDays'] as int,
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
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
    HandItemType? type,
    LootCategory? category,
    bool? isStackable,
    bool? isDroppable,
    bool? isTradeable,
    SeasonType? season,
    int? regrowthDays,
  }) {
    return HarvestLootItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      category: category ?? this.category,
      staminaRestore: staminaRestore ?? this.staminaRestore,
      healthRestore: healthRestore ?? this.healthRestore,
      seasonType: season ?? this.seasonType,
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
    return 'HarvestLootItem(id: ${id.name}, name: $name$rarityStr, type: ${type.name}, category: ${category.displayName}, season: ${seasonType.name})';
  }
}
