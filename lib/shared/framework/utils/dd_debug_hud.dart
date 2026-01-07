// import 'package:bonfire/bonfire.dart';
// import 'package:flutter/material.dart';

// class DDDebugHud extends GameComponent {
//   DDDebugHud({
//     this.showFps = true,
//     this.showPosition = true,
//     this.showEntities = true,
//     this.showMemory = false,
//   });

//   final bool showFps;
//   final bool showPosition;
//   final bool showEntities;
//   final bool showMemory;

//   late TextPaint _textPaint;
//   final List<double> _frameTimes = [];
//   double _fps = 0;
//   static const int _windowSize = 60;

//   @override
//   Future<void> onLoad() {
//     _textPaint = TextPaint(
//       style: const TextStyle(
//         color: Color(0xFF00FF00),
//         fontSize: 16,
//         fontFamily: 'monospace',
//         fontWeight: FontWeight.bold,
//         shadows: [
//           Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 2),
//         ],
//       ),
//     );
//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     _frameTimes.add(dt);
//     if (_frameTimes.length > _windowSize) {
//       _frameTimes.removeAt(0);
//     }

//     if (_frameTimes.isNotEmpty) {
//       final avg = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
//       _fps = avg > 0 ? 1 / avg : 0;
//     }
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);

//     double yOffset = 10;
//     const double lineHeight = 20;

//     if (showFps) {
//       final fpsColor = _fps >= 55
//           ? const Color(0xFF00FF00)
//           : _fps >= 30
//           ? const Color(0xFFFFFF00)
//           : const Color(0xFFFF0000);

//       _textPaint = TextPaint(style: _textPaint.style.copyWith(color: fpsColor));

//       _textPaint.render(
//         canvas,
//         'FPS: ${_fps.toStringAsFixed(0)}',
//         Vector2(10, yOffset),
//       );
//       yOffset += lineHeight;
//     }

//     _textPaint = TextPaint(
//       style: _textPaint.style.copyWith(color: const Color(0xFF00FF00)),
//     );

//     if (showEntities) {
//       final game = gameRef;
//       final visibleComponents = game.visibles().length;
//       _textPaint.render(
//         canvas,
//         'Entities: $visibleComponents',
//         Vector2(10, yOffset),
//       );
//       yOffset += lineHeight;
//     }

//     if (showPosition) {
//       final game = gameRef;
//       final player = game.player;
//       if (player != null) {
//         _textPaint.render(
//           canvas,
//           'Pos: (${player.x.toInt()}, ${player.y.toInt()})',
//           Vector2(10, yOffset),
//         );
//         yOffset += lineHeight;

//         final tileSize = game.map.tileSize;
//         if (tileSize > 0) {
//           final tileX = (player.x / tileSize).floor();
//           final tileY = (player.y / tileSize).floor();
//           _textPaint.render(
//             canvas,
//             'Tile: ($tileX, $tileY)',
//             Vector2(10, yOffset),
//           );
//           yOffset += lineHeight;
//         }
//       }
//     }
//   }
// }
