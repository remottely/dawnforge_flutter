import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_animated_weapon_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_weapon_configs.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';

/// Adaptador que converte equipamentos do InventoryManager
/// para o sistema de hands do Knight Player
///
/// Responsável por:
/// - Sincronizar EquipmentManager → KnightHandLoadout
/// - Mapear weapon → Right Hand (Primary Attack - Melee)
/// - Mapear offhand → Left Hand (Ranged Attack - Fireball)
/// - Detectar mudanças de equipamento e atualizar loadout
final class EquipmentToKnightAdapter {
  EquipmentToKnightAdapter._();

  static final instance = EquipmentToKnightAdapter._();

  // ==========================================================================
  // CONFIGURAÇÕES CENTRALIZADAS DE EQUIPAMENTOS
  // ==========================================================================

  /// Busca configuração visual para weapon type (Right Hand)
  static KnightWeaponVisualConfig _getWeaponConfig(WeaponType weaponType) {
    switch (weaponType) {
      case WeaponType.sword:
        return KnightWeaponConfigs.sword;
      case WeaponType.axe:
        return KnightWeaponConfigs.axe;
      case WeaponType.mace:
        return KnightWeaponConfigs.mace;
      default:
        return KnightWeaponConfigs.defaultWeapon;
    }
  }

  /// Busca configuração visual para offhand type (Left Hand)
  static KnightWeaponVisualConfig _getOffhandConfig(WeaponType weaponType) {
    switch (weaponType) {
      case WeaponType.staff:
        return KnightOffhandConfigs.staff;
      case WeaponType.wand:
        return KnightOffhandConfigs.wand;
      case WeaponType.shield:
        return KnightOffhandConfigs.shield;
      default:
        return KnightOffhandConfigs.defaultOffhand;
    }
  }

  /// Cria loadout baseado no equipamento atual do EquipmentManager
  KnightHandLoadoutSetup createLoadoutFromEquipment() {
    final entries = <KnightHandLoadoutEntry>[];

    // Right Hand = Weapon slot (Primary Attack - Space)
    // Apenas SWORD e AXE permitidos
    final weaponEntry = _createWeaponHandEntry();
    if (weaponEntry != null) {
      entries.add(weaponEntry);
    }

    // Left Hand = Offhand slot (Ranged Attack - Z)
    // Apenas SHIELD e STAFF permitidos
    final offhandEntry = _createOffhandHandEntry();
    if (offhandEntry != null) {
      entries.add(offhandEntry);
    }

    // Se nenhum equipamento, retornar loadout vazio (sem defaults)
    if (entries.isEmpty) {
      developer.log('[EquipmentAdapter] No equipment, empty hands');
      return KnightHandLoadoutSetup(entries: []);
    }

    developer.log(
      '[EquipmentAdapter] Created loadout with ${entries.length} items',
    );
    return KnightHandLoadoutSetup(entries: entries);
  }

  /// Cria entry para Right Hand baseado no weapon slot
  /// APENAS aceita SWORD e AXE
  KnightHandLoadoutEntry? _createWeaponHandEntry() {
    final weaponItem = EquipmentManager.instance.getEquippedItem(
      EquipmentSlotType.weapon,
    );

    if (weaponItem == null) {
      developer.log('[EquipmentAdapter] No weapon equipped, right hand empty');
      return null; // Mão vazia!
    }

    if (weaponItem is! WeaponItem) {
      developer.log('[EquipmentAdapter] Weapon slot has non-weapon item');
      return null;
    }

    final weaponType = weaponItem.weaponType;

    // VALIDAÇÃO: Apenas sword e axe permitidos no weapon slot
    if (weaponType != WeaponType.sword && weaponType != WeaponType.axe) {
      developer.log(
        '[EquipmentAdapter] Invalid weapon type for right hand: $weaponType (only sword/axe allowed)',
      );
      return null;
    }

    // Determinar tipo de arma e criar entry apropriado
    return _createWeaponEntryFromItem(weaponItem);
  }

  /// Cria entry para Left Hand baseado no offhand slot
  /// APENAS aceita SHIELD e STAFF
  KnightHandLoadoutEntry? _createOffhandHandEntry() {
    final offhandItem = EquipmentManager.instance.getEquippedItem(
      EquipmentSlotType.offhand,
    );

    if (offhandItem == null) {
      developer.log('[EquipmentAdapter] No offhand equipped, left hand empty');
      return null; // Mão vazia!
    }

    if (offhandItem is! WeaponItem) {
      developer.log('[EquipmentAdapter] Offhand slot has non-weapon item');
      return null;
    }

    final weaponType = offhandItem.weaponType;

    // VALIDAÇÃO: Apenas shield e staff permitidos no offhand slot
    if (weaponType != WeaponType.shield &&
        weaponType != WeaponType.staff &&
        weaponType != WeaponType.wand) {
      developer.log(
        '[EquipmentAdapter] Invalid weapon type for left hand: $weaponType (only shield/staff/wand allowed)',
      );
      return null;
    }

    // Determinar tipo de arma e criar entry apropriado
    return _createOffhandEntryFromItem(offhandItem);
  }

