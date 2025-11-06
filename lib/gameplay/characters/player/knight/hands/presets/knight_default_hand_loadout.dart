import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

KnightHandLoadoutConfig createDefaultKnightHandLoadout() {
  final rightHandConfig = KnightPickaxeHandPreset.create(
    id: 'sword',
    spritePath: KnightPlayerConfig.swordSpritePath,
    attachmentOffset: Vector2(8, 14),
    directionalOffset: Vector2(-6, 0), // left
    mirroredDirectionalOffset: Vector2(2, 0), // right
  );
  final leftHandConfig = KnightPickaxeHandPreset.create(
    id: 'staff',
    spritePath: KnightPlayerConfig.staffSpritePath,
    attachmentOffset: Vector2(8, 14),
    directionalOffset: Vector2(6, 0), // right
    mirroredDirectionalOffset: Vector2(-2, 0), // left
  );

  // Cada mão tem sua própria config de sincronização para permitir ataques independentes
  const rightHandSyncConfig = SynchronizedAttackConfig(
    baseAttackSpeedMs: 800,
    speedBonusPerLevel: 0.05,
    attackTypeMultipliers: {
      AttackType.melee: 1.0,
      AttackType.ranged: 0.8,
      AttackType.special: 1.5,
      AttackType.combo: 0.6,
    },
  );

  const leftHandSyncConfig = SynchronizedAttackConfig(
    baseAttackSpeedMs: 800,
    speedBonusPerLevel: 0.05,
    attackTypeMultipliers: {
      AttackType.melee: 1.0,
      AttackType.ranged: 0.8,
      AttackType.special: 1.5,
      AttackType.combo: 0.6,
    },
  );

  return KnightHandLoadoutConfig(
    entries: [
      KnightHandLoadoutEntry(
        slot: KnightHandSlot.right,
        itemConfig: rightHandConfig,
        attack: KnightHandAttackConfig(
          trigger: KnightAttackTrigger.primary,
          attackType: AttackType.melee,
          syncConfig: rightHandSyncConfig,
          execute: (context, damage) {
            GameplayCameraEffectsConfig.primaryAttackShake(
              context.player.gameRef,
            );
            GameplayAudioManager.instance.playPlayerPrimaryAttackSfx();
            context.player.addParticle(
              CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
              position: context.player.size,
            );
            context.player.simpleAttackMelee(
              size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
              damage: damage,
              animationRight:
                  CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
            );
          },
        ),
      ),
      KnightHandLoadoutEntry(
        slot: KnightHandSlot.left,
        itemConfig: leftHandConfig,
        attack: KnightHandAttackConfig(
          trigger: KnightAttackTrigger.fireball,
          attackType: AttackType.ranged,
          syncConfig: leftHandSyncConfig,
          execute: (context, damage) {
            context.player.addParticle(
              CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
              position: context.player.size,
            );
            context.player.simpleAttackRange(
              animationRight:
                  CharacterFireballAttackConfig.createExecutionAnimation(),
              animationDestroy:
                  CharacterFireballAttackConfig.createDestroyAnimation(),
              size: CharacterFireballAttackConfig.componentSize,
              damage: damage,
              speed:
                  context.player.speed *
                  CharacterFireballAttackConfig.kSpeedMultiplier,
              onDestroy: () {
                CharacterFireballAttackConfig.playDestroyAudio();
                GameplayCameraEffectsConfig.fireballExplosionShake(
                  context.player.gameRef,
                );
              },
              collision: CharacterFireballAttackConfig.createHitbox(),
              lightingConfig: CharacterFireballAttackConfig.lightingConfig,
            );
            CharacterFireballAttackConfig.playExecutionAudio();
          },
        ),
      ),
    ],
  );
}
