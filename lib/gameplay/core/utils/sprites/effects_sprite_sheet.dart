import 'package:bonfire/bonfire.dart';

import '../../constants/sprite_constants.dart';

/// [EffectsSpriteSheet] responsible for providing sprite animations for visual effects
/// Following Flutter naming conventions for effects sprite systems
class EffectsSpriteSheet {
  /// Creates explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> explosion() => SpriteAnimation.load(
    'explosion.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kExplosionFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.explosionTextureSize,
    ),
  );

  /// Creates smoke explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> smokeExplosion() => SpriteAnimation.load(
    'smoke_explosin.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kSmokeExplosionFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.effectTextureSize,
    ),
  );

  /// Creates fireball attack animation facing right
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackRight() => SpriteAnimation.load(
    'player/fireball_right.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kFireballFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing left
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackLeft() => SpriteAnimation.load(
    'player/fireball_left.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kFireballFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing up
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackTop() => SpriteAnimation.load(
    'player/fireball_top.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kFireballFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball attack animation facing down
  /// Following Flutter pattern of directional animation methods
  static Future<SpriteAnimation> fireBallAttackBottom() => SpriteAnimation.load(
    'player/fireball_bottom.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kFireballFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.fireballTextureSize,
    ),
  );

  /// Creates fireball explosion animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> fireBallExplosion() => SpriteAnimation.load(
    'player/explosion_fire.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kFireballExplosionFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.explosionTextureSize,
    ),
  );
}
