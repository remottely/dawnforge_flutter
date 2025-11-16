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

/// Configuração visual de um tipo de equipamento
class _EquipmentVisualConfig {
  final String Function(WeaponItem) spritePathResolver;
  final Vector2 spriteSize;
  final Vector2 attachmentOffset;
  final Vector2 directionalOffset;
  final Vector2 mirroredDirectionalOffset;

  const _EquipmentVisualConfig({
    required this.spritePathResolver,
    required this.spriteSize,
    required this.attachmentOffset,
    required this.directionalOffset,
    required this.mirroredDirectionalOffset,
  });
}

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

  /// Configurações visuais para equipamentos de Right Hand (weapon slot)
  static final Map<String, _EquipmentVisualConfig> _weaponConfigs = {
    'sword': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.sword3SpritePath,
      spriteSize: Vector2(7, 22) * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(-5, 0),
      mirroredDirectionalOffset: Vector2(-1, 0),
    ),
    'axe': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.axeNormal1SpritePath,
      spriteSize: Vector2(16, 22) * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(-5, 0),
      mirroredDirectionalOffset: Vector2(-1, 0),
    ),
    'mace': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.sword3SpritePath,
      spriteSize: TileConstants.tileSizeStandard,
      attachmentOffset: Vector2(8, 16),
      directionalOffset: Vector2(-5, 0),
      mirroredDirectionalOffset: Vector2(-1, 0),
    ),
  };

  /// Configurações visuais para equipamentos de Left Hand (offhand slot)
  static final Map<String, _EquipmentVisualConfig> _offhandConfigs = {
    'staff': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.staffSpritePath,
      spriteSize: TileConstants.tileSizeStandard / 2,
      attachmentOffset: Vector2(0, 6),
      directionalOffset: Vector2(5, 0),
      mirroredDirectionalOffset: Vector2(0, 0),
    ),
    'wand': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.staffSpritePath,
      spriteSize: TileConstants.tileSizeStandard / 2,
      attachmentOffset: Vector2(0, 6),
      directionalOffset: Vector2(5, 0),
      mirroredDirectionalOffset: Vector2(0, 0),
    ),
    'shield': _EquipmentVisualConfig(
      spritePathResolver: (item) => KnightPlayerConfig.woodShield4SpritePath,
      spriteSize: TileConstants.tileSizeStandard * 0.4,
      attachmentOffset: Vector2(0, 5),
      directionalOffset: Vector2(3, 1),
      mirroredDirectionalOffset: Vector2(2, 1),
    ),
  };

  /// Configuração padrão para weapon (fallback)
  static final _defaultWeaponConfig = _EquipmentVisualConfig(
    spritePathResolver: (item) => KnightPlayerConfig.sword3SpritePath,
    spriteSize: Vector2(7, 22) * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(-5, 0),
    mirroredDirectionalOffset: Vector2(-1, 0),
  );

  /// Configuração padrão para offhand (fallback)
  static final _defaultOffhandConfig = _EquipmentVisualConfig(
    spritePathResolver: (item) => KnightPlayerConfig.woodShield4SpritePath,
    spriteSize: TileConstants.tileSizeStandard * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(3, 1),
    mirroredDirectionalOffset: Vector2(2, 1),
  );

  /// Busca configuração visual para weapon type (Right Hand)
  static _EquipmentVisualConfig _getWeaponConfig(String weaponType) {
    final normalizedType = weaponType.toLowerCase();

    for (final entry in _weaponConfigs.entries) {
      if (normalizedType.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultWeaponConfig;
  }

  /// Busca configuração visual para offhand type (Left Hand)
  static _EquipmentVisualConfig _getOffhandConfig(String weaponType) {
    final normalizedType = weaponType.toLowerCase();

    for (final entry in _offhandConfigs.entries) {
      if (normalizedType.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultOffhandConfig;
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

    final weaponType = weaponItem.weaponType.toLowerCase();

    // VALIDAÇÃO: Apenas sword e axe permitidos no weapon slot
    if (!weaponType.contains('sword') && !weaponType.contains('axe')) {
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

    final weaponType = offhandItem.weaponType.toLowerCase();

    // VALIDAÇÃO: Apenas shield e staff permitidos no offhand slot
    if (!weaponType.contains('shield') &&
        !weaponType.contains('staff') &&
        !weaponType.contains('wand')) {
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
    final weaponType = item.weaponType.toLowerCase();

    // Buscar configuração centralizada
    final config = _getWeaponConfig(weaponType);
    final spritePath = config.spritePathResolver(item);

    final handData = KnightPickaxeHandPreset.create(
      id: item.id,
      spritePath: spritePath,
      spriteSize: config.spriteSize,
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

    // Buscar configuração centralizada
    final config = _getOffhandConfig(weaponType);
    final spritePath = config.spritePathResolver(item);

    final handData = KnightPickaxeHandPreset.create(
      id: item.id,
      spritePath: spritePath,
      spriteSize: config.spriteSize,
      attachmentOffset: config.attachmentOffset,
      directionalOffset: config.directionalOffset,
      mirroredDirectionalOffset: config.mirroredDirectionalOffset,
    );

    // Apenas staff/wand tem ataque fireball, shield tem defesa
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
    } else if (weaponType.contains('shield')) {
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
