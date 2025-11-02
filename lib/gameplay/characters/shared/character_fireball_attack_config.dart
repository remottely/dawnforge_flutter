import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';

final class CharacterFireballAttackConfig {
  CharacterFireballAttackConfig._();

  static const double kSpeedMultiplier = 2.5;

  static final LightingConfig lightingConfig = LightingConfig(
    radius: GameplayTileConstants.kTileDimensionSmall,
    blurBorder: GameplayTileConstants.kTileDimensionSmall,
    color: CharacterFxParticlesAnimationsConfig.lightingConfigColor,
  );

  static final Vector2 componentSize = GameplayTileConstants.tileSizeSmall;

  static RectangleHitbox createHitbox() =>
      HitboxUtils.createExpandHitbox(componentSize);

  static Future<SpriteAnimation> createExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> createDestroyAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_explosion_right_6.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: GameplayTileConstants.tileSizeExtraLarge,
        ),
      );

  static void playExecutionAudio() =>
      GameplayAudioManager.instance.playFireballAttackSfx();

  static void playDestroyAudio() =>
      GameplayAudioManager.instance.playFireballExplosionSfx();
}
