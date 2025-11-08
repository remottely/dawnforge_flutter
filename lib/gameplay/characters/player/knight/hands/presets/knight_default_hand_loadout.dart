import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_profile.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_utils.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

KnightHandLoadoutSetup createDefaultKnightHandLoadout() {
  // final rightHandData = KnightPickaxeHandPreset.create(
  //   id: 'sword',
  //   spritePath: KnightPlayerProfile.swordSpritePath,
  //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
  //   attachmentOffset: Vector2(8, 14),
  //   directionalOffset: Vector2(-6, 0), // left
  //   mirroredDirectionalOffset: Vector2(2, 0), // right
  // );

  // final leftHandData = KnightPickaxeHandPreset.create(
  //   id: 'staff',
  //   spritePath: KnightPlayerProfile.staffSpritePath,
  //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
  //   attachmentOffset: Vector2(8, 14),
  //   directionalOffset: Vector2(6, 0), // right
  //   mirroredDirectionalOffset: Vector2(-2, 0), // left
  // );

  // final rightHandData = KnightPickaxeHandPreset.create(
  //   id: 'sword_3',
  //   spritePath: KnightPlayerProfile.newWeapon07SpritePath,
  //   spriteSize: GameplayTileConstants.tileSizeStandard,
  //   attachmentOffset: Vector2(8, 16),
  //   directionalOffset: Vector2(-5, 0), // left
  //   mirroredDirectionalOffset: Vector2(-1, 0), // right
  // );

  final rightHandData = KnightPickaxeHandPreset.create(
    id: 'sword_3',
    spritePath: SunnyPlayerProfile.sword3SpritePath,
    spriteSize: Vector2(7, 22) * 0.4,
    attachmentOffset: Vector2(8, 13),
    directionalOffset: Vector2(-5, 0), // left
    mirroredDirectionalOffset: Vector2(-1, 0), // right
  );

  final leftHandData = KnightPickaxeHandPreset.create(
    id: 'new_shield_04',
    spritePath: SunnyPlayerProfile.steelShield1SpritePath,
    spriteSize: GameplayTileConstants.tileSizeStandard * 0.4,
    attachmentOffset: Vector2(6, 13),
    directionalOffset: Vector2(5, 1), // right
    mirroredDirectionalOffset: Vector2(4, 1), // left
  );

  const rightHandSyncSpec = SynchronizedAttackSpec(
    baseAttackSpeedMs: 800,
    speedBonusPerLevel: 0.05,
    attackTypeMultipliers: {
      AttackType.melee: 1.0,
      AttackType.ranged: 0.8,
      AttackType.special: 1.5,
      AttackType.combo: 0.6,
    },
  );

  const leftHandSyncSpec = SynchronizedAttackSpec(
    baseAttackSpeedMs: 800,
    speedBonusPerLevel: 0.05,
    attackTypeMultipliers: {
      AttackType.melee: 1.0,
      AttackType.ranged: 0.8,
      AttackType.special: 1.5,
      AttackType.combo: 0.6,
    },
  );

  return KnightHandLoadoutSetup(
    entries: [
      KnightHandLoadoutEntry(
        slot: KnightHandSlot.right,
        itemData: rightHandData,
        attack: KnightHandAttackSpec(
          trigger: KnightAttackTrigger.primary,
          attackType: AttackType.melee,
          syncSpec: rightHandSyncSpec,
          execute: (context, damage) {
            GameplayCameraEffectsUtils.primaryAttackShake(
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
        itemData: leftHandData,
        attack: KnightHandAttackSpec(
          trigger: KnightAttackTrigger.fireball,
          attackType: AttackType.ranged,
          syncSpec: leftHandSyncSpec,
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
                GameplayCameraEffectsUtils.fireballExplosionShake(
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
