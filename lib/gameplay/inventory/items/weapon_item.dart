import '../entities/enums/hand_item_id.dart';
import '../entities/hand_item.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class WeaponItem extends HandItem {
  final int damage;
  final double attackSpeed;

  const WeaponItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required super.quality,
    required this.damage,
    required this.attackSpeed,
    // this.attackSpeed = 1.0,
  }) : super(
         maxStackSize: 1,
         isDroppable: true,
         isTradeable: true,
         type: HandItemType.weapon,
       );

  double get dps {
    final avgDamage = damage;
    return avgDamage * attackSpeed;
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
      'damage': damage,
      'attackSpeed': attackSpeed,
      'critChance': critChance,
      'critMultiplier': critMultiplier,
      if (cropId != null) 'cropId': cropId,
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
      attackSpeed: (json['attackSpeed'] as num?)?.toDouble() ?? 1.0,
      critChance: (json['critChance'] as num?)?.toDouble() ?? 0.05,
      critMultiplier: (json['critMultiplier'] as num?)?.toDouble() ?? 1.5,
      cropId: json['cropId'] as String?,
      isStackable: json['isStackable'] as bool? ?? false,
      maxStackSize: json['maxStackSize'] as int? ?? 1,
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
      attackSpeed: attackSpeed ?? this.attackSpeed,
      critChance: critChance ?? this.critChance,
      critMultiplier: critMultiplier ?? this.critMultiplier,
      cropId: cropId ?? this.cropId,
      isStackable: isStackable ?? this.isStackable,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      iconData: iconData ?? this.iconData,
    );
  }
}
