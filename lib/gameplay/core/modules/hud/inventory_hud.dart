import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:flutter/material.dart';

/// HUD que exibe o inventário do jogador
class InventoryHUD extends InterfaceComponent {
  static const int kComponentId = 2;
  static const double kSlotSize = 40.0;
  static const double kSpacing = 4.0;
  static const double kPadding = 10.0;
  static const int kSlotsPerRow = 6;

  bool _isVisible = false;

  InventoryHUD()
    : super(
        id: kComponentId,
        size: Vector2(
          kPadding * 2 +
              (kSlotSize * kSlotsPerRow) +
              (kSpacing * (kSlotsPerRow - 1)),
          400,
        ),
        position: Vector2(10, 100),
      );

  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
  }

  void show() => _isVisible = true;
  void hide() => _isVisible = false;

  /// Força um refresh do HUD (útil após mudanças no inventário)
  void refresh() {
    // O render() já é chamado todo frame, mas podemos adicionar lógica futura aqui
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    // Background semi-transparente
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(bgRect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bgRect, borderPaint);

    // Título
    _drawText(
      canvas,
      'INVENTÁRIO (I para fechar)',
      Offset(kPadding, kPadding),
      fontSize: 14,
    );

    // Desenhar slots do inventário
    _drawInventorySlots(canvas);

    // Desenhar equipamentos
    _drawEquipmentSlots(canvas);

    super.render(canvas);
  }

  void _drawInventorySlots(Canvas canvas) {
    final manager = InventoryManager.instance;
    double startY = kPadding + 30;

    _drawText(
      canvas,
      'Inventário (${manager.usedSlots}/${manager.maxSlots}):',
      Offset(kPadding, startY),
      fontSize: 12,
    );

    startY += 20;

    for (int i = 0; i < manager.maxSlots; i++) {
      final row = i ~/ kSlotsPerRow;
      final col = i % kSlotsPerRow;

      final x = kPadding + (col * (kSlotSize + kSpacing));
      final y = startY + (row * (kSlotSize + kSpacing));

      final slot = manager.getSlotByIndex(i);
      _drawSlot(canvas, Offset(x, y), slot?.item?.name, slot?.quantity);
    }
  }

  void _drawEquipmentSlots(Canvas canvas) {
    final manager = EquipmentManager.instance;
    double startY = kPadding + 30 + 200; // Abaixo do inventário

    _drawText(canvas, 'Equipamento:', Offset(kPadding, startY), fontSize: 12);

    startY += 20;

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
          kPadding + (col * (kSlotSize + 10 + 60)); // Espaço extra para label
      final y = startY + (row * (kSlotSize + kSpacing + 10));

      final item = manager.getEquippedItem(slotType);

      // Label do slot
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
      kSlotSize,
      kSlotSize,
    );

    // Background do slot
    final slotPaint = Paint()
      ..color = itemName != null
          ? Colors.blue.withOpacity(0.3)
          : Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(slotRect, slotPaint);

    // Border do slot
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(slotRect, borderPaint);

    // Nome do item (abreviado)
    if (itemName != null) {
      final abbreviation = _abbreviateItemName(itemName);
      _drawText(
        canvas,
        abbreviation,
        Offset(position.dx + 4, position.dy + 8),
        fontSize: 10,
      );

      // Quantidade
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

    // Pegar primeiras letras de cada palavra
    final words = name.split(' ');
    if (words.length > 1) {
      return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
    }

    // Ou apenas primeiros 4 caracteres
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
