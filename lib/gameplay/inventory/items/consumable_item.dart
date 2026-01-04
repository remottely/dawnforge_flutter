import '../entities/hand/hand_item.dart';
import '../entities/hand/hand_item_id.dart';
import '../models/item_icon_data.dart';
import '../entities/hand/hand_item_rarity.dart';
import '../entities/hand/hand_item_type.dart';

final class ConsumableItem extends HandItem {
  final int healthRestore;
  final int staminaRestore;

  const ConsumableItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = HandItemRarity.common,
    super.type = HandItemType.consumable,
    super.isStackable = true,
    super.maxStackSize = 99,
    super.iconData,
    this.healthRestore = 0,
    this.staminaRestore = 0,
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
      'healthRestore': healthRestore,
      'staminaRestore': staminaRestore,
    };
  }

  factory ConsumableItem.fromJson(Map<String, dynamic> json) {
    final healAmount = json['healAmount'] as int?;

    return ConsumableItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: HandItemRarity.fromJson(json['rarity'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 99,
      // Fallback: some data uses healAmount instead of healthRestore/staminaRestore
      healthRestore: json['healthRestore'] as int? ?? healAmount ?? 0,
      staminaRestore: json['staminaRestore'] as int? ?? healAmount ?? 0,
    );
  }

  @override
  ConsumableItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    HandItemRarity? rarity,
    int? maxStackSize,
    int? healthRestore,
    int? staminaRestore,
    int? duration,
    ItemIconData? iconData,
  }) {
    return ConsumableItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      healthRestore: healthRestore ?? this.healthRestore,
      staminaRestore: staminaRestore ?? this.staminaRestore,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'ConsumableItem(id: ${id.name}, name: $name, hp: +$healthRestore, stamina: +$staminaRestore)';
}
