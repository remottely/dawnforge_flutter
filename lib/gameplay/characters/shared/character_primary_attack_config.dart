import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';

final class CharacterPrimaryAttackConfig {
  CharacterPrimaryAttackConfig._();

  /// Player
  static final Vector2 kPlayerPrimaryAttackFxSize =
      TileConstants.tileSizeStandard;

  static Future<SpriteAnimation> createPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );

  /// Enemy
  static final Vector2 kEnemyPrimaryAttackFxSize = TileConstants.tileSizeSmall;

  static Future<SpriteAnimation> createEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );

  static void playEnemyExecutionSfx() =>
      AudioManager.instance.playEnemyPrimaryAttackSfx();
}
