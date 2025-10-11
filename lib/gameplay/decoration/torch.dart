import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/environment_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Torch extends GameDecoration {
  bool isExtinguished = false;

  Torch(Vector2 position, {this.isExtinguished = false})
    : super.withAnimation(
        animation: EnvironmentSpriteSheet.torch(),
        position: position,
        size: Vector2.all(GameplayTileConstants.kCurrentTileSize),
      ) {
    setupLighting(
      LightingConfig(
        radius: width * 2.5,
        blurBorder: width,
        pulseVariation: 0.1,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (!isExtinguished) {
      super.render(canvas);
    }
  }
}
