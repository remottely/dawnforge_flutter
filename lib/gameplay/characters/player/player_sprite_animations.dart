import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

// class MyAssetsExample {
//   static late final SpriteAnimation enemyAttackRight;

//   static Future<void> load() async {
//     enemyAttackRight = await SpriteAnimation.load(
//       'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
//       GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
//         amount: GameplaySpriteConstants.kAttackFrames,
//         textureSize: GameplaySpriteConstants.effectTextureSize,
//       ),
//     );
//   }
// }

class PlayerSpriteAnimations {
  /// ATTACK EFFECTS
  static Future<SpriteAnimation> playerBasicAttackRight3() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_basic_attack_right_3.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kAttackFrames,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  /// KNIGHT
  static Future<SpriteAnimation> knightPlayerIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kIdleFrames,
          textureSize: GameplaySpriteConstants.playerTextureSize,
        ),
      );

  static final SimpleDirectionAnimation knightPlayerDirectional =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_idle_left_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kPlayerIdleFrames,
            textureSize: GameplaySpriteConstants.playerTextureSize,
          ),
        ),
        idleRight: knightPlayerIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_run_left_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kRunFrames,
            textureSize: GameplaySpriteConstants.playerTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_run_right_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kRunFrames,
            textureSize: GameplaySpriteConstants.playerTextureSize,
          ),
        ),
      );
}
