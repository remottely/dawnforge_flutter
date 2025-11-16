import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';

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

  /// Cria loadout baseado no equipamento atual do EquipmentManager
  KnightHandLoadoutSetup createLoadoutFromEquipment() {
    final entries = <KnightHandLoadoutEntry>[];

    // Right Hand = Weapon slot (Primary Attack)
    final weaponEntry = _createWeaponHandEntry();
    if (weaponEntry != null) {
      entries.add(weaponEntry);
    }

    // Left Hand = Offhand slot (Ranged Attack)
    final offhandEntry = _createOffhandHandEntry();
    if (offhandEntry != null) {
      entries.add(offhandEntry);
    }

    // Se nenhum equipamento, usar defaults
    if (entries.isEmpty) {
      developer.log('[EquipmentAdapter] No equipment, using defaults');
      return _createDefaultLoadout();
    }

    developer.log(
      '[EquipmentAdapter] Created loadout with ${entries.length} items',
    );
    return KnightHandLoadoutSetup(entries: entries);
  }

  /// Cria entry para Right Hand baseado no weapon slot
  KnightHandLoadoutEntry? _createWeaponHandEntry() {
    final weaponItem = EquipmentManager.instance.getEquippedItem(
      EquipmentSlotType.weapon,
    );

    if (weaponItem == null) {
      developer.log(
        '[EquipmentAdapter] No weapon equipped, using default sword',
      );
      return _createDefaultSwordEntry();
    }

    if (weaponItem is! WeaponItem) {
      developer.log('[EquipmentAdapter] Weapon slot has non-weapon item');
      return _createDefaultSwordEntry();
    }

    // Determinar tipo de arma e criar entry apropriado
    return _createWeaponEntryFromItem(weaponItem);
  }

  /// Cria entry para Left Hand baseado no offhand slot
  KnightHandLoadoutEntry? _createOffhandHandEntry() {
    final offhandItem = EquipmentManager.instance.getEquippedItem(
      EquipmentSlotType.offhand,
    );

    if (offhandItem == null) {
      developer.log(
        '[EquipmentAdapter] No offhand equipped, using default shield',
      );
      return _createDefaultShieldEntry();
    }

    if (offhandItem is! WeaponItem) {
      developer.log('[EquipmentAdapter] Offhand slot has non-weapon item');
      return _createDefaultShieldEntry();
    }

    // Determinar tipo de arma e criar entry apropriado
    return _createOffhandEntryFromItem(offhandItem);
  }

  /// Cria entry de weapon baseado no WeaponItem
  KnightHandLoadoutEntry _createWeaponEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType.toLowerCase();

    // Determinar sprite e configuração baseado no weaponType
    String spritePath;
    Vector2 spriteSize;
    Vector2 attachmentOffset;
    Vector2 directionalOffset;
    Vector2 mirroredDirectionalOffset;

    if (weaponType.contains('sword')) {
      // SWORD → Right Hand → Primary Attack (Melee)
      spritePath = _getSwordSpritePath(item);
      spriteSize = Vector2(7, 22) * 0.4;
      attachmentOffset = Vector2(0, 5);
      directionalOffset = Vector2(-5, 0);
      mirroredDirectionalOffset = Vector2(-1, 0);
    } else if (weaponType.contains('axe')) {
      spritePath = _getAxeSpritePath(item);
      spriteSize = Vector2(7, 22) * 0.4;
      attachmentOffset = Vector2(0, 5);
      directionalOffset = Vector2(-5, 0);
      mirroredDirectionalOffset = Vector2(-1, 0);
    } else if (weaponType.contains('mace')) {
      spritePath = _getMaceSpritePath(item);
      spriteSize = TileConstants.tileSizeStandard;
      attachmentOffset = Vector2(8, 16);
      directionalOffset = Vector2(-5, 0);
      mirroredDirectionalOffset = Vector2(-1, 0);
    } else {
      // Default sword
      spritePath = KnightPlayerConfig.sword3SpritePath;
      spriteSize = Vector2(7, 22) * 0.4;
      attachmentOffset = Vector2(0, 5);
      directionalOffset = Vector2(-5, 0);
      mirroredDirectionalOffset = Vector2(-1, 0);
    }

    final handData = KnightPickaxeHandPreset.create(
      id: item.id,
      spritePath: spritePath,
      spriteSize: spriteSize,
      attachmentOffset: attachmentOffset,
      directionalOffset: directionalOffset,
      mirroredDirectionalOffset: mirroredDirectionalOffset,
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

          CameraFx.primaryAttackShake(context.player.gameRef);
          AudioManager.instance.playPlayerPrimaryAttackSfx();
          context.player.addParticle(
            CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
            position: context.player.size,
          );
          context.player.simpleAttackMelee(
            size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
            damage: finalDamage,
            animationRight:
                CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
          );

          developer.log(
            '[EquipmentAdapter] Primary attack with ${item.name}: $finalDamage damage',
          );
        },
      ),
    );
  }

  /// Cria entry de offhand baseado no WeaponItem
  KnightHandLoadoutEntry _createOffhandEntryFromItem(WeaponItem item) {
    final weaponType = item.weaponType.toLowerCase();

    // Determinar sprite e configuração baseado no weaponType
    String spritePath;
    Vector2 spriteSize;
    Vector2 attachmentOffset;
    Vector2 directionalOffset;
    Vector2 mirroredDirectionalOffset;

    if (weaponType.contains('staff') || weaponType.contains('wand')) {
      // STAFF/WAND → Left Hand → Fireball Attack (Ranged)
      spritePath = _getStaffSpritePath(item);
      spriteSize = TileConstants.tileSizeStandard / 2;
      attachmentOffset = Vector2(0, 6);
      directionalOffset = Vector2(5, 0);
      mirroredDirectionalOffset = Vector2(0, 0);
    } else if (weaponType.contains('shield')) {
      spritePath = _getShieldSpritePath(item);
      spriteSize = TileConstants.tileSizeStandard * 0.4;
      attachmentOffset = Vector2(0, 5);
      directionalOffset = Vector2(3, 1);
      mirroredDirectionalOffset = Vector2(2, 1);
    } else {
      // Default shield (não tem ataque)
      spritePath = KnightPlayerConfig.woodShield4SpritePath;
      spriteSize = TileConstants.tileSizeStandard * 0.4;
      attachmentOffset = Vector2(0, 5);
      directionalOffset = Vector2(3, 1);
      mirroredDirectionalOffset = Vector2(2, 1);
    }

    final handData = KnightPickaxeHandPreset.create(
      id: item.id,
      spritePath: spritePath,
      spriteSize: spriteSize,
      attachmentOffset: attachmentOffset,
      directionalOffset: directionalOffset,
      mirroredDirectionalOffset: mirroredDirectionalOffset,
    );

    // Apenas staff/wand tem ataque fireball
    KnightHandAttackSpec? attackSpec;
    if (weaponType.contains('staff') || weaponType.contains('wand')) {
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
    }

    return KnightHandLoadoutEntry(
      slot: KnightHandSlot.left,
      itemData: handData,
      attack: attackSpec,
    );
  }

  // ==========================================================================
  // Sprite Path Resolvers
  // ==========================================================================

  String _getSwordSpritePath(WeaponItem item) {
    // TODO: Mapear item.iconPath ou item.id para sprite path real
    // Por enquanto, usar padrão
    return KnightPlayerConfig.sword3SpritePath;
  }

  String _getAxeSpritePath(WeaponItem item) {
    // TODO: Mapear item.iconPath ou item.id para sprite path real
    return KnightPlayerConfig.sword3SpritePath; // Placeholder
  }

  String _getMaceSpritePath(WeaponItem item) {
    // TODO: Mapear item.iconPath ou item.id para sprite path real
    return KnightPlayerConfig.sword3SpritePath; // Placeholder
  }

  String _getStaffSpritePath(WeaponItem item) {
    // TODO: Mapear item.iconPath ou item.id para sprite path real
    return KnightPlayerConfig.staffSpritePath;
  }

  String _getShieldSpritePath(WeaponItem item) {
    // TODO: Mapear item.iconPath ou item.id para sprite path real
    return KnightPlayerConfig.woodShield4SpritePath;
  }

  // ==========================================================================
  // Default Entries (quando não há equipamento)
  // ==========================================================================

  KnightHandLoadoutEntry _createDefaultSwordEntry() {
    final handData = KnightPickaxeHandPreset.create(
      id: 'default_sword',
      spritePath: KnightPlayerConfig.sword3SpritePath,
      spriteSize: Vector2(7, 22) * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(-5, 0),
      mirroredDirectionalOffset: Vector2(-1, 0),
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
  }

  KnightHandLoadoutEntry _createDefaultShieldEntry() {
    final handData = KnightPickaxeHandPreset.create(
      id: 'default_shield',
      spritePath: KnightPlayerConfig.woodShield4SpritePath,
      spriteSize: TileConstants.tileSizeStandard * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(3, 1),
      mirroredDirectionalOffset: Vector2(2, 1),
    );

    // Shield não tem ataque - apenas visual/defesa
    return KnightHandLoadoutEntry(
      slot: KnightHandSlot.left,
      itemData: handData,
      attack: null,
    );
  }

  KnightHandLoadoutSetup _createDefaultLoadout() {
    return KnightHandLoadoutSetup(
      entries: [_createDefaultSwordEntry(), _createDefaultShieldEntry()],
    );
  }
}
