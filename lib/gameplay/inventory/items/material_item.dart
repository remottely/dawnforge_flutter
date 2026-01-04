import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class MaterialItem extends HandItem {
  final String materialType;

  const MaterialItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    super.quality = HandItemQuality.normal,
    super.type = HandItemType.material,
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
      'quality': quality.toJson(),
      'baseValue': baseValue,
      'maxStackSize': maxStackSize,
      'materialType': materialType,
    };
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 999,
      materialType: json['materialType'] as String,
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
    String? materialType,
    ItemIconData? iconData,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      materialType: materialType ?? this.materialType,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'MaterialItem(id: ${id.name}, name: $name, materialType: $materialType)';
}
