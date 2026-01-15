// lib/shared/framework/character/behavior/combat_behavior.dart (COM LOGS DE MOVIMENTO)
import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/gameplay/core/modules/camera/camera_fx.dart';
import 'package:dawnforge/gameplay/core/modules/combat/attacks/character_fireball_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/attacks/player_primary_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/overlay/message/message_overlay_def.dart';
import 'package:dawnforge/gameplay/core/utils/offset_helper.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';

class CombatConfig {
  final double primaryAttackDamage;
  final double primaryAttackStaminaCost;
  final double rangedAttackDamage;
  final double rangedAttackStaminaCost;
  
  final DDAnimationDirectionalFactory attackAnimationFactory;
  final List<DDAnimationDirectionalFactory> comboAttackAnimationFactories;
  
  const CombatConfig({
    required this.primaryAttackDamage,
    required this.primaryAttackStaminaCost,
    required this.rangedAttackDamage,
    required this.rangedAttackStaminaCost,
    required this.attackAnimationFactory,
    this.comboAttackAnimationFactories = const [],
  });
}

class CombatBehavior extends CharacterBehavior {
  final CombatConfig config;
  
  late final List<DDAnimationDirectional> _comboAttackAnimations;
  int _comboStep = 0;
  bool _isAttackPlaying = false;
  bool _comboQueued = false;
  async.Timer? _comboResetTimer;
  async.Timer? _attackTimeoutTimer;
  
  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;
  
  static const Duration _kComboResetDelay = Duration(milliseconds: 450);
  static const Duration _kAttackTimeout = Duration(seconds: 2);
  
  CombatBehavior(this.config);
  
  @override
  void onAttach() {
    super.onAttach();
    GameLogger.info('[CombatBehavior] 🔗 onAttach');
    _initializeCombatSystems();
    _loadAnimations();
  }
  
  void _initializeCombatSystems() {
    meleeAttackController = SynchronizedAttackController(
      config: SynchronizedAttackDef.standard,
    );
    rangedAttackController = SynchronizedAttackController(
      config: SynchronizedAttackDef.standard,
    );
    GameLogger.info('[CombatBehavior] ✅ Combat systems initialized');
  }
  
  Future<void> _loadAnimations() async {
    final factories = config.comboAttackAnimationFactories.isNotEmpty
        ? config.comboAttackAnimationFactories
        : [config.attackAnimationFactory];
    
    final animations = await Future.wait(
      factories.map(
        DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory,
      ),
    );
    
    _comboAttackAnimations = animations;
    GameLogger.info('[CombatBehavior] ✅ Loaded ${_comboAttackAnimations.length} combo animations');
  }
  
  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;
    
    // Primary Attack (Melee)
    if (InputDef.isPrimaryAction(event.id)) {
      final equipment = character.data.equippedItemId;
      
      GameLogger.info('[CombatBehavior] 🎮 Input received (equipment: $equipment, isActionLocked: ${character.isActionLocked})');
      
      if (equipment == HandItemId.ironSword) {
        return _executePrimaryAttack();
      }
      
      if (equipment == HandItemId.staff) {
        return _executeRangedAttack();
      }
    }
    
