import '../entities/enums/hand_item_id.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';
import '../entities/enums/material_type.dart';
import '../entities/hand_item.dart';
import '../entities/item_icon_data.dart';

final class MaterialItem extends HandItem {
  final MaterialType materialType;

  const MaterialItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required super.quality,
    required this.materialType,
  }) : super(
         maxStackSize: 99,
         isDroppable: true,
         isTradeable: true,
         type: HandItemType.material,
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
      'maxStackSize': maxStackSize,
      'materialType': materialType.toJson(),
    };
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      materialType:
          MaterialType.fromJson(json['materialType'] as String? ?? 'unknown'),
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
    );
  }

  @override
  MaterialItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    int? maxStackSize,
    MaterialType? materialType,
    ItemIconData? iconData,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      materialType: materialType ?? this.materialType,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'MaterialItem(id: ${id.name}, name: $name, materialType: ${materialType.name})';
}
