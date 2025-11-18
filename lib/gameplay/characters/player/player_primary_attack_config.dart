import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class PlayerPrimaryAttackConfig {
  PlayerPrimaryAttackConfig._();

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

  static void playPlayerExecutionSfx() =>
      AudioManager.instance.playPlayerPrimaryAttackSfx();
}
