import 'package:bonfire/bonfire.dart';

import '../../constants/sprite_constants.dart';

/// [PlayerSpriteSheet] responsible for providing player character sprite animations
/// Following Flutter naming conventions for player sprite systems
class PlayerSpriteSheet {
  /// Creates player idle right animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
    'player/knight_idle.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.idleFrames,
      stepTime: SpriteConstants.defaultStepTime,
      textureSize: SpriteConstants.playerTextureSize,
    ),
  );

  /// Creates player attack effect animation facing down
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> attackEffectBottom() => SpriteAnimation.load(
    'player/atack_effect_bottom.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.attackFrames,
      stepTime: SpriteConstants.defaultStepTime,
      textureSize: SpriteConstants.effectTextureSize,
    ),
  );

  /// Creates player attack effect animation facing left
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> attackEffectLeft() => SpriteAnimation.load(
    'player/atack_effect_left.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.attackFrames,
      stepTime: SpriteConstants.defaultStepTime,
      textureSize: SpriteConstants.effectTextureSize,
    ),
  );

  /// Creates player attack effect animation facing right
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> attackEffectRight() => SpriteAnimation.load(
    'player/atack_effect_right.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.attackFrames,
      stepTime: SpriteConstants.defaultStepTime,
      textureSize: SpriteConstants.effectTextureSize,
    ),
  );

  /// Creates player attack effect animation facing up
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> attackEffectTop() => SpriteAnimation.load(
    'player/atack_effect_top.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.attackFrames,
      stepTime: SpriteConstants.defaultStepTime,
      textureSize: SpriteConstants.effectTextureSize,
    ),
  );

  /// Creates complete directional animation set for player
  /// Following Flutter pattern of comprehensive animation factories
  static SimpleDirectionAnimation playerAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'player/knight_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: SpriteConstants.playerIdleFrames,
            stepTime: SpriteConstants.defaultStepTime,
            textureSize: SpriteConstants.playerTextureSize,
          ),
        ),
        idleRight: idleRight(),
        runLeft: SpriteAnimation.load(
          'player/knight_run_left.png',
          SpriteAnimationData.sequenced(
            amount: SpriteConstants.playerRunFrames,
            stepTime: SpriteConstants.defaultStepTime,
            textureSize: SpriteConstants.playerTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'player/knight_run.png',
          SpriteAnimationData.sequenced(
            amount: SpriteConstants.playerRunFrames,
            stepTime: SpriteConstants.defaultStepTime,
            textureSize: SpriteConstants.playerTextureSize,
          ),
        ),
      );
}
