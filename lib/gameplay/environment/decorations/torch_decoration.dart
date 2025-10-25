import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  DATA CLASS (Seguindo o padrão de barrel_decoration.dart)
// -----------------------------------------------------------------------------

abstract class _TorchDecorationConfig {
  /// DATA
  static const double _kLightRadiusMultiplier = 2.5;
  static const double _kBlurBorderMultiplier = 1.0;
  static const double _kPulseVariation = 0.1;
  static const double _kLightOpacity = 0.2;
  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;

  /// LOAD
  static Future<SpriteAnimation> _loadAnimation() =>
      DecorationSpriteAnimations.torchDecoration6();

  /// CONFIG
  static LightingConfig _buildLightingConfig(double width) => LightingConfig(
    // TODO(Kevin): put it into a shared class
    radius: width * _kLightRadiusMultiplier,
    blurBorder: width * _kBlurBorderMultiplier,
    pulseVariation: _kPulseVariation,
    color: Colors.deepOrangeAccent.withValues(alpha: _kLightOpacity),
  );
}

// -----------------------------------------------------------------------------
//  CLASSE PRINCIPAL (Refatorada para usar _TorchDecorationData)
// -----------------------------------------------------------------------------

class TorchDecorationView extends DFGameDecoration {
  final bool _isExtinguished;

  TorchDecorationView({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
        size: _TorchDecorationConfig._spriteSize,
      ) {
    _setupLighting();
  }

  TorchDecorationView.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
        size: _TorchDecorationConfig._spriteSize,
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
