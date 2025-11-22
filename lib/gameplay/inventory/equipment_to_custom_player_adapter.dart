import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_animated_weapon_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/presets/custom_player_weapon_configs.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';

/// Adaptador que converte equipamentos do InventoryManager
/// para o sistema de hands do Custom Player
///
/// Responsável por:
/// - Sincronizar EquipmentManager → CustomPlayerHandLoadout
/// - Mapear weapon → Right Hand (Primary Attack - Melee)
/// - Mapear offhand → Left Hand (Ranged Attack - Fireball)
/// - Detectar mudanças de equipamento e atualizar loadout
final class EquipmentToCustomPlayerAdapter {
  EquipmentToCustomPlayerAdapter._();

  static final instance = EquipmentToCustomPlayerAdapter._();

  // ==========================================================================
  // CONFIGURAÇÕES CENTRALIZADAS DE EQUIPAMENTOS
  // ==========================================================================

  /// Busca configuração visual para weapon type (Right Hand)
  static CustomPlayerWeaponVisualConfig _getWeaponConfig(
    WeaponType weaponType,
  ) {
    switch (weaponType) {
      case WeaponType.ironSword:
        return CustomPlayerWeaponConfigs.toolsAttackStrip10;
      // case WeaponType.digger:
      //   return CustomPlayerWeaponConfigs.toolsDigStrip13;
      // case WeaponType.wateringCan:
      //   return CustomPlayerWeaponConfigs.toolsWateringCanStrip13;
      // case WeaponType.seeds:
      //   return CustomPlayerWeaponConfigs.toolsSeedStrip13;
      case WeaponType.axe:
        return CustomPlayerWeaponConfigs.axe;
      case WeaponType.mace:
        return CustomPlayerWeaponConfigs.mace;
      default:
        return CustomPlayerWeaponConfigs.defaultWeapon;
    }
  }

  /// Busca configuração visual para offhand type (Left Hand)
  static CustomPlayerWeaponVisualConfig _getOffhandConfig(
    WeaponType weaponType,
  ) {
    switch (weaponType) {
      case WeaponType.staff:
        return CustomPlayerOffhandConfigs.staff;
      case WeaponType.wand:
        return CustomPlayerOffhandConfigs.wand;
      case WeaponType.shield:
        return CustomPlayerOffhandConfigs.shield;
      default:
        return CustomPlayerOffhandConfigs.defaultOffhand;
    }
  }

  /// Cria loadout baseado no equipamento atual do EquipmentManager
  CustomPlayerHandLoadoutSetup createLoadoutFromEquipment() {
    final entries = <CustomPlayerHandLoadoutEntry>[];

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
      return CustomPlayerHandLoadoutSetup(entries: []);
    }

    developer.log(
      '[EquipmentAdapter] Created loadout with ${entries.length} items',
    );
    return CustomPlayerHandLoadoutSetup(entries: entries);
  }

  /// Cria entry para Right Hand baseado no weapon slot
  /// APENAS aceita SWORD e AXE
  CustomPlayerHandLoadoutEntry? _createWeaponHandEntry() {
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

    // final weaponType = weaponItem.weaponType;

    // // VALIDAÇÃO: Apenas sword e axe permitidos no weapon slot
    // if (weaponType != WeaponType.sword && weaponType != WeaponType.axe) {
    //   developer.log(
    //     '[EquipmentAdapter] Invalid weapon type for right hand: $weaponType (only sword/axe allowed)',
    //   );
    //   return null;
    // }

    // Determinar tipo de arma e criar entry apropriado
    return _createWeaponEntryFromItem(weaponItem);
  }

  /// Cria entry para Left Hand baseado no offhand slot
  /// APENAS aceita SHIELD e STAFF
  CustomPlayerHandLoadoutEntry? _createOffhandHandEntry() {
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
  CustomPlayerHandLoadoutEntry _createWeaponEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType;

    // Buscar configuração centralizada
    final config = _getWeaponConfig(weaponType);

    // Criar hand data baseado no tipo (animação ou sprite)
    final handData = config.useAnimation
        ? CustomPlayerAnimatedWeaponPreset.create(
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
        : CustomPlayerPickaxeHandPreset.create(
            id: item.id,
            spritePath: config.spritePath!,
            spriteSize: config.size,
            attachmentOffset: config.attachmentOffset,
            directionalOffset: config.directionalOffset,
            mirroredDirectionalOffset: config.mirroredDirectionalOffset,
          );

    const syncSpec = SynchronizedAttackSpecConfig.standard;

    return CustomPlayerHandLoadoutEntry(
      slot: CustomPlayerHandSlot.right,
      itemData: handData,
      attack: CustomPlayerHandAttackSpec(
        trigger: CustomPlayerAttackTrigger.primary,
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
    CustomPlayerAttackExecutionContext context,
    double damage,
    WeaponItem item,
  ) {
    // Use centralized primary attack execution
    PlayerPrimaryAttackConfig.execute(player: context.player, damage: damage);

    developer.log(
      '[EquipmentAdapter] Primary attack with ${item.name}: $damage damage',
    );
  }

  /// Cria entry de offhand baseado no WeaponItem
  CustomPlayerHandLoadoutEntry _createOffhandEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType;

    // Buscar configuração centralizada
    final config = _getOffhandConfig(weaponType);

    final handData = CustomPlayerPickaxeHandPreset.create(
      id: item.id,
      spritePath: config.spritePath!,
      spriteSize: config.size,
      attachmentOffset: config.attachmentOffset,
      directionalOffset: config.directionalOffset,
      mirroredDirectionalOffset: config.mirroredDirectionalOffset,
    );

    // Apenas staff/wand tem ataque fireball, shield tem defesa
    CustomPlayerHandAttackSpec? attackSpec;
    if (weaponType == WeaponType.staff || weaponType == WeaponType.wand) {
      const syncSpec = SynchronizedAttackSpecConfig.standard;

      attackSpec = CustomPlayerHandAttackSpec(
        trigger: CustomPlayerAttackTrigger.fireball,
        attackType: AttackType.ranged,
        syncSpec: syncSpec,
        execute: (context, damage) {
          // Usar dano da arma equipada
          final weaponDamage = (item.damage).toDouble();
          final finalDamage = weaponDamage > 0 ? weaponDamage : damage;

          CharacterFireballAttackConfig.playerExecute(
            player: context.player,
            damage: finalDamage,
          );
        },
      );
    } else if (weaponType == WeaponType.shield) {
      // Shield tem spec de defesa (sem syncSpec pois não é ataque)
      const syncSpec = SynchronizedAttackSpecConfig.standard;

      attackSpec = CustomPlayerHandAttackSpec(
        trigger: CustomPlayerAttackTrigger.shieldDefense,
        attackType: AttackType.melee, // Tipo irrelevante para defesa
        syncSpec: syncSpec,
        execute: (context, damage) {
          // A defesa é gerenciada pelo input handler
          // Este execute não é chamado diretamente
          developer.log('[EquipmentAdapter] Shield defense active');
        },
      );
    }

    return CustomPlayerHandLoadoutEntry(
      slot: CustomPlayerHandSlot.left,
      itemData: handData,
      attack: attackSpec,
    );
  }

  // ==========================================================================
  // REMOVIDO: Não há mais defaults!
  // Quando não há equipamento, as mãos ficam vazias.
  // ==========================================================================
}
