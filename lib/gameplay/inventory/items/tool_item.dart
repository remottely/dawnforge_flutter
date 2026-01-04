import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class ToolItem extends HandItem {
  final String toolType;
  final int powerLevel;

  const ToolItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    super.quality = HandItemQuality.normal,
    super.type = HandItemType.tool,
    required super.iconData,
    required this.toolType,
    this.powerLevel = 1,
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
      'toolType': toolType,
      'powerLevel': powerLevel,
    };
  }

  factory ToolItem.fromJson(Map<String, dynamic> json) {
    return ToolItem(
      id: HandItemId.fromJson(json['id'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      quality: HandItemQuality.fromJson(json['quality'] as String),
      toolType: json['toolType'] as String,
      powerLevel: json['powerLevel'] as int? ?? 1,
      iconData: ItemIconData.fromJson(json['iconData'] as Map<String, dynamic>),
    );
  }

  @override
  ToolItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    String? toolType,
    int? powerLevel,
    ItemIconData? iconData,
  }) {
    return ToolItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      toolType: toolType ?? this.toolType,
      powerLevel: powerLevel ?? this.powerLevel,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() =>
      'ToolItem(id: ${id.name}, name: $name, toolType: $toolType)';
}
