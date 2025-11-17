// ============================================================================
// EXEMPLO 1: Mantendo Sistema Legado (Sprite)
// ============================================================================

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_pickaxe_hand_preset.dart';

void exemploSpriteLegado() {
  // Continua funcionando exatamente como antes
  final pickaxeData = KnightPickaxeHandPreset.create(
    id: 'iron_pickaxe',
    spritePath: 'tools/pickaxe.png',
    spriteSize: Vector2(32, 32),
    attachmentOffset: Vector2(0, -28),
    directionalOffset: Vector2(20, 0),
    mirroredDirectionalOffset: Vector2(-20, 0),
  );

  // Criar entry com ataque
  final entry = KnightHandLoadoutEntry(
    slot: KnightHandSlot.right,
    itemData: pickaxeData,
    attack: KnightHandAttackSpec(
      trigger: KnightAttackTrigger.primary,
      attackType: AttackType.melee,
      syncSpec: SynchronizedAttackSpecConfig.standard,
      execute: (context, damage) {
        // Sistema legado: rotação via código
        context.player.simpleAttackMelee(
          damage: damage,
          size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
        );
      },
    ),
  );
}

// ============================================================================
// EXEMPLO 2: Novo Sistema (Animação)
// ============================================================================

import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_animated_weapon_preset.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';

