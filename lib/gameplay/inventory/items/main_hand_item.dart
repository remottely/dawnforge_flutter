import '../entities/hand_item_type.dart';
import '../entities/hand_item.dart';
import '../models/item_icon_data.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

final class MainHandItem extends HandItem {
  final int damage;
  final double attackSpeed;
  final double critChance;
  final double critMultiplier;
  final HandItemType equippedHandType;
  final String? cropId;

  const MainHandItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.weapon,
    super.iconData,
    required this.damage,
    this.attackSpeed = 1.0,
    this.critChance = 0.05,
    this.critMultiplier = 1.5,
    required this.equippedHandType,
    this.cropId,
    super.isStackable = false,
    super.maxStackSize = 1,
  });

  double get dps {
    final avgDamage = damage * (1 + critChance * (critMultiplier - 1));
    return avgDamage * attackSpeed;
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
      'damage': damage,
      'attackSpeed': attackSpeed,
      'critChance': critChance,
      'critMultiplier': critMultiplier,
      'equippedHandType': equippedHandType.toJson(),
      if (cropId != null) 'cropId': cropId,
      'isStackable': isStackable,
      'maxStackSize': maxStackSize,
    };
  }

  factory MainHandItem.fromJson(Map<String, dynamic> json) {
    return MainHandItem(
      id: HandItemType.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      damage: json['damage'] as int,
      attackSpeed: (json['attackSpeed'] as num?)?.toDouble() ?? 1.0,
      critChance: (json['critChance'] as num?)?.toDouble() ?? 0.05,
      critMultiplier: (json['critMultiplier'] as num?)?.toDouble() ?? 1.5,
      equippedHandType: HandItemType.fromJson(
        json['equippedHandType'] as String,
      ),
      cropId: json['cropId'] as String?,
      isStackable: json['isStackable'] as bool? ?? false,
      maxStackSize: json['maxStackSize'] as int? ?? 1,
    );
  }

  @override
  MainHandItem copyWith({
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    int? damage,
    double? attackSpeed,
    double? critChance,
    double? critMultiplier,
    HandItemType? equippedHandType,
    String? cropId,
    bool? isStackable,
    int? maxStackSize,
    ItemIconData? iconData,
  }) {
    return MainHandItem(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      damage: damage ?? this.damage,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      critChance: critChance ?? this.critChance,
      critMultiplier: critMultiplier ?? this.critMultiplier,
      equippedHandType: equippedHandType ?? this.equippedHandType,
      cropId: cropId ?? this.cropId,
      isStackable: isStackable ?? this.isStackable,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      iconData: iconData ?? this.iconData,
    );
  }
}
