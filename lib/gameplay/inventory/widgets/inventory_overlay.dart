import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/inventory_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
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
  Widget buildOverlayContent(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
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
    // Ajusta o número de slots por linha baseado no tamanho da tela
    final int slotsPerRow = valueByScreenSize(
      context,
      small: 6,
      medium: 8,
      large: 10,
      extraLarge: 12,
    );

    // Listen to inventory changes with the actual slots list
    return ValueListenableBuilder<List<InventorySlot>>(
      valueListenable: InventoryManager.instance.slotsNotifier,
      builder: (context, slots, _) {
        // Listen to equipment changes for highlighting
        return ValueListenableBuilder<Map<EquipmentSlotType, Item?>>(
          valueListenable: EquipmentState.instance.equipment,
          builder: (context, equipmentMap, child) {
            return Wrap(
              spacing: data.spacing,
              runSpacing: data.spacing,
              children: List.generate(
                slots.length,
                (index) {
                  final slot = slots[index];
                  return _buildInventorySlot(
                    data,
                    slot,
                    slot.item,
                    slot.quantity,
                  );
                },
              ),
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
        EquipmentManager.instance.getEquippedSlotForItem(item.id) ==
          EquipmentSlotType.mainHand;
      if (isMainHand) {
        slotColor = Colors.red.withOpacity(0.5);
      }
    }

    final isSelected =
      EquipmentManager.instance.currentMainHandSlotIndex == slot.index;

    return GestureDetector(
      onTap: () => EquipmentManager.instance.selectSlotIndex(slot.index),
      child: Container(
        width: data.slotSize,
        height: data.slotSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.5) : slotColor,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
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
