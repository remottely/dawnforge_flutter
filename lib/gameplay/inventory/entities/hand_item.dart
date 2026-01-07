import 'package:flutter/foundation.dart';

import 'enums/hand_item_id.dart';
import 'data/item_icon_data.dart';
import 'enums/hand_item_quality.dart';
import 'enums/hand_item_type.dart';

class HandItem {
  final HandItemId id;
  final String name;
  final String description;
  final HandItemType type;
  final HandItemQuality quality;
  final int baseValue;
  final int maxStackSize;
  final bool isTradeable;
  final ItemIconData iconData;

  const HandItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.quality,
    required this.baseValue,
    required this.maxStackSize,
    required this.isTradeable,
    required this.iconData,
  });

  bool get isStackable => maxStackSize > 1;

  int get sellValue => (baseValue * quality.priceMultiplier).round();

  @protected
  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'quality': quality.toJson(),
      'baseValue': baseValue,
      'maxStackSize': maxStackSize,
      'isTradeable': isTradeable,
      'iconData': iconData.toJson(),
    };
  }

  @protected
  factory HandItem.fromJson(Map<String, dynamic> json) {
    return HandItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      type: HandItemType.fromJson(json['type'] as String),
      quality: HandItemQuality.fromJson(json['quality'] as String),
      baseValue: json['baseValue'] as int,
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
      maxStackSize: json['maxStackSize'] as int,
      isTradeable: json['isTradeable'] as bool,
    );
  }

  @override
  String toString() => 'Item(id: ${id.name}, name: $name, type: $type)'; // TODO(Kevin): complete this method
}
