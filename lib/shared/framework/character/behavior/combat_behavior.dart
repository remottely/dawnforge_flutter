// lib/shared/framework/character/behavior/combat_behavior.dart
import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/gameplay/core/modules/camera/camera_fx.dart';
import 'package:dawnforge/gameplay/core/modules/combat/attacks/character_fireball_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/attacks/player_primary_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_def.dart';
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
  
  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;
  
  static const Duration _kComboResetDelay = Duration(milliseconds: 450);
  
  CombatBehavior(this.config);
  
  @override
  void onAttach() {
    super.onAttach();
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
  }
  
  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;
    
    // Primary Attack (Melee)
    if (InputDef.isPrimaryAction(event.id)) {
      final equipment = character.data.equippedItemId;
      
      if (equipment == HandItemId.ironSword.name) {
        return _executePrimaryAttack();
      }
      
      if (equipment == HandItemId.staff.name) {
        return _executeRangedAttack();
      }
    }
    
    return false;
  }
  
  // --- Primary Attack (Melee) ---
  
  bool _executePrimaryAttack() {
    GameLogger.info(
      '[CombatBehavior] Primary attack: stamina=${character.data.stamina}, '
      'canExecute=${_canExecutePrimaryAttack()}',
    );
    
    if (_isAttackPlaying) {
      _comboQueued = true;
      return false; // Não cobra stamina em cliques extras
    }
    
    if (!_canExecutePrimaryAttack()) {
      GameLogger.warning('[CombatBehavior] ✗ Cannot execute primary attack');
      
      if (character.data.stamina < config.primaryAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return false;
    }
    
    return _startComboAttack(consumeStamina: true);
  }
  
  bool _canExecutePrimaryAttack() {
    return !_isAttackPlaying &&
           character.data.stamina >= config.primaryAttackStaminaCost &&
           character.data.equippedItemId == HandItemId.ironSword.name;
  }
  
  bool _startComboAttack({bool consumeStamina = false}) {
    if (consumeStamina) {
      if (!character.data.tryConsumeStamina(config.primaryAttackStaminaCost)) {
        _comboQueued = false;
        _comboStep = 0;
        return false;
      }
    }
    
    final DDAnimationDirectional comboAnimation = _comboAttackAnimations[_comboStep];
    final currentComboStep = _comboStep;
    
    final executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
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
            _isAttackPlaying = true;
            _comboResetTimer?.cancel();
            character.lockAction(); // error: The method 'lockAction' isn't defined for the type 'Character'.
// Try correcting the name to the name of an existing method, or defining a method named 'lockAction'.
            character.beginStaminaConsumingAction();
          },
          onActionEnd: () => _handleAttackEnd(consumeStamina),
          onExecutionFrames: () => _executePrimaryAttackHitbox(
            comboStep: currentComboStep,
          ),
        );
      },
    );
    
    if (executionInfo == null) {
      _isAttackPlaying = false;
      _comboQueued = false;
      return false;
    }
    
    _comboStep = (_comboStep + 1) % _comboAttackAnimations.length;
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
  }
  
  void _handleAttackEnd(bool consumeStamina) {
    character.unlockAction(); // error: The method 'unlockAction' isn't defined for the type 'Character'.
// Try correcting the name to the name of an existing method, or defining a method named 'unlockAction'.
    character.endStaminaConsumingAction();
    _isAttackPlaying = false;
    
    if (_comboQueued) {
      _comboQueued = false;
      
      if (!meleeAttackController.canPerformAttack) {
        meleeAttackController.forceReadyForCombo();
      }
      
      _startComboAttack(consumeStamina: true);
      return;
    }
    
    _comboResetTimer?.cancel();
    _comboResetTimer = async.Timer(_kComboResetDelay, () {
      _comboStep = 0;
    });
  }
  
  // --- Ranged Attack (Fireball) ---
  
  bool _executeRangedAttack() {
    GameLogger.info(
      '[CombatBehavior] Ranged attack: stamina=${character.data.stamina}, '
      'canExecute=${_canExecuteRangedAttack()}',
    );
    
    if (!_canExecuteRangedAttack()) {
      GameLogger.warning('[CombatBehavior] ✗ Cannot execute ranged attack');
      
      if (character.data.stamina < config.rangedAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
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
    
    return executionInfo != null;
  }
  
  bool _canExecuteRangedAttack() {
    return character.data.stamina >= config.rangedAttackStaminaCost &&
           character.data.equippedItemId == HandItemId.staff.name;
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
  }
  
  @override
  void dispose() {
    _comboResetTimer?.cancel();
    meleeAttackController.dispose();
    rangedAttackController.dispose();
    super.dispose();
  }
}