    return false;
  }
  
  // --- Primary Attack (Melee) ---
  
  bool _executePrimaryAttack() {
    GameLogger.info(
      '[CombatBehavior] 🗡️ Primary attack request: '
      'stamina=${character.data.stamina}, '
      'isPlaying=$_isAttackPlaying, '
      'isActionLocked=${character.isActionLocked}, '
      'speed=${character.speed}, '
      'velocity=${character.velocity}, '
      'canExecute=${_canExecutePrimaryAttack()}',
    );
    
    if (_isAttackPlaying) {
      _comboQueued = true;
      GameLogger.info('[CombatBehavior] 🔄 Attack queued for combo');
      return false;
    }
    
    if (!_canExecutePrimaryAttack()) {
      GameLogger.warning('[CombatBehavior] ✗ Cannot execute primary attack');
      
      if (character.data.stamina < config.primaryAttackStaminaCost) {
        MessageOverlayDef.showNoStamina();
      }
      return false;
    }
    
    return _startComboAttack(consumeStamina: true);
  }
  
  bool _canExecutePrimaryAttack() {
    return !_isAttackPlaying &&
           character.data.stamina >= config.primaryAttackStaminaCost &&
           character.data.equippedItemId == HandItemId.ironSword;
  }
  
  bool _startComboAttack({bool consumeStamina = false}) {
    GameLogger.info(
      '[CombatBehavior] 🗡️ _startComboAttack START '
      '(step: $_comboStep, consuming: $consumeStamina, speed: ${character.speed}, velocity: ${character.velocity})',
    );
    
    if (consumeStamina) {
      if (!character.data.tryConsumeStamina(config.primaryAttackStaminaCost)) {
        _comboQueued = false;
        _comboStep = 0;
        GameLogger.warning('[CombatBehavior] ❌ Failed to consume stamina');
        return false;
      }
      GameLogger.info('[CombatBehavior] ✅ Stamina consumed (${config.primaryAttackStaminaCost})');
    }
    
    final DDAnimationDirectional comboAnimation = _comboAttackAnimations[_comboStep];
    final currentComboStep = _comboStep;
    
    GameLogger.info('[CombatBehavior] 🎬 Starting attack animation (step: $currentComboStep)');
    
    final executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        GameLogger.info('[CombatBehavior] 📹 Animation execution callback START');
        
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: comboAnimation.right,
          animationLeft: comboAnimation.left,
          animationUp: comboAnimation.up,
          animationDown: comboAnimation.down,
          animationRightUp: comboAnimation.rightUp,
          animationRightDown: comboAnimation.rightDown,
          animationLeftUp: comboAnimation.leftUp,
          animationLeftDown: comboAnimation.leftDown,
          currentAnimation: character.animation,
          target: character,
          executionStartFrame: 1,
          onActionStart: () {
            GameLogger.info(
              '[CombatBehavior] ✅ onActionStart CALLED '
              '(speed BEFORE: ${character.speed}, velocity BEFORE: ${character.velocity})',
            );
            _isAttackPlaying = true;
            _comboResetTimer?.cancel();
            
            character.lockAction();
            character.beginStaminaConsumingAction();
            
            // ✅ PARAR MOVIMENTO
            character.stopMove();
            
            GameLogger.info(
              '[CombatBehavior] 🔒 Action locked + stamina consuming started + MOVEMENT STOPPED '
              '(speed AFTER: ${character.speed}, velocity AFTER: ${character.velocity})',
            );
            
            _attackTimeoutTimer?.cancel();
            _attackTimeoutTimer = async.Timer(_kAttackTimeout, () {
              GameLogger.warning(
                '[CombatBehavior] ⚠️ ATTACK TIMEOUT! Force ending... '
                '(step: $currentComboStep)',
              );
              _forceEndAttack();
            });
          },
          onActionEnd: () {
            GameLogger.info(
              '[CombatBehavior] ✅ onActionEnd CALLED '
              '(step: $currentComboStep, speed: ${character.speed}, velocity: ${character.velocity})',
            );
            _attackTimeoutTimer?.cancel();
            _handleAttackEnd(consumeStamina);
          },
          onExecutionFrames: () {
            GameLogger.info(
              '[CombatBehavior] ⚔️ onExecutionFrames CALLED (hitbox) '
              '(speed: ${character.speed}, velocity: ${character.velocity})',
            );
            _executePrimaryAttackHitbox(comboStep: currentComboStep);
          },
        );
        
        GameLogger.info('[CombatBehavior] 📹 Animation execution callback END');
      },
    );
    
    if (executionInfo == null) {
      GameLogger.warning('[CombatBehavior] ❌ executionInfo is NULL! Attack cancelled.');
      _isAttackPlaying = false;
      _comboQueued = false;
      return false;
    }
    
    _comboStep = (_comboStep + 1) % _comboAttackAnimations.length;
    GameLogger.info('[CombatBehavior] ✅ Attack started successfully (next step: $_comboStep)');
    return true;
  }
  
  void _executePrimaryAttackHitbox({required int comboStep}) {
    final attackOffset = OffsetHelper.getCenterOffset(
      comboStep == 2 ? Vector2(4, 0) : Vector2(-4, 0),
      character.lastDirection,
    );
    
    CameraFx.executePrimaryAttackShake(character.gameRef);
    AudioManager.instance.playPlayerPrimaryAttackSfx(comboStep);
    
    final attackSize = comboStep == 2
        ? PlayerPrimaryAttackDef.componentSizeLarge
        : PlayerPrimaryAttackDef.componentSizeStandard;
    
    character.simpleAttackMeleeByDirection(
      direction: character.lastDirection,
      damage: config.primaryAttackDamage,
      size: attackSize,
      centerOffset: attackOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
    
    GameLogger.info('[CombatBehavior] 💥 Hitbox executed (step: $comboStep, damage: ${config.primaryAttackDamage})');
  }
  
  void _forceEndAttack() {
    GameLogger.warning('[CombatBehavior] 🔥 Force ending attack!');
    character.unlockAction();
    character.endStaminaConsumingAction();
    _isAttackPlaying = false;
    _comboQueued = false;
    _comboStep = 0;
  }
  
  void _handleAttackEnd(bool consumeStamina) {
    GameLogger.info(
      '[CombatBehavior] 🏁 _handleAttackEnd '
      '(consumeStamina: $consumeStamina, queued: $_comboQueued, speed: ${character.speed}, velocity: ${character.velocity})',
    );
    
    character.unlockAction();
    character.endStaminaConsumingAction();
    _isAttackPlaying = false;
    
    GameLogger.info('[CombatBehavior] 🔓 Action unlocked + stamina consuming ended');
    
    if (_comboQueued) {
      _comboQueued = false;
      
      GameLogger.info('[CombatBehavior] 🔄 Executing queued combo attack');
      
      if (!meleeAttackController.canPerformAttack) {
        meleeAttackController.forceReadyForCombo();
      }
      
      _startComboAttack(consumeStamina: true);
      return;
    }
    
    _comboResetTimer?.cancel();
    _comboResetTimer = async.Timer(_kComboResetDelay, () {
      GameLogger.info('[CombatBehavior] 🔄 Combo reset (back to step 0)');
      _comboStep = 0;
    });
  }
  
  // --- Ranged Attack (Fireball) ---
  
  bool _executeRangedAttack() {
    GameLogger.info(
      '[CombatBehavior] 🔥 Ranged attack: '
      'stamina=${character.data.stamina}, '
      'canExecute=${_canExecuteRangedAttack()}',
    );
    
    if (!_canExecuteRangedAttack()) {
      GameLogger.warning('[CombatBehavior] ✗ Cannot execute ranged attack');
      
      if (character.data.stamina < config.rangedAttackStaminaCost) {
        MessageOverlayDef.showNoStamina();
      }
      return false;
    }
    
    if (!character.data.tryConsumeStamina(config.rangedAttackStaminaCost)) {
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    final executionInfo = rangedAttackController.execute(
      AttackType.ranged,
      () => _executeFireballAttack(),
    );
    
    character.endStaminaConsumingAction();
    
    final success = executionInfo != null;
    GameLogger.info('[CombatBehavior] 🔥 Ranged attack ${success ? "SUCCESS" : "FAILED"}');
    
    return success;
  }
  
  bool _canExecuteRangedAttack() {
    return character.data.stamina >= config.rangedAttackStaminaCost &&
           character.data.equippedItemId == HandItemId.staff;
  }
  
  void _executeFireballAttack() {
    final projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      character.lastDirection,
    );
    
    CharacterFireballAttackDef.playAudioExecution();
    
    character.simpleAttackRangeByDirection(
      size: CharacterFireballAttackDef.componentSize,
      speed: CharacterFireballAttackDef.kSpeed,
      lightingConfig: CharacterFireballAttackDef.lighting,
      damage: config.rangedAttackDamage,
      collision: CharacterFireballAttackDef.createHitbox(),
      animationRight: CharacterFireballAttackDef.loadAnimationExecution(),
      animationDestroy: CharacterFireballAttackDef.loadAnimationDestroy(),
      onDestroy: () => CharacterFireballAttackDef.onDestroy(character.gameRef),
      direction: character.lastDirection,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
    
    GameLogger.info('[CombatBehavior] 🔥 Fireball spawned');
  }
  
  @override
  void dispose() {
    GameLogger.info('[CombatBehavior] 🗑️ Disposing...');
    _comboResetTimer?.cancel();
    _attackTimeoutTimer?.cancel();
    meleeAttackController.dispose();
    rangedAttackController.dispose();
    super.dispose();
  }
}