  /// Cria entry de weapon baseado no WeaponItem
  KnightHandLoadoutEntry _createWeaponEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType;

    // Buscar configuração centralizada
    final config = _getWeaponConfig(weaponType);

    // Criar hand data baseado no tipo (animação ou sprite)
    final handData = config.useAnimation
        ? KnightAnimatedWeaponPreset.create(
            id: item.id,
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
          )
        : KnightPickaxeHandPreset.create(
            id: item.id,
            spritePath: config.spritePath!,
            spriteSize: config.size,
            attachmentOffset: config.attachmentOffset,
            directionalOffset: config.directionalOffset,
            mirroredDirectionalOffset: config.mirroredDirectionalOffset,
          );

    const syncSpec = SynchronizedAttackSpecConfig.standard;

    return KnightHandLoadoutEntry(
      slot: KnightHandSlot.right,
      itemData: handData,
      attack: KnightHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: syncSpec,
        execute: (context, damage) {
          // Usar dano da arma equipada
          final weaponDamage = (item.damage).toDouble();
          final finalDamage = weaponDamage > 0 ? weaponDamage : damage;

          // Se for animação, configurar callback de frame
          if (config.useAnimation) {
            context.handController.setAttackFrameCallback(() {
              _executeWeaponAttack(context, finalDamage, item);
            });
          } else {
            // Sprite legado: executar imediatamente
            _executeWeaponAttack(context, finalDamage, item);
          }
        },
      ),
    );
  }

  /// Executa o ataque de arma (compartilhado entre sprite e animação)
  void _executeWeaponAttack(
    KnightAttackExecutionContext context,
    double damage,
    WeaponItem item,
  ) {
    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(6, 0),
      context.player.lastDirection,
    );

    CameraFx.primaryAttackShake(context.player.gameRef);
    AudioManager.instance.playPlayerPrimaryAttackSfx();
    context.player.addParticle(
      CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
      position: context.player.size,
    );
    context.player.simpleAttackMelee(
      size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
      damage: damage,
      centerOffset: attackOffset,
      animationRight:
          CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
    );

    developer.log(
      '[EquipmentAdapter] Primary attack with ${item.name}: $damage damage',
    );
  }

  /// Cria entry de offhand baseado no WeaponItem
  KnightHandLoadoutEntry _createOffhandEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType;

    // Buscar configuração centralizada
    final config = _getOffhandConfig(weaponType);

    final handData = KnightPickaxeHandPreset.create(
      id: item.id,
      spritePath: config.spritePath!,
      spriteSize: config.size,
      attachmentOffset: config.attachmentOffset,
      directionalOffset: config.directionalOffset,
      mirroredDirectionalOffset: config.mirroredDirectionalOffset,
    );

    // Apenas staff/wand tem ataque fireball, shield tem defesa
    KnightHandAttackSpec? attackSpec;
    if (weaponType == WeaponType.staff || weaponType == WeaponType.wand) {
      const syncSpec = SynchronizedAttackSpecConfig.standard;

      attackSpec = KnightHandAttackSpec(
        trigger: KnightAttackTrigger.fireball,
        attackType: AttackType.ranged,
        syncSpec: syncSpec,
        execute: (context, damage) {
          // Usar dano da arma equipada
          final weaponDamage = (item.damage).toDouble();
          final finalDamage = weaponDamage > 0 ? weaponDamage : damage;

          context.player.addParticle(
            CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
            position: context.player.size,
          );
          CharacterFireballAttackConfig.playerExecute(
            player: context.player,
            damage: finalDamage,
          );
          CharacterFireballAttackConfig.playExecutionAudio();

          developer.log(
            '[EquipmentAdapter] Fireball attack with ${item.name}: $finalDamage damage',
          );
        },
      );
    } else if (weaponType == WeaponType.shield) {
      // Shield tem spec de defesa (sem syncSpec pois não é ataque)
      const syncSpec = SynchronizedAttackSpecConfig.standard;

      attackSpec = KnightHandAttackSpec(
        trigger: KnightAttackTrigger.shieldDefense,
        attackType: AttackType.melee, // Tipo irrelevante para defesa
        syncSpec: syncSpec,
        execute: (context, damage) {
          // A defesa é gerenciada pelo input handler
          // Este execute não é chamado diretamente
          developer.log('[EquipmentAdapter] Shield defense active');
        },
      );
    }

    return KnightHandLoadoutEntry(
      slot: KnightHandSlot.left,
      itemData: handData,
      attack: attackSpec,
    );
  }

  // ==========================================================================
  // REMOVIDO: Não há mais defaults!
  // Quando não há equipamento, as mãos ficam vazias.
  // ==========================================================================
}
