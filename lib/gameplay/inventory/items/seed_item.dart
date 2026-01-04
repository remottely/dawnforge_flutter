import '../entities/hand_item.dart';
import '../entities/hand_item_type.dart';
import '../models/item_icon_data.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

final class SeedItem extends HandItem {
  final String cropId;
  final int growthTime;
  final int yield;
  final String season;

  const SeedItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.cropSeed,
    super.isStackable = true,
    super.maxStackSize = 99,
    super.iconData,
    required this.cropId,
    required this.growthTime,
    this.yield = 1,
    this.season = 'any',
  });

  bool canPlantInSeason(String currentSeason) {
    return season == 'any' ||
        season.toLowerCase() == currentSeason.toLowerCase();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'rarity': rarity.toJson(),
      'baseValue': baseValue,
      'iconPath': iconPath,
      'maxStackSize': maxStackSize,
      'cropId': cropId,
      'growthTime': growthTime,
      'yield': yield,
      'season': season,
    };
  }

  factory SeedItem.fromJson(Map<String, dynamic> json) {
    return SeedItem(
      id: HandItemType.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 99,
      cropId: json['cropId'] as String,
      growthTime: json['growthTime'] as int,
      yield: json['yield'] as int? ?? 1,
      season: json['season'] as String? ?? 'any',
    );
  }

  @override
  SeedItem copyWith({
    HandItemType? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    int? maxStackSize,
    String? cropId,
    int? growthTime,
    int? yield,
    String? season,
    ItemIconData? iconData,
  }) {
    return SeedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      cropId: cropId ?? this.cropId,
      growthTime: growthTime ?? this.growthTime,
      yield: yield ?? this.yield,
      season: season ?? this.season,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'SeedItem(id: ${id.name}, name: $name, cropId: $cropId, growthTime: ${growthTime}d)';
}
