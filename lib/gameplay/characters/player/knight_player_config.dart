import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

/// Contém todos os dados estáticos, constantes e construtores de configuração
/// para o KnightPlayerView.
abstract class KnightPlayerConfig {
  // Geral
  static final Vector2 spriteSize = GameplayConstants.kTileVector2Standard;
  static const double kStandardLife = 200.0;
  static const double kStandardSpeed =
      GameplayConstants.kTileSizeStandard * 2.5;

  // Sistema Agrícola
  static const int kMaxEnergy = 100;
  static const int kToolUsageEnergyCost = 2;

  // Combate
  static const double kStandardAttackDamage = 25.0;
  static const double kSmallAttackDamage = 10.0;
  static const int kMeleeAttackStaminaCost = 15;
  static const int kCharacterFireballAttackStaminaCost = 10;

  // Stamina
  static const double kMaxStamina = 100.0;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenerationDebounce = Duration(
    milliseconds: 150,
  );

  // Visão
  static const double kVisionRadius = GameplayConstants.kVisionRadiusUltraLarge;

  // Hitbox
  static final Vector2 hitBoxSize = Vector2(8, 6);
  static final Vector2 hitBoxPosition = Vector2(4, 9);

  // Morte
  static const String cryptSpritePath =
      'gameplay/characters/player/player_crypt_1.png';
  static final Vector2 cryptSpriteSize = Vector2.all(30);

  // UI
  static final TextStyle kDamageTextStyle = TextStyle(
    fontSize: 5,
    color: Colors.orange,
    fontFamily: 'Normal',
  );

  /// CONFIG (Métodos que criam objetos de configuração)
  static LightingConfig buildLightingConfig(double width) => LightingConfig(
    radius: width * 1.5,
    blurBorder: width,
    color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
  );

  /// LOAD (Métodos que carregam assets ou adicionam componentes)
  static SimpleDirectionAnimation get directionalAnimation =>
      PlayerAnimations.knightDirectional;

  static FutureOr<void> buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: hitBoxPosition, size: hitBoxSize));

  static Future<Sprite> loadCryptSprite() => Sprite.load(cryptSpritePath);
}
