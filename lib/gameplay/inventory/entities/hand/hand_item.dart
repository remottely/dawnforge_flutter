import 'hand_item_id.dart';
import '../../models/item_icon_data.dart';
import 'hand_item_rarity.dart';
import 'hand_item_type.dart';

abstract class HandItem {
  final HandItemId id;
  final String name;
  final String description;
  final HandItemCategory type;
  final HandItemRarity rarity;
  final int maxStackSize;
  final int baseValue;
  final String iconPath;
  final bool isStackable;
  final bool isDroppable;
  final bool isTradeable;
  final ItemIconData? iconData;

  const HandItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = HandItemRarity.common,
    this.maxStackSize = 1,
    required this.baseValue,
    required this.iconPath,
    this.isStackable = false,
    this.isDroppable = true,
    this.isTradeable = true,
    this.iconData,
  });

  int get sellValue => (baseValue * rarity.sellValueMultiplier).round();

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
