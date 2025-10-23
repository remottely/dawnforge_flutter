import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';
import 'package:flutter/material.dart';

class CharacterFireballAttackData {
  static final Vector2 spriteSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.65,
  );
  static const double kSpeedMultiplier = 2.5;

  static void playAttackAudio() => GameplayAudioManager.playFireballAttack();
  static void playExplosionAudio() =>
      GameplayAudioManager.playFireballExplosion();

  static RectangleHitbox get hitbox => RectangleHitbox(
    size: Vector2(
      GameplayConstants.kTileDimensionStandard / 3,
      GameplayConstants.kTileDimensionStandard / 3,
    ),
    position: Vector2(10, 5),
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: GameplayConstants.kTileDimensionStandard * 0.9,
    blurBorder: GameplayConstants.kTileDimensionStandard,
    color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
  );

  static Future<SpriteAnimation> loadAttackAnimation() => SpriteAnimation.load(
    'gameplay/characters/shared/character_fireball_attack_right_3.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kFireballFrames,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  static Future<SpriteAnimation> loadExplosionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_explosion_right_6.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kFireballExplosionFrames,
          textureSize: GameplaySpriteConstants.explosionTextureSize,
        ),
      );
}
