import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

final class PlayerPrimaryAttackConfig {
  PlayerPrimaryAttackConfig._();

  /// Player
  static final Vector2 kPlayerPrimaryAttackFxSize =
      TileConstants.tileSizeStandard;

  static Future<SpriteAnimation> createPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );

  static void playPlayerExecutionSfx() =>
      AudioManager.instance.playPlayerPrimaryAttackSfx();

  /// Executes a complete primary melee attack with all visual and audio effects.
  ///
  /// This is the centralized method that handles 100% of the primary attack flow:
  /// - Camera shake effect
  /// - Attack sound effect
  /// - Particle effects
  /// - Damage hitbox application via simpleAttackMelee
  ///
  /// Use this method whenever a primary attack needs to be executed to ensure
  /// consistent behavior across all game scenarios.
  ///
  /// Parameters:
  /// - [player]: The player component executing the attack
  /// - [damage]: The damage amount to apply
  /// - [direction]: The direction of the attack (defaults to player's lastDirection)
  /// - [centerOffset]: Optional custom offset for hitbox positioning
  ///                   (if null, calculates automatically based on direction)
  static void execute({
    required GameComponent player,
    required double damage,
    Direction? direction,
    Vector2? centerOffset,
  }) {
    // Get player as SimplePlayer to access game methods
    final simplePlayer = player as SimplePlayer;
    final attackDirection = direction ?? simplePlayer.lastDirection;

    // Calculate attack offset if not provided
    final attackOffset =
        centerOffset ??
        OffsetHelper.getCenterOffset(Vector2(6, 0), attackDirection);

    // Apply all effects in order:

    // 1. Camera shake
    CameraFx.executePrimaryAttackShake(simplePlayer.gameRef);

    // 2. Sound effect
    AudioManager.instance.playPlayerPrimaryAttackSfx();

    // 3. Particle effects
    simplePlayer.addParticle(
      CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
      position: simplePlayer.size,
    );

    // 4. Apply damage hitbox
    simplePlayer.simpleAttackMelee(
      damage: damage,
      size: kPlayerPrimaryAttackFxSize,
      centerOffset: attackOffset,
      animationRight: createPlayerExecutionAnimation(),
    );
  }
}
