import '../entities/item.dart';
import '../models/equipped_hand_type.dart';
import '../models/item_icon_data.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

final class MaterialItem extends Item {
  final String materialType;

  const MaterialItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    super.iconData,
    required this.materialType,
  });

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
      'materialType': materialType,
    };
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: EquippedHandType.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 999,
      materialType: json['materialType'] as String,
    );
  }

  @override
  MaterialItem copyWith({
    EquippedHandType? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    int? maxStackSize,
    String? materialType,
    ItemIconData? iconData,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      materialType: materialType ?? this.materialType,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'MaterialItem(id: ${id.name}, name: $name, materialType: $materialType)';
}
