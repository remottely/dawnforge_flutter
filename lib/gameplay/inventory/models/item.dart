import 'item_rarity.dart';
import 'item_type.dart';

abstract class Item {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final ItemRarity rarity;
  final int maxStackSize;
  final int baseValue;
  final String iconPath;
  final bool isStackable;
  final bool isDroppable;
  final bool isTradeable;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.maxStackSize = 1,
    required this.baseValue,
    required this.iconPath,
    this.isStackable = false,
    this.isDroppable = true,
    this.isTradeable = true,
  });

  int get sellValue => (baseValue * rarity.sellValueMultiplier).round();

  Map<String, dynamic> toJson();

  Item copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Item(id: $id, name: $name, type: $type)';
}
