import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:flutter/material.dart';

class InventoryOverlay extends StatelessWidget {
  const InventoryOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InventoryState.instance.isVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return child!;
      },
      child: _buildOverlay(),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _buildInventoryGrid(),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryGrid() {
    final manager = InventoryManager.instance;
    const int slotsPerRow = 10;
    const double slotSize = 40.0;
    const double spacing = 4.0;

    final int rows = (manager.maxSlots / slotsPerRow).ceil();

    return ValueListenableBuilder<Map<EquipmentSlotType, Item?>>(
      valueListenable: EquipmentState.instance.equipment,
      builder: (context, equipmentMap, child) {
        return SizedBox(
          width: (slotSize * slotsPerRow) + (spacing * (slotsPerRow - 1)) + 16,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              manager.maxSlots,
              (index) {
                final slot = manager.getSlotByIndex(index);
                return _buildInventorySlot(
                  slot?.item,
                  slot?.quantity,
                  slotSize,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventorySlot(Item? item, int? quantity, double slotSize) {
    // Check if item is equipped
    EquipmentSlotType? equippedSlot;
    Color slotColor = item != null
        ? Colors.blue.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2);

    if (item != null) {
      equippedSlot = EquipmentManager.instance.getEquippedSlotForItem(item.id);
      if (equippedSlot != null) {
        // Red background for mainHand, green for offHand
        slotColor = equippedSlot == EquipmentSlotType.mainHand
            ? Colors.red.withOpacity(0.5)
            : Colors.green.withOpacity(0.5);
      }
    }

    return Container(
      width: slotSize,
      height: slotSize,
      decoration: BoxDecoration(
        color: slotColor,
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          if (item != null) ...[
            // Item icon or abbreviation
            Center(
              child: item.iconData != null
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ItemSpriteWidget(
                        iconData: item.iconData,
                        size: slotSize - 8,
                      ),
                    )
                  : Text(
                      _abbreviateItemName(item.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Normal',
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            // Quantity indicator
            if (quantity != null && quantity > 1)
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'x$quantity',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 8,
                      fontFamily: 'Normal',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _abbreviateItemName(String name) {
    if (name.length <= 4) return name;

    final words = name.split(' ');
    if (words.length > 1) {
      return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
    }

    return name.substring(0, 4).toUpperCase();
  }
}
