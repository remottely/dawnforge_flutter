import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';

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
}