void exemploAnimacaoNova() {
  // Criar sword com animação
  final swordData = KnightAnimatedWeaponPreset.create(
    id: 'iron_sword',
    animationPath: 'weapons/sword_slash_strip6.png',
    frameCount: 6,
    attackFrameIndex: 3, // Dano aplicado no frame 3
    animationDuration: Duration(milliseconds: 400),
    textureSize: Vector2(64, 64),
    size: Vector2(64, 64),
    attachmentOffset: Vector2(0, -32),
    directionalOffset: Vector2(20, 0),
    mirroredDirectionalOffset: Vector2(-20, 0),
  );

  // Criar entry com callback de frame
  final entry = KnightHandLoadoutEntry(
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
            animationRight: CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
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
}

// ============================================================================
// EXEMPLO 3: Criar Animação Customizada
// ============================================================================

void exemploAnimacaoCustomizada() {
  // Criar dados da animação manualmente
  final hammerAnimation = KnightHandAnimationData(
    spritePath: 'weapons/warhammer_slam_strip10.png',
    frameCount: 10,
    attackFrameIndex: 7, // Ataque pesado, dano no final
    animationDuration: Duration(milliseconds: 800), // Ataque lento
    textureSize: Vector2(96, 96), // Sprite grande
    loop: false,
  );

  // Criar item data com animação customizada
  final hammerData = KnightHandItemData(
    id: 'steel_warhammer',
    animationData: hammerAnimation,
    size: Vector2(96, 96),
    slotSpecs: {
      KnightHandSlot.right: KnightHandSlotSpec(
        attachmentOffset: Vector2(0, -40),
        facingRightOffset: Vector2(-24, 0),
        facingLeftOffset: Vector2(24, 0),
      ),
    },
    defaultAttackDuration: Duration(milliseconds: 800),
  );

  // Usar no loadout
  final entry = KnightHandLoadoutEntry(
    slot: KnightHandSlot.right,
    itemData: hammerData,
    attack: KnightHandAttackSpec(
      trigger: KnightAttackTrigger.primary,
      attackType: AttackType.melee,
      syncSpec: SynchronizedAttackSpecConfig.standard,
      execute: (context, damage) {
        // Callback executará no frame 7
        context.handController.setAttackFrameCallback(() {
          print('💥 SLAM! Heavy damage: ${damage * 1.5}');

          // Dano aumentado para ataque pesado
          context.player.simpleAttackMelee(
            damage: damage * 1.5,
            size: Vector2(48, 48), // Hitbox maior
          );

          // Shake mais intenso
          CameraFx.primaryAttackShake(context.player.gameRef);
          CameraFx.primaryAttackShake(context.player.gameRef); // Duplo shake
        });
      },
    ),
  );
}

// ============================================================================
// EXEMPLO 4: Misturar Sprite e Animação no Mesmo Loadout
// ============================================================================

void exemploMisturado() {
  // Mão direita: Espada COM ANIMAÇÃO
  final swordData = KnightAnimatedWeaponPreset.createExampleSword();

  // Mão esquerda: Escudo SEM ANIMAÇÃO (sprite estático)
  final shieldData = KnightPickaxeHandPreset.create(
    id: 'wooden_shield',
    spritePath: 'equipment/shield.png',
    spriteSize: Vector2(32, 32),
    attachmentOffset: Vector2(0, -28),
    directionalOffset: Vector2(-20, 0),
    mirroredDirectionalOffset: Vector2(20, 0),
  );

  final loadout = KnightHandLoadoutSetup(
    entries: [
      // Right hand: Animated sword
      KnightHandLoadoutEntry(
        slot: KnightHandSlot.right,
        itemData: swordData,
        attack: KnightHandAttackSpec(
          trigger: KnightAttackTrigger.primary,
          attackType: AttackType.melee,
          syncSpec: SynchronizedAttackSpecConfig.standard,
          execute: (context, damage) {
            context.handController.setAttackFrameCallback(() {
              // Executa no frame de ataque da animação
              context.player.simpleAttackMelee(damage: damage);
            });
          },
        ),
      ),

      // Left hand: Static shield (sem ataque)
      KnightHandLoadoutEntry(
        slot: KnightHandSlot.left,
        itemData: shieldData,
        // Sem attack spec = apenas visual
      ),
    ],
  );
}

// ============================================================================
// EXEMPLO 5: Debugging e Verificação
// ============================================================================

void exemploDebug() {
  final itemData = KnightAnimatedWeaponPreset.createExampleSword();

  // Verificar modo
  if (itemData.isAnimated) {
    print('🎬 Este item usa ANIMAÇÃO');
    print('Frames: ${itemData.animationData!.frameCount}');
    print('Frame de ataque: ${itemData.animationData!.attackFrameIndex}');
    print('Duração: ${itemData.animationData!.animationDuration.inMilliseconds}ms');
    print('Tempo do ataque: ${itemData.animationData!.attackFrameTime}s');
  } else {
    print('🖼️ Este item usa SPRITE estático');
    print('Path: ${itemData.spritePath}');
  }

  // Durante o jogo, verificar progresso
  final controller = handManager.handControllerFor(KnightHandSlot.right);
  if (controller?.view?.isAnimated == true) {
    final progress = controller!.view!.animationProgress;
    print('Progresso da animação: ${(progress * 100).toStringAsFixed(1)}%');
  }
}

// ============================================================================
// EXEMPLO 6: Integração com Equipment System
// ============================================================================

import 'package:darkness_dungeon/gameplay/inventory/equipment_to_knight_adapter.dart';

void exemploIntegracaoEquipment() {
  // No EquipmentToKnightAdapter, detectar se WeaponItem tem animação

  KnightHandLoadoutEntry _createWeaponEntry(WeaponItem item) {
    final weaponType = item.weaponType;

    // Verificar se este tipo de arma deve usar animação
    final shouldUseAnimation = weaponType == WeaponType.sword ||
                               weaponType == WeaponType.axe ||
                               weaponType == WeaponType.mace;

    KnightHandItemData handData;

    if (shouldUseAnimation && item.hasAnimationData) {
      // Usar animação se disponível
      handData = KnightAnimatedWeaponPreset.create(
        id: item.id,
        animationPath: item.animationPath,
        frameCount: item.animationFrameCount,
        attackFrameIndex: item.attackFrameIndex,
        animationDuration: Duration(milliseconds: item.attackDuration),
        textureSize: Vector2(64, 64),
        size: Vector2(64, 64),
        attachmentOffset: Vector2(0, -32),
        directionalOffset: Vector2(20, 0),
        mirroredDirectionalOffset: Vector2(-20, 0),
      );
    } else {
      // Fallback para sprite estático
      handData = KnightPickaxeHandPreset.create(
        id: item.id,
        spritePath: item.iconPath,
        spriteSize: Vector2(32, 32),
        attachmentOffset: Vector2(0, -28),
        directionalOffset: Vector2(20, 0),
        mirroredDirectionalOffset: Vector2(-20, 0),
      );
    }

    return KnightHandLoadoutEntry(
      slot: KnightHandSlot.right,
      itemData: handData,
      attack: KnightHandAttackSpec(
        trigger: KnightAttackTrigger.primary,
        attackType: AttackType.melee,
        syncSpec: SynchronizedAttackSpecConfig.standard,
        execute: (context, damage) {
          final finalDamage = (item.damage).toDouble();

          if (handData.isAnimated) {
            // Modo animação: usar callback
            context.handController.setAttackFrameCallback(() {
              _applyWeaponDamage(context, finalDamage);
            });
          } else {
            // Modo sprite: aplicar imediatamente
            _applyWeaponDamage(context, finalDamage);
          }
        },
      ),
    );
  }

  void _applyWeaponDamage(KnightAttackExecutionContext context, double damage) {
    CameraFx.primaryAttackShake(context.player.gameRef);
    AudioManager.instance.playPlayerPrimaryAttackSfx();
    context.player.simpleAttackMelee(
      damage: damage,
      size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
    );
  }
}
