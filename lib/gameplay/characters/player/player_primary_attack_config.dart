import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

final class PlayerPrimaryAttackConfig {
  PlayerPrimaryAttackConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _createExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );

  static void execute({required SimplePlayer player, required double damage}) {
    final attackDirection = player.lastDirection;

    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(6, 0),
      attackDirection,
    );

    CameraFx.executePrimaryAttackShake(player.gameRef);

    AudioManager.instance.playPlayerPrimaryAttackSfx();

    player.addParticle(
      CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
      position: player.size / 2,
    );

    player.simpleAttackMelee(
      damage: damage,
      size: _componentSize,
      centerOffset: attackOffset,
      animationRight: _createExecutionAnimation(),
    );
  }
}
