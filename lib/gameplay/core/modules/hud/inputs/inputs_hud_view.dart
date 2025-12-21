import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/inputs_hud_def.dart';
import 'package:flutter/painting.dart';

class InputsHUDView extends InterfaceComponent {
  InputsHUDView()
      : super(
          id:  3,
          size: Vector2(300, 0), // Width fixed, height calculated dynamically
          position: Vector2.zero(), // Will be set in onLoad
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateSizeAndPosition();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateSizeAndPosition();
  }

  void _updateSizeAndPosition() {
    // Guard: only update position if game is mounted AND has valid size
    if (!hasGameRef) {
      developer.log(
        '[InputsHUDView] Cannot update position: gameRef not available',
      );
      return;
    }

    final gameSize = gameRef.size;

    // Guard: gameRef.size can be (0,0) during initialization
    if (gameSize.x <= 0 || gameSize.y <= 0) {
      developer.log(
        '[InputsHUDView] Cannot update position: invalid game size $gameSize',
      );
      return;
    }

    try {
      const double padding = 6;
      const double lineHeight = 22;
      final double panelHeight =
          InputsHUDDef.inputGuide.length * lineHeight + padding * 2;

      // Update component size
      size.y = panelHeight;

      // Position at bottom left with margins
      position = Vector2(
        16, // Left margin
        gameSize.y - size.y - 20, // Bottom with 20px margin
      );

      developer.log(
        '[InputsHUDView] Position updated to $position (gameSize: $gameSize)',
      );
    } catch (e, stack) {
      developer.log(
        '[InputsHUDView] Error updating position: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    _drawInputGuide(canvas);
    super.render(canvas);
  }

  void _drawInputGuide(Canvas canvas) {
    const double lineHeight = 22;
    const double keyBoxWidth = 96;
    const double keyBoxHeight = 20;
    const double padding = 6;
    final Paint bgPaint = Paint()..color = const Color(0xAA222222);
    final Paint keyPaint = Paint()..color = const Color(0xFF444444);
    final textStyle = const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13);
    final keyTextStyle = const TextStyle(
      color: Color(0xFF00FFAA),
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );

    // Draw background panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      bgPaint,
    );

    // Draw input guide entries
    for (int i = 0; i < InputsHUDDef.inputGuide.length; i++) {
      final y = padding + i * lineHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padding, y, keyBoxWidth, keyBoxHeight),
          const Radius.circular(4),
        ),
        keyPaint,
      );

      TextPainter(
          text: TextSpan(
            text: InputsHUDDef.inputGuide[i]["key"],
            style: keyTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: keyBoxWidth)
        ..paint(canvas, Offset(padding + 8, y + 2));

      TextPainter(
          text: TextSpan(
            text: InputsHUDDef.inputGuide[i]["desc"],
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: size.x - keyBoxWidth - padding * 3)
        ..paint(canvas, Offset(padding + keyBoxWidth + 12, y + 2));
    }
  }
}
