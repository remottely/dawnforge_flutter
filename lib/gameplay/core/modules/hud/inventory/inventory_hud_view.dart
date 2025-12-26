import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inventory/inventory_hud_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_icon_data.dart';
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
          64, // Reduced height since equipment slots are removed
        ),
        position: Vector2.zero(), // Will be set in onLoad
      );

  final Map<String, Sprite> _spriteCache = {};
  bool _isVisible = true;
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
    // Guard: only update position if game is mounted AND has valid size
    if (!hasGameRef) {
      developer.log(
        '[InventoryHUDView] Cannot update position: gameRef not available',
      );
      return;
    }

    final gameSize = gameRef.size;

    // Guard: gameRef.size can be (0,0) during initialization, which causes NaN/Infinity errors
    if (gameSize.x <= 0 || gameSize.y <= 0) {
      developer.log(
        '[InventoryHUDView] Cannot update position: invalid game size $gameSize',
      );
      return;
    }

    try {
      // Center horizontally at bottom of screen
      position = Vector2(
        (gameSize.x - size.x) / 2, // Center horizontally
        gameSize.y - size.y - 20, // Bottom with 20px margin
      );
      developer.log(
        '[InventoryHUDView] Position updated to $position (gameSize: $gameSize)',
      );
    } catch (e, stack) {
      developer.log(
        '[InventoryHUDView] Error updating position: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bgRect, borderPaint);

    _drawInventorySlots(canvas);

    super.render(canvas);
  }

  void _drawInventorySlots(Canvas canvas) {
    final manager = InventoryManager.instance;

    for (int i = 0; i < manager.maxSlots; i++) {
      final row = i ~/ InventoryHUDDef.kSlotsPerRow;
      final col = i % InventoryHUDDef.kSlotsPerRow;

      final x =
          InventoryHUDDef.kPadding +
          (col * (InventoryHUDDef.kSlotSize + InventoryHUDDef.kSpacing));
      final y =
          // startY +
          InventoryHUDDef.kPadding +
          (row * (InventoryHUDDef.kSlotSize + InventoryHUDDef.kSpacing));
      final slot = manager.getSlotByIndex(i);
      _drawSlot(canvas, Offset(x, y), slot?.item, slot?.quantity);
    }
  }

  void _drawSlot(Canvas canvas, Offset position, Item? item, int? quantity) {
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
        final cacheKey =
            '${iconData.spritesheetPath}_${iconData.spriteRowIndex}_${iconData.spriteColumnIndex}';
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

  void _loadAndCacheSprite(String cacheKey, ItemIconData? iconData) {
    SpriteAnimationConfigHelper.loadSpriteFromTextureAtlas(
      assetPath: '${iconData?.spritesheetPath}',
      spriteSize: Vector2(
        iconData?.spriteWidth.toDouble() ?? 0,
        iconData?.spriteHeight.toDouble() ?? 0,
      ),
      frameIndex: iconData?.spriteColumnIndex ?? 0,
      rowIndex: iconData?.spriteRowIndex ?? 0,
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
