import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

final class CharacterFireballAttackConfig {
  CharacterFireballAttackConfig._();

  static const double kSpeed = CharacterConstants.kSpeedFast * 2.5;

  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionSmall,
    blurBorder: TileConstants.kTileDimensionSmall,
    color: LightingConstants.fireballAttackLighting,
  );

  static final Vector2 _textureSize = Vector2(23, 23);
  static final Vector2 componentSize = _textureSize / 3;

  static RectangleHitbox createHitbox() =>
      HitboxUtils.createExpandHitbox(componentSize);

  static Future<SpriteAnimation> createExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );

  static Future<SpriteAnimation> createDestroyAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_explosion_right_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      );

  static void playExecutionAudio() =>
      AudioManager.instance.playFireballAttackSfx();

  static void playDestroyAudio() =>
      AudioManager.instance.playFireballExplosionSfx();

  static void execute({
    required SimplePlayer player,
    required double damage,
    RectangleHitbox? collision,
    void Function()? onProjectileDestroyed,
  }) {
    final Vector2 projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      player.lastDirection,
    );

    player.simpleAttackRangeByDirection(
      direction: player.lastDirection,
      damage: damage,
      speed: kSpeed,
      animationRight: createExecutionAnimation(),
      animationDestroy: createDestroyAnimation(),
      size: componentSize,
      lightingConfig: lightingConfig,
      collision: collision ?? createHitbox(),
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
      onDestroy: () {
        playDestroyAudio();
        CameraFx.fireballExplosionShake(player.gameRef);
        onProjectileDestroyed?.call();
      },
    );
  }
}
