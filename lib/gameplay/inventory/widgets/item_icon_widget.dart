import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/inventory/entities/hand_item.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/sprite_animation_config_helper.dart';

class ItemIconWidget extends StatelessWidget {
  final HandItem item;
  final double size;

  const ItemIconWidget({super.key, required this.item, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    final iconData = item.iconData;
    try {
      return FutureBuilder<Sprite>(
        future:
            SpriteAnimationConfigHelper.loadSpriteFromTextureAtlasModernFarm(
              assetPath: 'assets/${iconData.spritesheetPath}',
              spriteSize: Vector2(
                iconData.spriteWidth.toDouble(),
                iconData.spriteHeight.toDouble(),
              ),
              frameIndex: iconData.spriteColumnIndex,
              rowIndex: iconData.spriteRowIndex,
              skipFirstFrames: 0,
            ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomPaint(
              size: Size(size, size),
              painter: _SpritePainter(sprite: snapshot.data!),
            );
          }

          // Loading ou erro: mostrar abreviação
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Text(
              _abbreviateItemName(item.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Fallback: mostrar abreviação de texto
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Text(
          _abbreviateItemName(item.name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _abbreviateItemName(String name) {
    if (name.length <= 4) return name.toUpperCase();

    final words = name.split(' ');
    if (words.length > 1) {
      return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
    }

    return name.substring(0, 4).toUpperCase();
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite sprite;

  _SpritePainter({required this.sprite});

  @override
  void paint(Canvas canvas, Size size) {
    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: Vector2(size.width, size.height),
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return sprite != oldDelegate.sprite;
  }
}
