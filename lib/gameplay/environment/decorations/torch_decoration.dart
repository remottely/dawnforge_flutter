import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/sprites/decoration_sprite_animations.dart';
import 'package:flutter/material.dart';

abstract class _TorchData {}

class TorchDecoration extends DFGameDecoration {
  static const double kLightRadiusMultiplier = 2.5;
  static const double kBlurBorderMultiplier = 1.0;
  static const double kPulseVariation = 0.1;
  static const double kLightOpacity = 0.2;

  bool _isExtinguished = false;

  TorchDecoration({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: DecorationSpriteAnimations.torchDecoration6(),
        size: GameplayConstants.kTileVector2Default,
      ) {
    _setupLighting();
  }

  TorchDecoration.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: DecorationSpriteAnimations.torchDecoration6(),
        size: GameplayConstants.kTileVector2Default,
      ) {
    _setupLighting();
  }

  @override
  void render(Canvas canvas) {
    if (!_isExtinguished) {
      super.render(canvas);
    }
  }

  void _setupLighting() {
    setupLighting(
      LightingConfig(
        radius: width * kLightRadiusMultiplier,
        blurBorder: width * kBlurBorderMultiplier,
        pulseVariation: kPulseVariation,
        color: Colors.deepOrangeAccent.withValues(alpha: kLightOpacity),
      ),
    );
  }
}
