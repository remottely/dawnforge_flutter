import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/player_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/shared/framework/players/mixins/dd_base_player_extension.dart';

final class PlayerCombatActionController {
  PlayerCombatActionController._();

  static void executePrimaryAttack({
    required SimplePlayer player,
    required double damage,
  }) {
    final attackDirection = player.lastDirection;

    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(6, 0),
      attackDirection,
    );

    CameraFx.executePrimaryAttackShake(player.gameRef);

    AudioManager.instance.playPlayerPrimaryAttackSfx();

    player.executeMeleeAttack(
      damage: damage,
      size: PlayerPrimaryAttackConfig.componentSize,
      centerOffset: attackOffset,
      animationRight: PlayerPrimaryAttackConfig.loadAnimationFxRight(),
      onDamage: (_) => player.addParticle(
        CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
        position: player.size / 2,
      ),
    );
  }

  static void executeFireballAttack({
    required SimplePlayer player,
    required double damage,
  }) {
    final Vector2 projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      player.lastDirection,
    );

    player.addParticle(
      CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
      position: player.size / 2,
    );

    CharacterFireballAttackConfig.playExecutionAudio();

    player.simpleAttackRangeByDirection(
      size: CharacterFireballAttackConfig.componentSize,
      speed: CharacterFireballAttackConfig.kSpeed,
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
      damage: damage,
      collision: CharacterFireballAttackConfig.createHitbox(),
      animationRight: CharacterFireballAttackConfig.loadExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadDestroyAnimation(),
      onDestroy: () => CharacterFireballAttackConfig.onDestroy(player.gameRef),
      direction: player.lastDirection,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }
}
