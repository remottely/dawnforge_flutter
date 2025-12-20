import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inventory/inventory_hud_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:flutter/material.dart';

class InventoryHUDView extends InterfaceComponent {
  InventoryHUDView()
    : super(
        id: InventoryHUDDef.kComponentId,
        size: Vector2(
          InventoryHUDDef.kPadding * 2 +
              (InventoryHUDDef.kSlotSize * InventoryHUDDef.kSlotsPerRow) +
              (InventoryHUDDef.kSpacing * (InventoryHUDDef.kSlotsPerRow - 1)),
          220, // Reduced height since equipment slots are removed
        ),
        position: Vector2.zero(), // Will be set in onLoad
      );

  final Map<String, Sprite> _spriteCache = {};
  bool _isVisible = false;
  bool get isVisible => _isVisible;
  void _show() => _isVisible = true;
  void _hide() => _isVisible = false;
  void toggleIsVisible() => _isVisible ? _hide() : _show();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updatePosition();
  }

  void _updatePosition() {
    // Center horizontally at bottom of screen
    final gameSize = gameRef.size;
    position = Vector2(
      (gameSize.x - size.x) / 2, // Center horizontally
      gameSize.y - size.y - 20,   // Bottom with 20px margin
    );
  }

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
      Offset(InventoryHUDDef.kPadding, InventoryHUDDef.kPadding),
      fontSize: 14,
    );

    _drawInventorySlots(canvas);

    super.render(canvas);
  }

  void _drawInventorySlots(Canvas canvas) {
    final manager = InventoryManager.instance;
    double startY = InventoryHUDDef.kPadding + 30;

    _drawText(
      canvas,
      'Inventário (${manager.usedSlots}/${manager.maxSlots}):',
      Offset(InventoryHUDDef.kPadding, startY),
      fontSize: 12,
    );

    startY += 20;

    for (int i = 0; i < manager.maxSlots; i++) {
      final row = i ~/ InventoryHUDDef.kSlotsPerRow;
      final col = i % InventoryHUDDef.kSlotsPerRow;

      final x =
          InventoryHUDDef.kPadding +
          (col * (InventoryHUDDef.kSlotSize + InventoryHUDDef.kSpacing));
      final y =
          startY +
          (row * (InventoryHUDDef.kSlotSize + InventoryHUDDef.kSpacing));
      final slot = manager.getSlotByIndex(i);
      _drawSlot(canvas, Offset(x, y), slot?.item, slot?.quantity);
    }
  }

  void _drawSlot(Canvas canvas, Offset position, dynamic item, int? quantity) {
    final slotRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      InventoryHUDDef.kSlotSize,
      InventoryHUDDef.kSlotSize,
    );

    // Check if item is equipped
    EquipmentSlotType? equippedSlot;
    Color slotColor = item != null
        ? Colors.blue.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.2);

    if (item != null) {
      equippedSlot = EquipmentManager.instance.getEquippedSlotForItem(item.id);
      if (equippedSlot != null) {
        // Red background for mainHand, green for offHand
        slotColor = equippedSlot == EquipmentSlotType.mainHand
            ? Colors.red.withValues(alpha: 0.5)
            : Colors.green.withValues(alpha: 0.5);
      }
    }

    final slotPaint = Paint()
      ..color = slotColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(slotRect, slotPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(slotRect, borderPaint);

    if (item != null) {
      final iconData = item.iconData;

      if (iconData != null) {
        final cacheKey = '${iconData.spritesheetPath}_${iconData.spriteRowIndex}_${iconData.spriteColumnIndex}';
        final cachedSprite = _spriteCache[cacheKey];

        if (cachedSprite != null) {
          cachedSprite.render(
            canvas,
            position: Vector2(position.dx + 4, position.dy + 4),
            size: Vector2(
              InventoryHUDDef.kSlotSize - 8,
              InventoryHUDDef.kSlotSize - 8,
            ),
          );
        } else {
          _loadAndCacheSprite(cacheKey, iconData);
          final abbreviation = _abbreviateItemName(item.name);
          _drawText(
            canvas,
            abbreviation,
            Offset(position.dx + 4, position.dy + 8),
            fontSize: 10,
          );
        }
      } else {
        final abbreviation = _abbreviateItemName(item.name);
        _drawText(
          canvas,
          abbreviation,
          Offset(position.dx + 4, position.dy + 8),
          fontSize: 10,
        );
      }

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

  void _loadAndCacheSprite(String cacheKey, dynamic iconData) {
    SpriteAnimationConfigHelper.loadSpriteFromSheet(
      assetPath: '${iconData.spritesheetPath}',
      spriteSize: Vector2(
        iconData.spriteWidth.toDouble(),
        iconData.spriteHeight.toDouble(),
      ),
      frameIndex: iconData.spriteColumnIndex,
      rowIndex: iconData.spriteRowIndex,
      skipFirstFrames: 0,
    ).then((sprite) {
      _spriteCache[cacheKey] = sprite;
    });
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
