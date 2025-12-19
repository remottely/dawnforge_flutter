import '../models/equipped_hand_type.dart';
import '../models/item.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

final class WeaponItem extends Item {
  final int damage;
  final double attackSpeed;
  final double critChance;
  final double critMultiplier;
  final EquippedHandType equippedHandType;
  final String? cropId;

  const WeaponItem({
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
  });

  double get dps {
    final avgDamage = damage * (1 + critChance * (critMultiplier - 1));
    return avgDamage * attackSpeed;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }

  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    return WeaponItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      damage: json['damage'] as int,
      attackSpeed: (json['attackSpeed'] as num?)?.toDouble() ?? 1.0,
      critChance: (json['critChance'] as num?)?.toDouble() ?? 0.05,
      critMultiplier: (json['critMultiplier'] as num?)?.toDouble() ?? 1.5,
      equippedHandType: EquippedHandType.fromJson(
        json['equippedHandType'] as String,
      ),
      cropId: json['cropId'] as String?,
    );
  }

  @override
  WeaponItem copyWith({
    String? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    int? damage,
    double? attackSpeed,
    double? critChance,
    double? critMultiplier,
    EquippedHandType? equippedHandType,
    String? cropId,
  }) {
    return WeaponItem(
      id: id ?? this.id,
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
    );
  }
}
