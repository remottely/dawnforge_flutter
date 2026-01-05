import 'enums/hand_item_id.dart';
import 'item_icon_data.dart';
import 'enums/hand_item_quality.dart';
import 'enums/hand_item_type.dart';

abstract class HandItem {
  final HandItemId id;
  final String name;
  final String description;
  final HandItemType type;
  final HandItemQuality quality;
  final int maxStackSize;
  final int baseValue;
  final bool isDroppable;
  final bool isTradeable;
  final ItemIconData iconData;

  const HandItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.baseValue,
    required this.maxStackSize,
    required this.quality,
    required this.isDroppable,
    required this.isTradeable,
    required this.iconData,
  });

  bool get isStackable => maxStackSize > 1;

  int get sellValue => (baseValue * quality.priceMultiplier).round();

  /// Serialization for persistence (D2)
  Map<String, dynamic> toJson();

  /// Create a copy with modifications
  HandItem copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Item(id: ${id.name}, name: $name, type: $type)';
}
