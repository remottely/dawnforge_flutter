import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

final class CharacterPrimaryAttackConfig {
  CharacterPrimaryAttackConfig._();

  /// Player
  static final Vector2 kPlayerPrimaryAttackFxSize =
      GameplayTileConfig.tileSizeSmall;

  static Future<SpriteAnimation> createPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConfig.tileSizeStandard,
        ),
      );

  /// Enemy
  static final Vector2 kEnemyPrimaryAttackFxSize =
      GameplayTileConfig.tileSizeSmall;

  static Future<SpriteAnimation> createEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConfig.tileSizeStandard,
        ),
      );

  static void playEnemyExecutionSfx() =>
      GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
}
