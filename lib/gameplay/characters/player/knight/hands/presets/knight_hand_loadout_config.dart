import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_animated_weapon_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_weapon_configs.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

final class KnightHandLoadoutConfig {
  KnightHandLoadoutConfig._();

  static KnightHandLoadoutSetup createDefaultKnightHandLoadout() {
    // Usar configuração centralizada de sword
    final config = KnightWeaponConfigs.sword;

    final swordData = KnightAnimatedWeaponPreset.create(
      id: 'iron_sword',
      idlePath: config.idlePath!,
      idleFrameCount: config.idleFrameCount!,
      idleFrameDuration: config.idleFrameDuration!,
      attackPath: config.attackPath!,
      attackFrameCount: config.attackFrameCount!,
      attackFrameIndex: config.attackFrameIndex!,
      attackDuration: config.attackDuration!,
      textureSize: config.textureSize,
      size: config.size,
      attachmentOffset: config.attachmentOffset,
      directionalOffset: config.directionalOffset,
      mirroredDirectionalOffset: config.mirroredDirectionalOffset,
    );

    // Criar entry com callback de frame
    final rightEntry = KnightHandLoadoutEntry(
      slot: KnightHandSlot.right,
      itemData: swordData,
      attack: KnightHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: SynchronizedAttackSpecConfig.standard,
        execute: (context, damage) {
          // ✅ IMPORTANTE: Configurar callback ANTES do ataque começar
          context.handController.setAttackFrameCallback(() {
            // Este código executa EXATAMENTE no frame 3 da animação
            print('💥 Aplicando dano: $damage');

            // Aplicar hitbox de dano
            final attackOffset = OffsetHelper.getCenterOffset(
              Vector2(6, 0),
              context.player.lastDirection,
            );

            context.player.simpleAttackMelee(
              damage: damage,
              size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
              centerOffset: attackOffset,
              animationRight:
                  CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
            );

            // Efeitos visuais e sonoros
            CameraFx.primaryAttackShake(context.player.gameRef);
            AudioManager.instance.playPlayerPrimaryAttackSfx();
            context.player.addParticle(
              CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
              position: context.player.size,
            );
          });

          // A animação da mão começa automaticamente
          // O callback acima será executado quando atingir o frame 3
        },
      ),
    );

    // final _rightHandData = KnightPickaxeHandPreset.create(
    //   id: 'sword',
    //   spritePath: KnightPlayerConfig.swordSpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
    //   attachmentOffset: Vector2(8, 14),
    //   directionalOffset: Vector2(-6, 0), // left
    //   mirroredDirectionalOffset: Vector2(2, 0), // right
    // );

    // final _leftHandData = KnightPickaxeHandPreset.create(
    //   id: 'staff',
    //   spritePath: KnightPlayerConfig.staffSpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard / 2,
    //   attachmentOffset: Vector2(8, 14),
    //   directionalOffset: Vector2(6, 0), // right
    //   mirroredDirectionalOffset: Vector2(-2, 0), // left
    // );

    // final _rightHandData = KnightPickaxeHandPreset.create(
    //   id: 'sword_3',
    //   spritePath: KnightPlayerConfig.newWeapon07SpritePath,
    //   spriteSize: GameplayTileConstants.tileSizeStandard,
    //   attachmentOffset: Vector2(8, 16),
    //   directionalOffset: Vector2(-5, 0), // left
    //   mirroredDirectionalOffset: Vector2(-1, 0), // right
    // );

    /// Left Hand
    final _leftHandData = KnightPickaxeHandPreset.create(
      id: 'new_shield_04',
      spritePath: KnightPlayerConfig.woodShield4SpritePath,
      spriteSize: TileConstants.tileSizeStandard * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(3, 1), // right
      mirroredDirectionalOffset: Vector2(2, 1), // left
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
          CharacterFireballAttackConfig.playerExecute(
            player: context.player,
            damage: damage,
          );

          CharacterFireballAttackConfig.playExecutionAudio();
        },
      ),
    );

    /// Right Hand
    final _rightHandData = KnightPickaxeHandPreset.create(
      id: 'sword_3',
      spritePath: KnightPlayerConfig.sword3SpritePath,
      spriteSize: Vector2(7, 22) * 0.4,
      attachmentOffset: Vector2(0, 5),
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
          CameraFx.primaryAttackShake(context.player.gameRef);
          AudioManager.instance.playPlayerPrimaryAttackSfx();
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
    // return KnightHandLoadoutSetup(entries: [_rightHandEntry, _leftHandEntry]);
    return KnightHandLoadoutSetup(entries: [rightEntry, _leftHandEntry]);
  }
}
