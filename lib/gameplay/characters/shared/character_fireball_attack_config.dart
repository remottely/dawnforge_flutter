import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

class CharacterFireballAttackConfig {
  static const double kSpeedMultiplier = 2.5;

  static final LightingConfig fLightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionSmall,
    blurBorder: GameplayTileConfig.kTileDimensionSmall,
    color: CharacterParticlesAnimations.fLightingConfigColor,
  );

  static final Vector2 fComponentSize = GameplayTileConfig.fTileSizeSmall;

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(size: fComponentSize);

  static Future<SpriteAnimation> loadExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> loadDestroyAnimation() => SpriteAnimation.load(
    'gameplay/characters/shared/character_fireball_explosion_right_6.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: GameplayTileConfig.fTileSizeExtraLarge,
    ),
  );

  static void playExecutionAudio() =>
      GameplayAudioManager.instance.playFireballAttack();

  static void playDestroyAudio() =>
      GameplayAudioManager.instance.playFireballExplosion();
}
