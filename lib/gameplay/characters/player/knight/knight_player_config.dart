import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KnightPlayerConfig {
  static const double kStandardLife = 200.0;

  static const double kStandardSpeed =
      GameplayConstants.kTileDimensionStandard * 2.5;

  static const int kMaxEnergy = 100;

  static const int kToolUsageEnergyCost = 2;

  static const double kMaxStamina = 100.0;

  static const int kStaminaIncrement = 2;

  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double kStandardAttackDamage = 25.0;

  static const double kSmallAttackDamage = 10.0;

  static const int kMeleeAttackStaminaCost = 15;

  static const int kFireballAttackStaminaCost = 10;

  static const double kVisionRadius = GameplayConstants.kVisionRadiusUltraLarge;

  static final Vector2 hitBoxSize = Vector2(8, 6);

  static final Vector2 hitBoxPosition = Vector2(4, 9);

  static FutureOr<void> buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: hitBoxPosition, size: hitBoxSize));

  static const String kCryptSpritePath =
      'gameplay/characters/player/player_crypt_1.png';
  static final Vector2 cryptComponentSize = GameplayConstants.kTileSizeStandard;
  static Future<Sprite> loadCryptSprite() => Sprite.load(kCryptSpritePath);

  static LightingConfig buildLightingConfig(double width) =>
      CharacterParticlesAnimations.knightLightingConfig(width);

  static final Vector2 textureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation buildDirectionalAnimation =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_idle_left_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        idleRight: UISpriteAnimations.knightPlayerIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_run_left_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_run_right_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );
}
