import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_type.dart';

import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';

class ConsumableItem extends HandItem {
  final int healthRestore;
  final int staminaRestore;

  const ConsumableItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required super.quality,
    required super.type,
    required this.healthRestore,
    required this.staminaRestore,
  }) : super(maxStackSize: 99, isDroppable: true, isTradeable: true);

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
      'healthRestore': healthRestore,
      'staminaRestore': staminaRestore,
    };
  }

  factory ConsumableItem.fromJson(Map<String, dynamic> json) {
    return ConsumableItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      type: HandItemType.fromJson(json['type'] as String),
      healthRestore: json['healthRestore'] as int,
      staminaRestore: json['staminaRestore'] as int,
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
    );
  }

  @override
  ConsumableItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    HandItemType? type,
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
      quality: quality ?? this.quality,
      healthRestore: healthRestore ?? this.healthRestore,
      staminaRestore: staminaRestore ?? this.staminaRestore,
      iconData: iconData ?? this.iconData,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'ConsumableItem(id: ${id.name}, name: $name, hp: +$healthRestore, stamina: +$staminaRestore)';
}
