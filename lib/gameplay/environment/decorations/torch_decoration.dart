import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';
import 'package:flutter/material.dart';

abstract class _TorchDecorationConfig {
  static const _kLightRadiusMultiplier = 2.5;
  static const _kBlurBorderMultiplier = 1.0;
  static const _kPulseVariation = 0.1;
  static const _kLightOpacity = 0.2;

  static final Vector2 _textureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _loadAnimation() => SpriteAnimation.load(
    'gameplay/environment/decorations/torch_decoration_6.png',
    GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
      amount: 6,
      textureSize: _textureSize,
    ),
  );

  static LightingConfig _buildLightingConfig(double width) => LightingConfig(
    radius: width * _kLightRadiusMultiplier,
    blurBorder: width * _kBlurBorderMultiplier,
    pulseVariation: _kPulseVariation,
    color: Colors.deepOrangeAccent.withValues(alpha: _kLightOpacity),
  );
}

class TorchDecorationView extends DDGameDecoration {
  final bool _isExtinguished;

  TorchDecorationView({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
        size: _TorchDecorationConfig._componentSize,
      ) {
    _setupLighting();
  }

  TorchDecorationView.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
        size: _TorchDecorationConfig._componentSize,
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
    setupLighting(_TorchDecorationConfig._buildLightingConfig(width));
  }
}
