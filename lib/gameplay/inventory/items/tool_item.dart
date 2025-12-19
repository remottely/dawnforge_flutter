import '../models/item.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

final class ToolItem extends Item {
  final String toolType;
  final int powerLevel;
  final int durability;
  final int maxDurability;

  const ToolItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.tool,
    super.iconData,
    required this.toolType,
    this.powerLevel = 1,
    required this.durability,
    required this.maxDurability,
  });

  bool get isBroken => durability <= 0;

  double get durabilityPercent => durability / maxDurability;

  ToolItem use([int amount = 1]) {
    return copyWith(durability: (durability - amount).clamp(0, maxDurability));
  }

  ToolItem repair([int amount = 10]) {
    return copyWith(durability: (durability + amount).clamp(0, maxDurability));
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
      'toolType': toolType,
      'powerLevel': powerLevel,
      'durability': durability,
      'maxDurability': maxDurability,
    };
  }

  factory ToolItem.fromJson(Map<String, dynamic> json) {
    return ToolItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      toolType: json['toolType'] as String,
      powerLevel: json['powerLevel'] as int? ?? 1,
      durability: json['durability'] as int,
      maxDurability: json['maxDurability'] as int,
    );
  }

  @override
  ToolItem copyWith({
    String? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    String? toolType,
    int? powerLevel,
    int? durability,
    int? maxDurability,
  }) {
    return ToolItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      toolType: toolType ?? this.toolType,
      powerLevel: powerLevel ?? this.powerLevel,
      durability: durability ?? this.durability,
      maxDurability: maxDurability ?? this.maxDurability,
    );
  }

  @override
  String toString() =>
      'ToolItem(id: $id, name: $name, toolType: $toolType, durability: $durability/$maxDurability)';
}
