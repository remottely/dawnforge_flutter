import '../entities/data/item_icon_data.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';
import '../entities/enums/season.dart';
import '../entities/hand_item.dart';

final class SeedBagItem extends HandItem {
  final HandItemId cropId;
  final int growthTime; // TODO(Kevin): criar enum
  final int yield; // TODO(Kevin): criar enum
  final SeasonType requiredSeason;

  const SeedBagItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required this.cropId,
    required this.growthTime,
    required super.quality,
    required this.requiredSeason,
    this.yield = 1, // TODO(Kevin): entender oq é isso
  }) : super(maxStackSize: 99, isTradeable: true, type: HandItemType.cropSeed);

  bool canPlantInSeason(SeasonType currentSeason) {
    return requiredSeason.matches(currentSeason);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseData = super.toJson();
    return {
      ...baseData,
      'cropId': cropId.toJson(),
      'growthTime': growthTime,
      'yield': yield,
      'requiredSeason': requiredSeason.toJson(),
    };
  }

  factory SeedBagItem.fromJson(Map<String, dynamic> json) {
    final baseData = HandItem.fromJson(json);

    return SeedBagItem(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      quality: baseData.quality,
      baseValue: baseData.baseValue,
      iconData: baseData.iconData,
      cropId: HandItemId.fromJson(json['cropId'] as String),
      growthTime: json['growthTime'] as int,
      yield: json['yield'] as int? ?? 1,
      requiredSeason: SeasonType.fromJson(
        json['requiredSeason'] as String? ?? 'any',
      ),
    );
  }

  SeedBagItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    ItemIconData? iconData,
    HandItemId? cropId,
    int? growthTime,
    int? yield,
    SeasonType? requiredSeason,
  }) {
    return SeedBagItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      iconData: iconData ?? this.iconData,
      cropId: cropId ?? this.cropId,
      growthTime: growthTime ?? this.growthTime,
      yield: yield ?? this.yield,
      requiredSeason: requiredSeason ?? this.requiredSeason,
    );
  }

  @override
  String toString() =>
      'SeedItem(id: ${id.name}, name: $name, cropId: $cropId, growthTime: ${growthTime}d, season: ${requiredSeason.name})';
}
