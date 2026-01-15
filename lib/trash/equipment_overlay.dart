// import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
// import 'package:dawnforge/gameplay/inventory/entities/item.dart';
// import 'package:dawnforge/gameplay/inventory/state/equipment_state.dart';
// import 'package:dawnforge/gameplay/inventory/widgets/item_sprite_widget.dart';
// import 'package:flutter/material.dart';

// class EquipmentOverlay extends ResponsiveOverlayBase {
//   const EquipmentOverlay({super.key});

//   @override
//   String get overlayId => 'equipment';

//   @override
//   ValueNotifier<bool> get visibilityNotifier =>
//       EquipmentState.instance.isVisible;

//   @override
//   OverlayPosition getOverlayPosition(BuildContext context) {
//     final margin = getResponsiveMargin(context);
//     return OverlayPosition.topRight(
//       margin: margin,
//       safeAreaPadding: EdgeInsets.all(margin / 2),
//     );
//   }

//   @override
//   Widget buildOverlayContent(BuildContext context, OverlaySpacing data) {
//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         padding: EdgeInsets.all(data.padding),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.8),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.5),
//             width: data.isMobileScreen ? 1.5 : 2,
//           ),
//           borderRadius: BorderRadius.circular(data.isMobileScreen ? 6 : 8),
//         ),
//         child: ValueListenableBuilder<Item?>(
//           valueListenable: EquipmentState.instance.equippedItem,
//           builder: (context, equippedItem, child) {
//             return _buildSlotRow(
//               context,
//               data,
//               equippedItem,
//               Colors.red.withOpacity(0.3),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSlotRow(
//     BuildContext context,
//     OverlaySpacing data,
//     Item? equippedItem,
//     Color slotColor,
//   ) {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: SizedBox(
//         width: data.equipmentSlotSize,
//         height: data.equipmentSlotSize,
//         child: Container(
//           decoration: BoxDecoration(
//             color: equippedItem != null
//                 ? slotColor
//                 : Colors.grey.withOpacity(0.2),
//             border: Border.all(color: Colors.white.withOpacity(0.5)),
//           ),
//           child: equippedItem != null
//               ? (equippedItem.iconData != null
//                     ? Padding(
//                         padding: EdgeInsets.zero,
//                         child: ItemSpriteWidget(
//                           iconData: equippedItem.iconData,
//                           size: data.equipmentSlotSize - data.spacing,
//                         ),
//                       )
//                     : Center(
//                         child: Text(
//                           _abbreviateItemName(equippedItem.name),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: data.baseFontSize - 2,
//                             fontFamily: 'Normal',
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ))
//               : Center(
//                   child: Text(
//                     '-',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: data.titleFontSize,
//                       fontFamily: 'Normal',
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   static String _abbreviateItemName(String name) {
//     if (name.length <= 4) return name;

//     final words = name.split(' ');
//     if (words.length > 1) {
//       return words.map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
//     }

//     return name.substring(0, 4).toUpperCase();
//   }
// }
