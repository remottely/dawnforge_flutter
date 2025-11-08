import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_utils.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

final class KnightHandLoadoutConfig {
  KnightHandLoadoutConfig._();

  static KnightHandLoadoutSetup createDefaultKnightHandLoadout() {
    // final _rightHandData = KnightPickaxeHandPreset.create(
    //   id: 'sword',
    //   spritePath: KnightPlayerProfile.swordSpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
    //   attachmentOffset: Vector2(8, 14),
    //   directionalOffset: Vector2(-6, 0), // left
    //   mirroredDirectionalOffset: Vector2(2, 0), // right
    // );

    // final _leftHandData = KnightPickaxeHandPreset.create(
    //   id: 'staff',
    //   spritePath: KnightPlayerProfile.staffSpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
    //   attachmentOffset: Vector2(8, 14),
    //   directionalOffset: Vector2(6, 0), // right
    //   mirroredDirectionalOffset: Vector2(-2, 0), // left
    // );

    // final _rightHandData = KnightPickaxeHandPreset.create(
    //   id: 'sword_3',
    //   spritePath: KnightPlayerProfile.newWeapon07SpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard,
    //   attachmentOffset: Vector2(8, 16),
    //   directionalOffset: Vector2(-5, 0), // left
    //   mirroredDirectionalOffset: Vector2(-1, 0), // right
    // );

    /// Left Hand
    final _leftHandData = KnightPickaxeHandPreset.create(
      id: 'new_shield_04',
      spritePath: SunnyPlayerConfig.steelShield1SpritePath,
      spriteSize: GameplayTileConstants.tileSizeStandard * 0.4,
      attachmentOffset: Vector2(6, 13),
      directionalOffset: Vector2(5, 1), // right
      mirroredDirectionalOffset: Vector2(4, 1), // left
    );

    const _leftHandSyncSpec = SynchronizedAttackSpecConfig.standard;

    final _leftHandEntry = KnightHandLoadoutEntry(
      slot: KnightHandSlot.left,
      itemData: _leftHandData,
      attack: KnightHandAttackSpec(
        trigger: KnightAttackTrigger.fireball,
        attackType: AttackType.ranged,
        syncSpec: _leftHandSyncSpec,
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
            speed: CharacterFireballAttackConfig.kSpeed,
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
    );

    /// Right Hand
    final _rightHandData = KnightPickaxeHandPreset.create(
      id: 'sword_3',
      spritePath: SunnyPlayerConfig.sword3SpritePath,
      spriteSize: Vector2(7, 22) * 0.4,
      attachmentOffset: Vector2(8, 13),
      directionalOffset: Vector2(-5, 0), // left
      mirroredDirectionalOffset: Vector2(-1, 0), // right
    );

    const _rightHandSyncSpec = SynchronizedAttackSpecConfig.standard;

    final _rightHandEntry = KnightHandLoadoutEntry(
      slot: KnightHandSlot.right,
      itemData: _rightHandData,
      attack: KnightHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: _rightHandSyncSpec,
        execute: (context, damage) {
          GameplayCameraEffectsUtils.primaryAttackShake(context.player.gameRef);
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
    );

    /// Result
    return KnightHandLoadoutSetup(entries: [_rightHandEntry, _leftHandEntry]);
  }
}
