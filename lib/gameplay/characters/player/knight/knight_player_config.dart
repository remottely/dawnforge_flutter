import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// KnightPlayerConfig
/// ---------------------------------------------------------------------------
/// Contém todos os dados estáticos, constantes e métodos utilitários para
/// configuração do KnightPlayerView. Use este padrão para outros configs.
abstract class KnightPlayerConfig {
  //////////////////////////////////////////////////////////////////////////////
  // GENERAL CONFIGURATION
  //////////////////////////////////////////////////////////////////////////////

  /// Tamanho padrão do sprite do player
  static final Vector2 spriteSize = GameplayConstants.kTileSizeStandard;

  /// Vida e velocidade padrão
  static const double kStandardLife = 200.0;
  static const double kStandardSpeed =
      GameplayConstants.kTileDimensionStandard * 2.5;

  //////////////////////////////////////////////////////////////////////////////
  // ENERGY & STAMINA
  //////////////////////////////////////////////////////////////////////////////

  /// Energia máxima e custo de ferramentas
  static const int kMaxEnergy = 100;
  static const int kToolUsageEnergyCost = 2;

  /// Stamina
  static const double kMaxStamina = 100.0;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  //////////////////////////////////////////////////////////////////////////////
  // COMBAT
  //////////////////////////////////////////////////////////////////////////////

  static const double kStandardAttackDamage = 25.0;
  static const double kSmallAttackDamage = 10.0;
  static const int kMeleeAttackStaminaCost = 15;
  static const int kFireballAttackStaminaCost = 10;

  //////////////////////////////////////////////////////////////////////////////
  // VISION
  //////////////////////////////////////////////////////////////////////////////

  static const double kVisionRadius = GameplayConstants.kVisionRadiusUltraLarge;

  //////////////////////////////////////////////////////////////////////////////
  // HITBOX
  //////////////////////////////////////////////////////////////////////////////

  static final Vector2 hitBoxSize = Vector2(8, 6);
  static final Vector2 hitBoxPosition = Vector2(4, 9);
  static FutureOr<void> buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: hitBoxPosition, size: hitBoxSize));

  //////////////////////////////////////////////////////////////////////////////
  // DEATH
  //////////////////////////////////////////////////////////////////////////////

  static const String kCryptSpritePath =
      'gameplay/characters/player/player_crypt_1.png';
  static final Vector2 cryptSpriteSize = Vector2.all(32);
  static Future<Sprite> loadCryptSprite() => Sprite.load(kCryptSpritePath);

  //////////////////////////////////////////////////////////////////////////////
  // CONFIGURATION BUILDERS
  //////////////////////////////////////////////////////////////////////////////

  static LightingConfig buildLightingConfig(double width) =>
      CharacterParticlesAnimations.knightLightingConfig(width);

  //////////////////////////////////////////////////////////////////////////////
  // LOADERS & HELPERS
  //////////////////////////////////////////////////////////////////////////////

  static final SimpleDirectionAnimation buildDirectionalAnimation =
      PlayerSpriteAnimations.knightPlayerDirectional;
}
