// lib/shared/framework/character/behavior/farming_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';

class FarmingConfig {
  final double digStaminaCost;
  final double wateringCanStaminaCost;
  final double seedStaminaCost;
  final double harvestStaminaCost;
  
  final DDAnimationDirectionalFactory digAnimationFactory;
  final DDAnimationDirectionalFactory wateringCanAnimationFactory;
  final DDAnimationDirectionalFactory seedAnimationFactory;
  final DDAnimationDirectionalFactory harvestAnimationFactory;
  
  const FarmingConfig({
    required this.digStaminaCost,
    required this.wateringCanStaminaCost,
    required this.seedStaminaCost,
    required this.harvestStaminaCost,
    required this.digAnimationFactory,
    required this.wateringCanAnimationFactory,
    required this.seedAnimationFactory,
    required this.harvestAnimationFactory,
  });
}

class FarmingBehavior extends CharacterBehavior {
  final FarmingConfig config;
  
  late DDAnimationDirectional _digAnimation;
  late DDAnimationDirectional _wateringAnimation;
  late DDAnimationDirectional _seedAnimation;
  late DDAnimationDirectional _harvestAnimation;
  
  bool _isActionPlaying = false;
  
  FarmingBehavior(this.config);
  
  @override
  void onAttach() {
    super.onAttach();
    _loadAnimations();
  }
  
  Future<void> _loadAnimations() async {
    _digAnimation = await DDCharacterActionSpriteAnimationHelper
        .loadAnimationDirectionalFromFactory(config.digAnimationFactory);
    _wateringAnimation = await DDCharacterActionSpriteAnimationHelper
        .loadAnimationDirectionalFromFactory(config.wateringCanAnimationFactory);
    _seedAnimation = await DDCharacterActionSpriteAnimationHelper
        .loadAnimationDirectionalFromFactory(config.seedAnimationFactory);
    _harvestAnimation = await DDCharacterActionSpriteAnimationHelper
        .loadAnimationDirectionalFromFactory(config.harvestAnimationFactory);
  }
  
  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;
    
    final equipment = character.data.equippedItemId;
    
    // Dig
    if (InputDef.isPrimaryAction(event.id) && equipment == HandItemId.shovel.name) {
      return _executeDig();
    }
    
    // Water
    if (InputDef.isPrimaryAction(event.id) && equipment == HandItemId.wateringCan.name) {
      return _executeWatering();
    }
    
    // Plant Seed
    if (InputDef.isPrimaryAction(event.id) && equipment == HandItemId.seed.name) {
      return _executePlantSeed();
    }
    
    // Harvest
    if (InputDef.isPrimaryAction(event.id) && equipment == HandItemId.hoe.name) {
      return _executeHarvest();
    }
    
    return false;
  }
  
  // --- Dig ---
  
  bool _executeDig() {
    GameLogger.info('[FarmingBehavior] Executing dig');
    
    if (_isActionPlaying) return false;
    
    if (!character.data.tryConsumeStamina(config.digStaminaCost)) {
      OverlayMessageDef.showNoStamina();
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _digAnimation.right,
      animationLeft: _digAnimation.left,
      animationUp: _digAnimation.up,
      animationDown: _digAnimation.down,
      animationRightUp: _digAnimation.rightUp,
      animationRightDown: _digAnimation.rightDown,
      animationLeftUp: _digAnimation.leftUp,
      animationLeftDown: _digAnimation.leftDown,
      currentAnimation: character.animation,
      target: character,
      onActionStart: () {
        _isActionPlaying = true;
        character.lockAction();
      },
      onActionEnd: () {
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () => _performDigAction(),
    );
    
    return true;
  }
  
  void _performDigAction() {
    // Lógica de cavar tile será implementada aqui
    GameLogger.info('[FarmingBehavior] Dig action executed');
  }
  
  // --- Water ---
  
  bool _executeWatering() {
    GameLogger.info('[FarmingBehavior] Executing watering');
    
    if (_isActionPlaying) return false;
    
    if (!character.data.tryConsumeStamina(config.wateringCanStaminaCost)) {
      OverlayMessageDef.showNoStamina();
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _wateringAnimation.right,
      animationLeft: _wateringAnimation.left,
      animationUp: _wateringAnimation.up,
      animationDown: _wateringAnimation.down,
      animationRightUp: _wateringAnimation.rightUp,
      animationRightDown: _wateringAnimation.rightDown,
      animationLeftUp: _wateringAnimation.leftUp,
      animationLeftDown: _wateringAnimation.leftDown,
      currentAnimation: character.animation,
      target: character,
      onActionStart: () {
        _isActionPlaying = true;
        character.lockAction();
      },
      onActionEnd: () {
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () => _performWateringAction(),
    );
    
    return true;
  }
  
  void _performWateringAction() {
    GameLogger.info('[FarmingBehavior] Watering action executed');
  }
  
  // --- Plant Seed ---
  
  bool _executePlantSeed() {
    GameLogger.info('[FarmingBehavior] Executing plant seed');
    
    if (_isActionPlaying) return false;
    
    if (!character.data.tryConsumeStamina(config.seedStaminaCost)) {
      OverlayMessageDef.showNoStamina();
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _seedAnimation.right,
      animationLeft: _seedAnimation.left,
      animationUp: _seedAnimation.up,
      animationDown: _seedAnimation.down,
      animationRightUp: _seedAnimation.rightUp,
      animationRightDown: _seedAnimation.rightDown,
      animationLeftUp: _seedAnimation.leftUp,
      animationLeftDown: _seedAnimation.leftDown,
      currentAnimation: character.animation,
      target: character,
      onActionStart: () {
        _isActionPlaying = true;
        character.lockAction();
      },
      onActionEnd: () {
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () => _performPlantSeedAction(),
    );
    
    return true;
  }
  
  void _performPlantSeedAction() {
    GameLogger.info('[FarmingBehavior] Plant seed action executed');
  }
  
  // --- Harvest ---
  
  bool _executeHarvest() {
    GameLogger.info('[FarmingBehavior] Executing harvest');
    
    if (_isActionPlaying) return false;
    
    if (!character.data.tryConsumeStamina(config.harvestStaminaCost)) {
      OverlayMessageDef.showNoStamina();
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _harvestAnimation.right,
      animationLeft: _harvestAnimation.left,
      animationUp: _harvestAnimation.up,
      animationDown: _harvestAnimation.down,
      animationRightUp: _harvestAnimation.rightUp,
      animationRightDown: _harvestAnimation.rightDown,
      animationLeftUp: _harvestAnimation.leftUp,
      animationLeftDown: _harvestAnimation.leftDown,
      currentAnimation: character.animation,
      target: character,
      onActionStart: () {
        _isActionPlaying = true;
        character.lockAction();
      },
      onActionEnd: () {
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () => _performHarvestAction(),
    );
    
    return true;
  }
  
  void _performHarvestAction() {
    GameLogger.info('[FarmingBehavior] Harvest action executed');
  }
}