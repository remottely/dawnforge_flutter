import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class CharacterFireballAttackConfig {
  static const kSpeedMultiplier = 2.5;

  static final fLightingConfig = LightingConfig(
    radius: GameplayConstants.kTileDimensionSmall,
    blurBorder: GameplayConstants.kTileDimensionSmall,
    color: CharacterParticlesAnimations.fLightingConfigColor,
  );

  static final fComponentSize = GameplayConstants.fTileSizeSmall;

  static RectangleHitbox buildHitbox() => RectangleHitbox(size: fComponentSize);

  static Future<SpriteAnimation> loadExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_attack_right_3.png',
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 3,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> loadDestroyAnimation() => SpriteAnimation.load(
    'gameplay/characters/shared/character_fireball_explosion_right_6.png',
    GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
      amount: 6,
      textureSize: GameplayConstants.fTileSizeExtraLarge,
    ),
  );

  static void playExecutionAudio() =>
      GameplayAudioManager.instance.playFireballAttack();

  static void playDestroyAudio() =>
      GameplayAudioManager.instance.playFireballExplosion();
}
