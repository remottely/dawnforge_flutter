// lib/shared/framework/character/behavior/farming_behavior.dart (COMPLETO COM LOGS)
import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/game/core/modules/overlay/message/message_overlay_def.dart';
import 'package:dawnforge/game/core/utils/app_environment.dart';
import 'package:dawnforge/game/features/farm/services/farm_tool_action_config.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
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
  async.Timer? _actionTimeoutTimer; // ✅ NOVO

  static const Duration _kActionTimeout = Duration(seconds: 2); // ✅ NOVO

  FarmingBehavior(this.config);

  @override
  void onAttach() {
    super.onAttach();
    GameLogger.info('[FarmingBehavior] 🔗 onAttach');
    _loadAnimations();
  }

  Future<void> _loadAnimations() async {
    _digAnimation =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.digAnimationFactory,
        );
    _wateringAnimation =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.wateringCanAnimationFactory,
        );
    _seedAnimation =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.seedAnimationFactory,
        );
    _harvestAnimation =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.harvestAnimationFactory,
        );
    GameLogger.info('[FarmingBehavior] ✅ All farming animations loaded');
  }

  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;

    final equipment = character.data.equippedItemId;
    
    GameLogger.info('[FarmingBehavior] 🎮 Input received (equipment: $equipment)');

    if (InputDef.isPrimaryAction(event.id)) {
      // Dig
      if (equipment == HandItemId.shovel) {
        return _executeDig();
      }

      // Water
      if (equipment == HandItemId.wateringCan) {
        return _executeWatering();
      }

      // Plant Seed
      final equipmentEnum = HandItemId.values
          .where((e) => e == equipment)
          .firstOrNull;
      if (equipmentEnum?.isSeed ?? false) {
        return _executePlantSeed();
      }

      // Harvest
      if (equipment == HandItemId.harvestBasket) {
        return _executeHarvest();
      }
    }

    return false;
  }

  bool _executeDig() {
    GameLogger.info('[FarmingBehavior] 🪝 Executing dig (isPlaying: $_isActionPlaying)');

    if (_isActionPlaying) {
      GameLogger.warning('[FarmingBehavior] ⚠️ Action already playing, ignoring input');
      return false;
    }

    if (!character.data.tryConsumeStamina(config.digStaminaCost)) {
      MessageOverlayDef.showNoStamina();
      return false;
    }

    GameLogger.info('[FarmingBehavior] ✅ Stamina consumed (${config.digStaminaCost})');

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
      executionStartFrame: 5,
      onActionStart: () {
        GameLogger.info('[FarmingBehavior] ✅ DIG onActionStart');
        _isActionPlaying = true;
        character.lockAction();
        
        // ✅ TIMEOUT
        _actionTimeoutTimer?.cancel();
        _actionTimeoutTimer = async.Timer(_kActionTimeout, () {
          GameLogger.warning('[FarmingBehavior] ⚠️ DIG TIMEOUT! Force ending...');
          _forceEndAction();
        });
      },
      onActionEnd: () {
        GameLogger.info('[FarmingBehavior] ✅ DIG onActionEnd');
        _actionTimeoutTimer?.cancel();
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () {
        GameLogger.info('[FarmingBehavior] ⚔️ DIG onExecutionFrames');
        _performDigAction();
      },
    );

    return true;
  }

  void _performDigAction() {
    // FarmToolActionDef.execute(player: character); // TODO(kevin): put it back?
    GameLogger.info('[FarmingBehavior] 💥 Dig action executed');
  }

  bool _executeWatering() {
    GameLogger.info('[FarmingBehavior] 💧 Executing watering (isPlaying: $_isActionPlaying)');

    if (_isActionPlaying) {
      GameLogger.warning('[FarmingBehavior] ⚠️ Action already playing, ignoring input');
      return false;
    }

    if (!character.data.tryConsumeStamina(config.wateringCanStaminaCost)) {
      MessageOverlayDef.showNoStamina();
      return false;
    }

    GameLogger.info('[FarmingBehavior] ✅ Stamina consumed (${config.wateringCanStaminaCost})');

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
      executionStartFrame: AppEnvironment.kIsDevToolsMode ? 0 : 8,
      onActionStart: () {
        GameLogger.info('[FarmingBehavior] ✅ WATERING onActionStart');
        _isActionPlaying = true;
        character.lockAction();
        
        _actionTimeoutTimer?.cancel();
        _actionTimeoutTimer = async.Timer(_kActionTimeout, () {
          GameLogger.warning('[FarmingBehavior] ⚠️ WATERING TIMEOUT! Force ending...');
          _forceEndAction();
        });
      },
      onActionEnd: () {
        GameLogger.info('[FarmingBehavior] ✅ WATERING onActionEnd');
        _actionTimeoutTimer?.cancel();
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () {
        GameLogger.info('[FarmingBehavior] ⚔️ WATERING onExecutionFrames');
        _performWateringAction();
      },
    );

    return true;
  }

  void _performWateringAction() {
    // FarmToolActionDef.execute(player: character); // TODO(kevin): put it back?
    GameLogger.info('[FarmingBehavior] 💥 Watering action executed');
  }

  bool _executePlantSeed() {
    GameLogger.info('[FarmingBehavior] 🌱 Executing plant seed (isPlaying: $_isActionPlaying)');

    if (_isActionPlaying) {
      GameLogger.warning('[FarmingBehavior] ⚠️ Action already playing, ignoring input');
      return false;
    }

    if (!character.data.tryConsumeStamina(config.seedStaminaCost)) {
      MessageOverlayDef.showNoStamina();
      return false;
    }

    GameLogger.info('[FarmingBehavior] ✅ Stamina consumed (${config.seedStaminaCost})');

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
      executionStartFrame: 4,
      onActionStart: () {
        GameLogger.info('[FarmingBehavior] ✅ SEED onActionStart');
        _isActionPlaying = true;
        character.lockAction();
        
        _actionTimeoutTimer?.cancel();
        _actionTimeoutTimer = async.Timer(_kActionTimeout, () {
          GameLogger.warning('[FarmingBehavior] ⚠️ SEED TIMEOUT! Force ending...');
          _forceEndAction();
        });
      },
      onActionEnd: () {
        GameLogger.info('[FarmingBehavior] ✅ SEED onActionEnd');
        _actionTimeoutTimer?.cancel();
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () {
        GameLogger.info('[FarmingBehavior] ⚔️ SEED onExecutionFrames');
        _performPlantSeedAction();
      },
    );

    return true;
  }

  void _performPlantSeedAction() {
    // FarmToolActionDef.execute(player: character); // TODO(kevin): put it back?
    GameLogger.info('[FarmingBehavior] 💥 Plant seed action executed');
  }

  bool _executeHarvest() {
    GameLogger.info('[FarmingBehavior] 🌾 Executing harvest (isPlaying: $_isActionPlaying)');

    if (_isActionPlaying) {
      GameLogger.warning('[FarmingBehavior] ⚠️ Action already playing, ignoring input');
      return false;
    }

    if (!character.data.tryConsumeStamina(config.harvestStaminaCost)) {
      MessageOverlayDef.showNoStamina();
      return false;
    }

    GameLogger.info('[FarmingBehavior] ✅ Stamina consumed (${config.harvestStaminaCost})');

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
      executionStartFrame: 4,
      onActionStart: () {
        GameLogger.info('[FarmingBehavior] ✅ HARVEST onActionStart');
        _isActionPlaying = true;
        character.lockAction();
        
        _actionTimeoutTimer?.cancel();
        _actionTimeoutTimer = async.Timer(_kActionTimeout, () {
          GameLogger.warning('[FarmingBehavior] ⚠️ HARVEST TIMEOUT! Force ending...');
          _forceEndAction();
        });
      },
      onActionEnd: () {
        GameLogger.info('[FarmingBehavior] ✅ HARVEST onActionEnd');
        _actionTimeoutTimer?.cancel();
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () {
        GameLogger.info('[FarmingBehavior] ⚔️ HARVEST onExecutionFrames');
        _performHarvestAction();
      },
    );

    return true;
  }

  void _performHarvestAction() {
    // FarmToolActionDef.execute(player: character); // TODO(kevin): put it back?
    GameLogger.info('[FarmingBehavior] 💥 Harvest action executed');
  }

  // ✅ NOVO: Force end
  void _forceEndAction() {
    GameLogger.warning('[FarmingBehavior] 🔥 Force ending action!');
    _isActionPlaying = false;
    character.unlockAction();
    character.endStaminaConsumingAction();
  }

  @override
  void dispose() {
    GameLogger.info('[FarmingBehavior] 🗑️ Disposing...');
    _actionTimeoutTimer?.cancel();
    super.dispose();
  }
}
