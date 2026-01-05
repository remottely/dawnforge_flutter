import 'consumable_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/enums/loot_category.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';
import '../entities/enums/season.dart';
import '../entities/data/item_icon_data.dart';

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
    final baseData = super.toJson();
    return {
      ...baseData,
      'category': category.toJson(),
      'seasonType': seasonType.toJson(),
      'regrowthDays': regrowthDays,
    };
  }

  factory HarvestLootItem.fromJson(Map<String, dynamic> json) {
    final baseData = ConsumableItem.fromJson(json);

    return HarvestLootItem(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      quality: baseData.quality,
      baseValue: baseData.baseValue,
      iconData: baseData.iconData,
      healthRestore: baseData.healthRestore,
      staminaRestore: baseData.healthRestore,
      category: LootCategory.fromJson(json['category'] as String),
      seasonType: SeasonType.fromJson(json['seasonType'] as String? ?? 'any'),
      regrowthDays: json['regrowthDays'] as int,
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
    bool? isTradeable,
    SeasonType? seasonType,
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
      seasonType: seasonType ?? this.seasonType,
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
