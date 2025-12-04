import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/inputs_hud_config.dart';
import 'package:flutter/painting.dart';

class InputsHUDView extends GameInterface {
  @override
  void render(Canvas canvas) {
    _drawInputGuide(canvas);
    super.render(canvas);
  }

  void _drawInputGuide(Canvas canvas) {
    const double startX = 16;
    const double startY = 512;
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

    // Fundo do painel
    final double panelHeight =
        InputsHUDConfig.inputGuide.length * lineHeight + padding * 2;
    final double panelWidth = 300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startX - padding,
          startY - padding,
          panelWidth,
          panelHeight,
        ),
        const Radius.circular(8),
      ),
      bgPaint,
    );

    for (int i = 0; i < InputsHUDConfig.inputGuide.length; i++) {
      final y = startY + i * lineHeight;
      // Caixa da tecla
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, y, keyBoxWidth, keyBoxHeight),
          const Radius.circular(4),
        ),
        keyPaint,
      );
      // Texto da tecla
      TextPainter(
          text: TextSpan(
            text: InputsHUDConfig.inputGuide[i]["key"],
            style: keyTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: keyBoxWidth)
        ..paint(canvas, Offset(startX + 8, y + 2));
      // Descrição
      TextPainter(
          text: TextSpan(
            text: InputsHUDConfig.inputGuide[i]["desc"],
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: panelWidth - keyBoxWidth - 16)
        ..paint(canvas, Offset(startX + keyBoxWidth + 12, y + 2));
    }
  }
}
