import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inventory/inventory_hud_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:flutter/material.dart';

class InventoryHUDView extends InterfaceComponent {
  InventoryHUDView()
    : super(
        id: InventoryHUDConfig.kComponentId,
        size: Vector2(
          InventoryHUDConfig.kPadding * 2 +
              (InventoryHUDConfig.kSlotSize * InventoryHUDConfig.kSlotsPerRow) +
              (InventoryHUDConfig.kSpacing *
                  (InventoryHUDConfig.kSlotsPerRow - 1)),
          400,
        ),
        position: Vector2(10, 100),
      );

  bool _isVisible = false;
  bool get isVisible => _isVisible;
  void _show() => _isVisible = true;
  void _hide() => _isVisible = false;
  void toggleIsVisible() => _isVisible ? _hide() : _show();

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(bgRect, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bgRect, borderPaint);

    _drawText(
      canvas,
      'INVENTÁRIO (I para fechar)',
      Offset(InventoryHUDConfig.kPadding, InventoryHUDConfig.kPadding),
      fontSize: 14,
    );

    _drawInventorySlots(canvas);

    _drawEquipmentSlots(canvas);

    super.render(canvas);
  }

  void _drawInventorySlots(Canvas canvas) {
    final manager = InventoryManager.instance;
    double startY = InventoryHUDConfig.kPadding + 30;

    _drawText(
      canvas,
      'Inventário (${manager.usedSlots}/${manager.maxSlots}):',
      Offset(InventoryHUDConfig.kPadding, startY),
      fontSize: 12,
    );

    startY += 20;

    for (int i = 0; i < manager.maxSlots; i++) {
      final row = i ~/ InventoryHUDConfig.kSlotsPerRow;
      final col = i % InventoryHUDConfig.kSlotsPerRow;

      final x =
          InventoryHUDConfig.kPadding +
          (col * (InventoryHUDConfig.kSlotSize + InventoryHUDConfig.kSpacing));
      final y =
          startY +
          (row * (InventoryHUDConfig.kSlotSize + InventoryHUDConfig.kSpacing));
      final slot = manager.getSlotByIndex(i);
      _drawSlot(canvas, Offset(x, y), slot?.item?.name, slot?.quantity);
    }
  }

  void _drawEquipmentSlots(Canvas canvas) {
    final manager = EquipmentManager.instance;
    double startY = InventoryHUDConfig.kPadding + 30 + 200;

    _drawText(
      canvas,
      'Equipment:',
      Offset(InventoryHUDConfig.kPadding, startY),
      fontSize: 12,
    );

    startY += 32;

    final slots = [
      EquipmentSlotType.weapon,
      EquipmentSlotType.offhand,
      EquipmentSlotType.helmet,
      EquipmentSlotType.chest,
      EquipmentSlotType.legs,
      EquipmentSlotType.boots,
    ];

    for (int i = 0; i < slots.length; i++) {
      final slotType = slots[i];
      final col = i % 3;
      final row = i ~/ 3;

      final x =
          InventoryHUDConfig.kPadding +
          (col * (InventoryHUDConfig.kSlotSize + 10 + 60));
      final y =
          startY +
          (row *
              (InventoryHUDConfig.kSlotSize +
                  InventoryHUDConfig.kSpacing +
                  10));

      final item = manager.getEquippedItem(slotType);

      _drawText(
        canvas,
        slotType.name.toUpperCase(),
        Offset(x, y - 12),
        fontSize: 8,
        color: Colors.yellow,
      );

      _drawSlot(canvas, Offset(x, y), item?.name, item != null ? 1 : null);
    }
  }

  void _drawSlot(
    Canvas canvas,
    Offset position,
    String? itemName,
    int? quantity,
  ) {
    final slotRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      InventoryHUDConfig.kSlotSize,
      InventoryHUDConfig.kSlotSize,
    );

    final slotPaint = Paint()
      ..color = itemName != null
          ? Colors.blue.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(slotRect, slotPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(slotRect, borderPaint);

    if (itemName != null) {
      final abbreviation = _abbreviateItemName(itemName);
      _drawText(
        canvas,
        abbreviation,
        Offset(position.dx + 4, position.dy + 8),
        fontSize: 10,
      );

      if (quantity != null && quantity > 1) {
        _drawText(
          canvas,
          'x$quantity',
          Offset(position.dx + 4, position.dy + 24),
          fontSize: 8,
          color: Colors.yellow,
        );
      }
    }
  }

  String _abbreviateItemName(String name) {
    if (name.length <= 4) return name;

    final words = name.split(' ');
    if (words.length > 1) {
      return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
    }

    return name.substring(0, 4).toUpperCase();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    Color color = Colors.white,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'Normal',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}
