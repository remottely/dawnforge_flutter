import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fireball_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/player_primary_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/shared/framework/player/mixins/dd_base_player_extension.dart';

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
      size: PlayerPrimaryAttackDef.componentSize,
      centerOffset: attackOffset,
      animationRight: PlayerPrimaryAttackDef.loadAnimationFxRight(),
      onDamage: (_) => player.addParticle(
        CharacterFxParticlesAnimationsDef.createPrimaryAttackParticles(),
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
      CharacterFxParticlesAnimationsDef.createFireballAttackParticles(),
      position: player.size / 2,
    );

    CharacterFireballAttackDef.playAudioExecution();

    player.simpleAttackRangeByDirection(
      size: CharacterFireballAttackDef.componentSize,
      speed: CharacterFireballAttackDef.kSpeed,
      lightingConfig: CharacterFireballAttackDef.lighting,
      damage: damage,
      collision: CharacterFireballAttackDef.createHitbox(),
      animationRight: CharacterFireballAttackDef.loadAnimationExecution(),
      animationDestroy: CharacterFireballAttackDef.loadAnimationDestroy(),
      onDestroy: () => CharacterFireballAttackDef.onDestroy(player.gameRef),
      direction: player.lastDirection,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }
}
