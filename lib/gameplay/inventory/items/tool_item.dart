import '../entities/hand_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../entities/item_icon_data.dart';
import '../entities/enums/hand_item_quality.dart';
import '../entities/enums/hand_item_type.dart';

final class ToolItem extends HandItem {
  final String toolType;

  const ToolItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconData,
    required super.quality,
    required this.toolType,
  }) : super(
         maxStackSize: 1,
         isDroppable: true,
         isTradeable: true,
         type: HandItemType.tool,
       );

  @override
  Map<String, dynamic> toJson() {
    final baseData = super.toJson();
    return {...baseData, 'toolType': toolType};
  }

  factory ToolItem.fromJson(Map<String, dynamic> json) {
    final baseData = HandItem.fromJson(json);

    return ToolItem(
      id: baseData.id,
      name: baseData.name,
      description: baseData.description,
      quality: baseData.quality,
      baseValue: baseData.baseValue,
      iconData: baseData.iconData,
      toolType: json['toolType'] as String,
    );
  }

  ToolItem copyWith({
    HandItemId? id,
    String? name,
    String? description,
    int? baseValue,
    HandItemQuality? quality,
    ItemIconData? iconData,
    String? toolType,
  }) {
    return ToolItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      quality: quality ?? this.quality,
      iconData: iconData ?? this.iconData,
      toolType: toolType ?? this.toolType,
    );
  }

  @override
  String toString() =>
      'ToolItem(id: ${id.name}, name: $name, toolType: $toolType)';
}
