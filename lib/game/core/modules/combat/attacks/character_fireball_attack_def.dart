import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/game/core/modules/camera/camera_fx.dart';
import 'package:dawnforge/game/core/modules/game/lightning_constants.dart';
import 'package:dawnforge/game/core/modules/game/tile_constants.dart';
import 'package:dawnforge/game/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class CharacterFireballAttackDef {
  CharacterFireballAttackDef._();

  static final Vector2 _textureSize = Vector2(
    23,
    23,
  ); // TODO(Kevin): enhance image textureSize
  static final Vector2 componentSize = _textureSize / 3;

  static const double kSpeed = CharacterConstants.kSpeedFast * 2.5;

  static final LightingConfig lighting = LightingConfig(
    radius: TileConstants.kTileDimensionSmall,
    blurBorder: TileConstants.kTileDimensionSmall,
    color: LightingConstants.fireballAttackLighting,
  );

  static RectangleHitbox createHitbox() =>
      HitboxUtils.createExpandHitbox(componentSize)
        ..collisionType = CollisionType.passive;

  static Future<SpriteAnimation> loadAnimationExecution() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationDestroy() => SpriteAnimation.load(
    'gameplay/characters/shared/character_fireball_explosion_right_6.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 6,
      textureSize: TileConstants.tileSizeExtraLarge,
    ),
  );

  static void playAudioExecution() =>
      AudioManager.instance.playFireballAttackSfx();

  static void onDestroy(BonfireGameInterface gameRef) {
    AudioManager.instance.playFireballExplosionSfx();
    CameraFx.executeFireballExplosionShake(gameRef);
  }
}
