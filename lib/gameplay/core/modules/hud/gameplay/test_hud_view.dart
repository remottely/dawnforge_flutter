import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/darkness_dungeon.dart';

class TestHUDView extends GameInterface {
  // Guia de inputs de teste
  static const List<Map<String, String>> _inputGuide = [
    // {"key": "ESC", "desc": "Menu/Pause"},
    // {"key": "C", "desc": "Ação especial"},
    // {"key": "Z", "desc": "Ataque primário"},
    // {"key": "X", "desc": "Ataque secundário"},
    // {"key": "Espaço", "desc": "Interagir / Usar ferramenta"},
    // {"key": "Q/E", "desc": "Trocar item rápido"},
    // {"key": "I", "desc": "Inventário"},
    {"key": "Z", "desc": "Defesa Especial"},
    {"key": "X", "desc": "Interação com Objeto / NPC"},
    {"key": "Espaço", "desc": "Executar Ação Equipada"},
    {"key": "Q/E", "desc": "Trocar item rápido"},
    {"key": "I", "desc": "Abrir/Fechar Inventário"},
    {"key": "G", "desc": "Apagar save"},
    {"key": "N", "desc": "Virar dia / Salvar jogo"},
    {"key": "U", "desc": "Desequipa hand (DEV)"},
    {"key": "O", "desc": "Equipa offhand (DEV)"},
    {"key": "P", "desc": "Desquipa offhand (DEV)"},
    {"key": "T", "desc": "Add items para teste (DEV)"},
  ];

  @override
  void render(Canvas canvas) {
    _drawInputGuide(canvas);
    super.render(canvas);
  }

  void _drawInputGuide(Canvas canvas) {
    const double startX = 16;
    const double startY = 512;
    const double lineHeight = 22;
    const double keyBoxWidth = 64;
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
    final double panelHeight = _inputGuide.length * lineHeight + padding * 2;
    final double panelWidth = 256;
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

    for (int i = 0; i < _inputGuide.length; i++) {
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
          text: TextSpan(text: _inputGuide[i]["key"], style: keyTextStyle),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: keyBoxWidth)
        ..paint(canvas, Offset(startX + 8, y + 2));
      // Descrição
      TextPainter(
          text: TextSpan(text: _inputGuide[i]["desc"], style: textStyle),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: panelWidth - keyBoxWidth - 16)
        ..paint(canvas, Offset(startX + keyBoxWidth + 12, y + 2));
    }
  }
}
