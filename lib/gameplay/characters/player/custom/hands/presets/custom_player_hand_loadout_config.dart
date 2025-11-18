import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_animated_weapon_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_weapon_configs.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class CustomPlayerHandLoadoutConfig {
  CustomPlayerHandLoadoutConfig._();

  static CustomPlayerHandLoadoutSetup createDefaultCustomPlayerHandLoadout() {
    // Usar configuração centralizada de sword
    final config = CustomPlayerWeaponConfigs.sword;

    final swordData = CustomPlayerAnimatedWeaponPreset.create(
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
    final rightEntry = CustomPlayerHandLoadoutEntry(
      slot: CustomPlayerHandSlot.right,
      itemData: swordData,
      attack: CustomPlayerHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: SynchronizedAttackSpecConfig.standard,
        execute: (context, damage) {
          // ✅ IMPORTANTE: Configurar callback ANTES do ataque começar
          context.handController.setAttackFrameCallback(() {
            // Este código executa EXATAMENTE no frame 3 da animação
            print('💥 Aplicando dano: $damage');

            // Use centralized primary attack execution
            PlayerPrimaryAttackConfig.execute(
              player: context.player,
              damage: damage,
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
    final _leftHandData = CustomPlayerPickaxeHandPreset.create(
      id: 'new_shield_04',
      spritePath: KnightPlayerConfig.woodShield4SpritePath,
      spriteSize: TileConstants.tileSizeStandard * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(3, 1), // right
      mirroredDirectionalOffset: Vector2(2, 1), // left
    );

    const _leftHandSyncSpec = SynchronizedAttackSpecConfig.standard;

    final _leftHandEntry = CustomPlayerHandLoadoutEntry(
      slot: CustomPlayerHandSlot.left,
      itemData: _leftHandData,
      attack: CustomPlayerHandAttackSpec(
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
    final _rightHandData = CustomPlayerPickaxeHandPreset.create(
      id: 'sword_3',
      spritePath: KnightPlayerConfig.sword3SpritePath,
      spriteSize: Vector2(7, 22) * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(-5, 0), // left
      mirroredDirectionalOffset: Vector2(-1, 0), // right
    );

    const _rightHandSyncSpec = SynchronizedAttackSpecConfig.standard;

    final _rightHandEntry = CustomPlayerHandLoadoutEntry(
      slot: CustomPlayerHandSlot.right,
      itemData: _rightHandData,
      attack: CustomPlayerHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: _rightHandSyncSpec,
        execute: (context, damage) {
          // Use centralized primary attack execution
          PlayerPrimaryAttackConfig.execute(
            player: context.player,
            damage: damage,
          );
        },
      ),
    );

    /// Result
    // return CustomPlayerHandLoadoutSetup(entries: [_rightHandEntry, _leftHandEntry]);
    return CustomPlayerHandLoadoutSetup(entries: [rightEntry, _leftHandEntry]);
  }
}
