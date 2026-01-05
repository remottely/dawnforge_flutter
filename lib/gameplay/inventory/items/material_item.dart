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
    final baseData = super.toJson();
    return {...baseData, 'materialType': materialType.toJson()};
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    final baseData = HandItem.fromJson(json);

    return MaterialItem(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      quality: baseData.quality,
      baseValue: baseData.baseValue,
      iconData: baseData.iconData,
      materialType: MaterialType.fromJson(
        json['materialType'] as String? ?? 'unknown',
      ),
    );
  }

  MaterialItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    ItemIconData? iconData,
    MaterialType? materialType,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      iconData: iconData ?? this.iconData,
      materialType: materialType ?? this.materialType,
    );
  }

  @override
  String toString() =>
      'MaterialItem(id: ${id.name}, name: $name, materialType: ${materialType.name})';
}
