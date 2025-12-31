import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/inventory_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:flutter/material.dart';

class InventoryOverlay extends ResponsiveOverlayBase {
  const InventoryOverlay({super.key});

  @override
  String get overlayId => 'inventory';

  @override
  ValueNotifier<bool> get visibilityNotifier =>
      InventoryState.instance.isVisible;

  @override
  OverlayPosition getOverlayPosition(BuildContext context) {
    final margin = getResponsiveMargin(context);
    return OverlayPosition.bottomRight(
      margin: margin,
      safeAreaPadding: EdgeInsets.all(margin / 2),
    );
  }

  @override
  Widget buildOverlayContent(BuildContext context, ResponsiveOverlayData data) {
    return Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.all(data.padding),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: data.isSmallScreen ? 1.5 : 2,
            ),
            borderRadius: BorderRadius.circular(data.isSmallScreen ? 3 : 4),
          ),
          child: _buildInventoryGrid(context, data),
        ),
      ),
    );
  }

  Widget _buildInventoryGrid(BuildContext context, ResponsiveOverlayData data) {
    // Listen to inventory changes with the actual slots list
    return ValueListenableBuilder<List<InventorySlot>>(
      valueListenable: getIt<InventoryManager>().slotsNotifier,
      builder: (context, slots, _) {
        // Sempre renderiza em 2 linhas com 6 slots cada
        const slotsPerRow = 6;
        final totalRows = (slots.length / slotsPerRow).ceil();

        return ValueListenableBuilder<Map<EquipmentSlotType, Item?>>(
          valueListenable: EquipmentState.instance.equipment,
          builder: (context, equipmentMap, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalRows, (rowIndex) {
                final startIndex = rowIndex * slotsPerRow;
                final endIndex = (startIndex + slotsPerRow).clamp(
                  0,
                  slots.length,
                );
                final rowSlots = slots.sublist(startIndex, endIndex);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: rowIndex < totalRows - 1 ? data.spacing : 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(rowSlots.length, (colIndex) {
                      final slot = rowSlots[colIndex];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: colIndex < rowSlots.length - 1
                              ? data.spacing
                              : 0,
                        ),
                        child: _buildInventorySlot(
                          data,
                          slot,
                          slot.item,
                          slot.quantity,
                        ),
                      );
                    }),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildInventorySlot(
    ResponsiveOverlayData data,
    InventorySlot slot,
    Item? item,
    int? quantity,
  ) {
    Color slotColor = item != null
        ? Colors.blue.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2);

    if (item != null) {
      final isMainHand =
          getIt<EquipmentManager>().getEquippedSlotForItem(item.id) ==
          EquipmentSlotType.mainHand;
      if (isMainHand) {
        slotColor = Colors.red.withOpacity(0.5);
      }
    }

    final isSelected =
        getIt<EquipmentManager>().currentMainHandSlotIndex == slot.index;

    // Get slot number label (1-9, 0 for slot 10, - for slot 11, + for slot 12)
    String? slotNumberLabel;
    if (slot.index < 9) {
      slotNumberLabel = '${slot.index + 1}';
    } else if (slot.index == 9) {
      slotNumberLabel = '0';
    } else if (slot.index == 10) {
      slotNumberLabel = '-';
    } else if (slot.index == 11) {
      slotNumberLabel = '+';
    }

    return GestureDetector(
      onTap: () => getIt<EquipmentManager>().selectSlotIndex(slot.index),
      child: Container(
        width: data.slotSize,
        height: data.slotSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.5) : slotColor,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            // Slot number (keyboard shortcut indicator)
            if (slotNumberLabel != null)
              Positioned(
                top: 1,
                left: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: data.spacing / 2,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    slotNumberLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: data.baseFontSize - 4,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Normal',
                    ),
                  ),
                ),
              ),
            if (item != null) ...[
              // Item icon or abbreviation
              Center(
                child: item.iconData != null
                    ? Padding(
                        padding: EdgeInsets.all(data.spacing),
                        child: ItemSpriteWidget(
                          iconData: item.iconData,
                          size: data.slotSize - (data.spacing * 2),
                        ),
                      )
                    : Text(
                        _abbreviateItemName(item.name),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: data.baseFontSize - 2,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: data.spacing / 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'x$quantity',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: data.baseFontSize - 4,
                        fontFamily: 'Normal',
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
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
