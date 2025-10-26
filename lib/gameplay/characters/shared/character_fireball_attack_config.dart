import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

class CharacterFireballAttackConfig {
  static const kSpeedMultiplier = 2.5;

  static void playExecutionAudio() =>
      GameplayAudioManager.instance.playFireballAttack();

  static void playDestroyAudio() =>
      GameplayAudioManager.instance.playFireballExplosion();

  static buildHitbox() => RectangleHitbox(
    position: Vector2(10, 5),
    size: Vector2(
      GameplayConstants.kTileDimensionStandard / 3,
      GameplayConstants.kTileDimensionStandard / 3,
    ),
  );

  static final lightingConfig = LightingConfig(
    radius: GameplayConstants.kTileDimensionStandard * 0.9,
    blurBorder: GameplayConstants.kTileDimensionStandard,
    color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
  );

  static final componentSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.65,
  );

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
      textureSize: GameplayConstants.kTileSizeExtraLarge,
    ),
  );
}
