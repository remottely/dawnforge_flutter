import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  DATA CLASS (Seguindo o padrão de barrel_decoration.dart)
// -----------------------------------------------------------------------------

abstract class _TorchDecorationData {
  /// DATA
  static const double _kLightRadiusMultiplier = 2.5;
  static const double _kBlurBorderMultiplier = 1.0;
  static const double _kPulseVariation = 0.1;
  static const double _kLightOpacity = 0.2;
  static Vector2 get _spriteSize => GameplayConstants.kTileVector2Default;

  /// LOAD
  static Future<SpriteAnimation> _loadAnimation() =>
      DecorationSpriteAnimations.torchDecoration6();

  /// CONFIG
  static LightingConfig _buildLightingConfig(double width) => LightingConfig(
    radius: width * _kLightRadiusMultiplier,
    blurBorder: width * _kBlurBorderMultiplier,
    pulseVariation: _kPulseVariation,
    color: Colors.deepOrangeAccent.withValues(alpha: _kLightOpacity),
  );
}

// -----------------------------------------------------------------------------
//  CLASSE PRINCIPAL (Refatorada para usar _TorchDecorationData)
// -----------------------------------------------------------------------------

class TorchDecoration extends DFGameDecoration {
  final bool _isExtinguished;

  TorchDecoration({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationData._loadAnimation(),
        size: _TorchDecorationData._spriteSize,
      ) {
    _setupLighting();
  }

  TorchDecoration.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationData._loadAnimation(),
        size: _TorchDecorationData._spriteSize,
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
    setupLighting(_TorchDecorationData._buildLightingConfig(width));
  }
}
