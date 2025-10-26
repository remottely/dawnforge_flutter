import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KnightPlayerConfig {
  static const kStandardLife = 200.0;
  static const kStandardSpeed = GameplayConstants.kTileDimensionStandard * 2.5;
  static const kMaxEnergy = 100;
  static const kToolUsageEnergyCost = 2;
  static const kMaxStamina = 100.0;
  static const kStaminaIncrement = 2;
  static const kStaminaRegenDebounce = Duration(milliseconds: 150);
  static const kStandardAttackDamage = 25.0;
  static const kSmallAttackDamage = 10.0;
  static const kMeleeAttackStaminaCost = 15;
  static const kFireballAttackStaminaCost = 10;
  static const kVisionRadius = GameplayConstants.kVisionRadiusUltraLarge;

  static final fHitbox = RectangleHitbox(
    position: Vector2(4, 9),
    size: Vector2(8, 6),
  );

  static const kCryptSpritePath =
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
