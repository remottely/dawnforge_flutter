import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';
import 'package:flutter/material.dart';

class CharacterFireballAttackData {
  static Vector2 spriteSize = Vector2.all(
    GameplayConstants.kTileSizeDefault * 0.65,
  );
  static const double kSpeedMultiplier = 2.5;

  static void playExplosionAudio() => GameplayAudioManager.playExplosion();
  static void playExecutionAudio() => GameplayAudioManager.playFireballAttack();

  static RectangleHitbox buildHitbox() => RectangleHitbox(
    size: Vector2(
      GameplayConstants.kTileSizeDefault / 3,
      GameplayConstants.kTileSizeDefault / 3,
    ),
    position: Vector2(10, 5),
  );

  static LightingConfig buildLightingConfig() => LightingConfig(
    radius: GameplayConstants.kTileSizeDefault * 0.9,
    blurBorder: GameplayConstants.kTileSizeDefault,
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
