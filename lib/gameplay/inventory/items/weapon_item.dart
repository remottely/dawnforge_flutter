import '../entities/enums/hand_item_id.dart';
import '../entities/hand_item.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class WeaponItem extends HandItem {
  final int damage;

  const WeaponItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required super.quality,
    required this.damage,
  }) : super(
         maxStackSize: 1,
         isDroppable: true,
         isTradeable: true,
         type: HandItemType.weapon,
       );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'quality': quality.toJson(),
      'baseValue': baseValue,
      'damage': damage,
      'isStackable': isStackable,
      'maxStackSize': maxStackSize,
    };
  }

  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    return WeaponItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      damage: json['damage'] as int,
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
    );
  }

  @override
  WeaponItem copyWith({
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    int? damage,
    double? attackSpeed,
    double? critChance,
    double? critMultiplier,
    String? cropId,
    bool? isStackable,
    int? maxStackSize,
    ItemIconData? iconData,
  }) {
    return WeaponItem(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      damage: damage ?? this.damage,
      iconData: iconData ?? this.iconData,
    );
  }
}
