import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

final class CharacterFireballAttackConfig {
  CharacterFireballAttackConfig._();

  static const double kSpeedMultiplier = 2.5;

  static final LightingConfig fLightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionSmall,
    blurBorder: GameplayTileConfig.kTileDimensionSmall,
    color: CharacterFxParticlesAnimationsConfig.fLightingConfigColor,
  );

  static final Vector2 fComponentSize = GameplayTileConfig.fTileSizeSmall;

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(size: fComponentSize);

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
          textureSize: GameplayTileConfig.fTileSizeExtraLarge,
        ),
      );

  static void playExecutionAudio() =>
      GameplayAudioManager.instance.playFireballAttackSfx();

  static void playDestroyAudio() =>
      GameplayAudioManager.instance.playFireballExplosionSfx();
}
