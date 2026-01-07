import 'package:flutter/material.dart';

import '../entities/hand_item.dart';
import '../entities/data/item_icon_data.dart';
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
         isTradeable: false,
         type: HandItemType.weapon,
       );

  @override
  Map<String, dynamic> toJson() {
    final baseData = super.toJson();
    return {
      ...baseData,
      'damage': damage,
    };
  }

  @protected
  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    final baseData = HandItem.fromJson(json);

    return WeaponItem(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      quality: baseData.quality,
      baseValue: baseData.baseValue,
      iconData: baseData.iconData,
      damage: json['damage'] as int,
    );
  }

  WeaponItem copyWith({
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    ItemIconData? iconData,
    int? damage,
  }) {
    return WeaponItem(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      iconData: iconData ?? this.iconData,
      damage: damage ?? this.damage,
    );
  }
}
