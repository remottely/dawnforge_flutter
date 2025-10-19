import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

/// [EffectsSpriteSheet] responsible for providing sprite animations for visual effects
/// Following Flutter naming conventions for effects sprite systems
class EffectsSpriteSheet {
  /// Creates explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> explosion() => SpriteAnimation.load(
    'explosion.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kExplosionFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.explosionTextureSize,
    ),
  );

  /// Creates smoke explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> smokeExplosion() => SpriteAnimation.load(
    'smoke_explosin.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kSmokeExplosionFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.effectTextureSize,
    ),
  );

  /// Creates fireball attack animation facing right
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackRight() => SpriteAnimation.load(
    'gameplay/characters/player/fireball_right.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kFireballFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing left
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackLeft() => SpriteAnimation.load(
    'gameplay/characters/player/fireball_left.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kFireballFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing up
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackTop() => SpriteAnimation.load(
    'gameplay/characters/player/fireball_top.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kFireballFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing down
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackBottom() => SpriteAnimation.load(
    'gameplay/characters/player/fireball_bottom.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kFireballFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> fireBallExplosion() => SpriteAnimation.load(
    'gameplay/characters/player/explosion_fire.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kFireballExplosionFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.explosionTextureSize,
    ),
  );
}
