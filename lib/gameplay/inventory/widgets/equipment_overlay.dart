import 'package:darkness_dungeon/gameplay/inventory/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:flutter/material.dart';

class EquipmentOverlay extends StatelessWidget {
  const EquipmentOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EQUIPMENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Normal',
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: EquipmentState.instance.equipment,
                builder: (context, equipmentMap, child) {
                  return Column(
                    children: [
                      _buildSlotRow(
                        'MAIN HAND',
                        EquipmentSlotType.mainHand,
                        equipmentMap,
                        Colors.red.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildSlotRow(
                        'OFF HAND',
                        EquipmentSlotType.offHand,
                        equipmentMap,
                        Colors.green.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildSlotRow(
                        'HELMET',
                        EquipmentSlotType.helmet,
                        equipmentMap,
                        Colors.blue.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildSlotRow(
                        'CHEST',
                        EquipmentSlotType.chest,
                        equipmentMap,
                        Colors.blue.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildSlotRow(
                        'LEGS',
                        EquipmentSlotType.legs,
                        equipmentMap,
                        Colors.blue.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      _buildSlotRow(
                        'BOOTS',
                        EquipmentSlotType.boots,
                        equipmentMap,
                        Colors.blue.withOpacity(0.3),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotRow(
    String label,
    EquipmentSlotType slotType,
    Map<EquipmentSlotType, Item?> equipmentMap,
    Color slotColor,
  ) {
    final item = equipmentMap[slotType];

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 10,
              fontFamily: 'Normal',
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item != null ? slotColor : Colors.grey.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: item != null
              ? (item.iconData != null
                    ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ItemSpriteWidget(
                          iconData: item.iconData,
                          size: 32,
                        ),
                      )
                    : Center(
                        child: Text(
                          _abbreviateItemName(item.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Normal',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ))
              : const Center(
                  child: Text(
                    '-',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Normal',
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _abbreviateItemName(String name) {
    if (name.length <= 4) return name;

    final words = name.split(' ');
    if (words.length > 1) {
      return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
    }

    return name.substring(0, 4).toUpperCase();
  }
}
