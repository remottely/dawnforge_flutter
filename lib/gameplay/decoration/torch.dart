import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/environment_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/decoration/decoration.dart';
import 'package:flutter/material.dart';

/// [Torch] responsible for providing ambient lighting in dark areas
/// Following Flutter naming conventions for decoration systems
///
/// This decoration handles:
/// - Dynamic lighting effects with pulse variation
/// - Extinguishable state for gameplay mechanics
/// - Visual rendering based on lighting state
class Torch extends DFGameDecoration {
  // 1. Constantes de configuração
  static const double kDefaultSize = GameplayConstants.kCurrentTileSize;
  static const double kLightRadiusMultiplier = 2.5;
  static const double kBlurBorderMultiplier = 1.0;
  static const double kPulseVariation = 0.1;
  static const double kLightOpacity = 0.2;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  bool _isExtinguished = false;

  // 3. Construtor
  Torch(this._initialPosition, {bool isExtinguished = false})
    : _isExtinguished = isExtinguished,
      super.withAnimation(
        animation: EnvironmentSpriteSheet.torch(),
        position: _initialPosition,
        size: Vector2.all(kDefaultSize),
      ) {
    _setupLighting();
  }

  // 4. Métodos públicos principais
  @override
  void render(Canvas canvas) {
    if (!_isExtinguished) {
      super.render(canvas);
    }
  }

  // 5. Métodos privados auxiliares
  /// Sets up the lighting configuration for the torch
  void _setupLighting() {
    setupLighting(
      LightingConfig(
        radius: width * kLightRadiusMultiplier,
        blurBorder: width * kBlurBorderMultiplier,
        pulseVariation: kPulseVariation,
        color: Colors.deepOrangeAccent.withOpacity(kLightOpacity),
      ),
    );
  }
}
