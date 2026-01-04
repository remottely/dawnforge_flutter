import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/inventory_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:flutter/material.dart';

class InventoryOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  const InventoryOverlay({super.key});

  String get overlayId => 'inventory';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InventoryState.instance.isVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();
        
        // LayoutBuilder para reagir a mudanças de tamanho em tempo real
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = getScreenSize(context);
            final padding = OverlayResponsiveConfig.getPadding(screenSize);
            final spacing = OverlayResponsiveConfig.getSpacing(screenSize);
            final slotSize = OverlayResponsiveConfig.getSlotSize(screenSize);
            final baseFontSize = OverlayResponsiveConfig.getBaseFontSize(screenSize);

            return Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: screenSize == ScreenSize.mobile ? 1.5 : 2,
                  ),
                  borderRadius: BorderRadius.circular(
                    screenSize == ScreenSize.mobile ? 3 : 4,
                  ),
                ),
                child: _buildInventoryGrid(
                  context,
                  spacing,
                  slotSize,
                  baseFontSize,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryGrid(
    BuildContext context,
    double spacing,
    double slotSize,
    double baseFontSize,
  ) {
    // Listen to inventory changes with the actual slots list
    return ValueListenableBuilder<int>(
      valueListenable: getIt<EquipmentManager>().selectedSlotIndexNotifier,
      builder: (context, selectedIndex, _) {
        return ValueListenableBuilder<List<InventorySlot>>(
          valueListenable: getIt<InventoryManager>().slotsNotifier,
          builder: (context, slots, _) {
            return ValueListenableBuilder<HandItem?>(
              valueListenable: EquipmentState.instance.equippedItem,
              builder: (context, equippedItem, child) {
                // Desktop: 1 linha horizontal com rolagem horizontal
                if (isDesktopScreen(context)) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(slots.length, (index) {
                        final slot = slots[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < slots.length - 1 ? spacing : 0,
                          ),
                          child: _buildInventorySlot(
                            spacing,
                            slotSize,
                            baseFontSize,
                            slot,
                            slot.item,
                            slot.quantity,
                            equippedItem,
                            selectedIndex,
                          ),
                        );
                      }),
                    ),
                  );
                }

                // Mobile e Tablet: 1 coluna vertical com rolagem vertical
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(slots.length, (index) {
                        final slot = slots[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < slots.length - 1 ? spacing : 0,
                          ),
                          child: _buildInventorySlot(
                            spacing,
                            slotSize,
                            baseFontSize,
                            slot,
                            slot.item,
                            slot.quantity,
                            equippedItem,
                            selectedIndex,
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInventorySlot(
    double spacing,
    double slotSize,
    double baseFontSize,
    InventorySlot slot,
    HandItem? item,
    int? quantity,
    HandItem? equippedItem,
    int selectedIndex,
  ) {
    Color slotColor = item != null
        ? Colors.blue.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2);

    if (item != null && equippedItem != null && equippedItem.id == item.id) {
      slotColor = Colors.red.withOpacity(0.5);
    }

    final isSelected = selectedIndex == slot.index;

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
        width: slotSize,
        height: slotSize,
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
                    horizontal: spacing / 2,
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
                      fontSize: baseFontSize - 4,
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
                        padding: EdgeInsets.all(spacing),
                        child: ItemSpriteWidget(
                          iconData: item.iconData,
                          size: slotSize - (spacing * 2),
                        ),
                      )
                    : Text(
                        _abbreviateItemName(item.name),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: baseFontSize - 2,
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
                      horizontal: spacing / 2,
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
                        fontSize: baseFontSize - 4,
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
