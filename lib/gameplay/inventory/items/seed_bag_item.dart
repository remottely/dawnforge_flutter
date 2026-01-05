import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class SeedBagItem extends HandItem {
  final HandItemId cropId;
  final int growthTime;
  final int yield;
  final String season; // TODO(Kevin): change to enum

  const SeedBagItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required this.cropId,
    required this.growthTime,
    required super.quality,
    required this.season,
    // this.season = 'any', // TODO(Kevin): put it as required
    this.yield = 1, // TODO(Kevin): entender oq é isso
  }) : super(
         maxStackSize: 99,
         isDroppable: true,
         isTradeable: true,
         type: HandItemType.cropSeed,
       );

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
      'quality': quality.toJson(),
      'baseValue': baseValue,
      'maxStackSize': maxStackSize,
      'cropId': cropId.toJson(),
      'growthTime': growthTime,
      'yield': yield,
      'season': season,
    };
  }

  factory SeedBagItem.fromJson(Map<String, dynamic> json) {
    return SeedBagItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 99,
      cropId: HandItemId.fromJson(json['cropId'] as String),
      growthTime: json['growthTime'] as int,
      yield: json['yield'] as int? ?? 1,
      season: json['season'] as String? ?? 'any',
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
    );
  }

  @override
  SeedBagItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    int? maxStackSize,
    HandItemId? cropId,
    int? growthTime,
    int? yield,
    String? season,
    ItemIconData? iconData,
  }) {
    return SeedBagItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
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
