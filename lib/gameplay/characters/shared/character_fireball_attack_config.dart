import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

final class CharacterFireballAttackConfig {
  CharacterFireballAttackConfig._();

  static final Vector2 _textureSize = Vector2(
    23,
    23,
  ); // TODO(Kevin): enhance image textureSize
  static final Vector2 _componentSize = _textureSize / 3;

  static const double _kSpeed = CharacterConstants.kSpeedFast * 2.5;

  static final LightingConfig _lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionSmall,
    blurBorder: TileConstants.kTileDimensionSmall,
    color: LightingConstants.fireballAttackLighting,
  );

  static RectangleHitbox _createHitbox() =>
      HitboxUtils.createExpandHitbox(_componentSize)
        ..collisionType = CollisionType.passive;

  static Future<SpriteAnimation> _createExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );

  static Future<SpriteAnimation> _createDestroyAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_explosion_right_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      );

  static void _playExecutionAudio() =>
      AudioManager.instance.playFireballAttackSfx();

  static void _onDestroy(BonfireGameInterface gameRef) {
    AudioManager.instance.playFireballExplosionSfx();
    CameraFx.executeFireballExplosionShake(gameRef);
  }

  static void playerExecute({
    required SimplePlayer player,
    required double damage,
  }) {
    final Vector2 projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      player.lastDirection,
    );

    player.addParticle(
      CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
      position: player.size / 2,
    );

    _playExecutionAudio();

    player.simpleAttackRangeByDirection(
      size: _componentSize,
      speed: _kSpeed,
      lightingConfig: _lightingConfig,
      damage: damage,
      collision: _createHitbox(),
      animationRight: _createExecutionAnimation(),
      animationDestroy: _createDestroyAnimation(),
      onDestroy: () => _onDestroy(player.gameRef),
      direction: player.lastDirection,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }

  static void enemyExecute({
    required SimpleEnemy enemy,
    required double damage,
    required double longVisionRadius,
  }) {
    enemy.seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (_) {
        enemy.simpleAttackRange(
          size: _componentSize,
          speed: _kSpeed,
          lightingConfig: _lightingConfig,
          damage: damage,
          collision: _createHitbox(),
          animation: _createExecutionAnimation(),
          animationDestroy: _createDestroyAnimation(),
          execute: _playExecutionAudio,
          onDestroy: () => _onDestroy(enemy.gameRef),
        );
      },
    );
  }
}
