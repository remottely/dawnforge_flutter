import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

final class CharacterPrimaryAttackConfig {
  CharacterPrimaryAttackConfig._();

  /// Player
  static final Vector2 kPlayerPrimaryAttackFxSize =
      GameplayTileConstants.tileSizeSmall;

  static Future<SpriteAnimation> createPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConstants.tileSizeStandard,
        ),
      );

  /// Enemy
  static final Vector2 kEnemyPrimaryAttackFxSize =
      GameplayTileConstants.tileSizeSmall;

  static Future<SpriteAnimation> createEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConstants.tileSizeStandard,
        ),
      );

  static void playEnemyExecutionSfx() =>
      GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
}
