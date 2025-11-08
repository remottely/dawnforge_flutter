import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';

class SunnyPlayerController {
  final SunnyPlayerModel model;
  final void Function(bool isRunning) onRunChange;
  final bool Function(double damage) onPrimaryAttack;
  final bool Function(double damage) onFireballAttack;
  final void Function() onToolUse;
  final void Function() onShowExclamation;
  final void Function({
    required double visionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  })
  onCheckEnemyVision;

  bool _hasStaminaRegenScheduled = false;
  bool _isToolInUse = false;

  SunnyPlayerController({
    required this.model,
    required this.onRunChange,
    required this.onPrimaryAttack,
    required this.onFireballAttack,
    required this.onToolUse,
    required this.onShowExclamation,
    required this.onCheckEnemyVision,
  });

  // Lifecycle
  void update(double dt) {
    _handleStaminaRegeneration();
    _handleEnemyVision();
  }

  void dispose() {
    _hasStaminaRegenScheduled = false;
  }

  // Input handling
  void handleInputAction(JoystickActionEvent event) {
    if (event.id == JoystickSetup.kRunId || event.id == KeyboardSetup.kRunKey) {
      if (event.event == ActionEvent.DOWN) {
        onRunChange(true);
      } else if (event.event == ActionEvent.UP) {
        onRunChange(false);
      }
      return;
    }

    if (event.event != ActionEvent.DOWN) return;

    if (event.id == JoystickSetup.kPrimaryAttackId ||
        event.id == KeyboardSetup.kPrimaryAttackKey) {
      executePrimaryAttack();
    } else if (event.id == JoystickSetup.kFireballAttackId ||
        event.id == KeyboardSetup.kFireballAttackKey) {
      executeFireballAttack();
    }
  }

  // Actions
  void executePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;
    final executed = onPrimaryAttack.call(
      SunnyPlayerConfig.kPrimaryAttackDamage,
    );
    if (!executed) return;
    model.consumeStamina(SunnyPlayerConfig.kPrimaryAttackStaminaCost);
  }

  void executeFireballAttack() {
    if (!model.canExecuteFireballAttack) return;
    final executed = onFireballAttack.call(
      SunnyPlayerConfig.kFireballAttackDamage,
    );
    if (!executed) return;
    model.consumeStamina(SunnyPlayerConfig.kFireballAttackStaminaCost);
  }

  void useTool() {
    if (_isToolInUse || !model.canExecuteToolAction) return;
    _isToolInUse = true;
    model.consumeEnergy(SunnyPlayerConfig.kToolActionEnergyCost);
    onToolUse();
    Future.delayed(Duration(milliseconds: 500), () => _isToolInUse = false);
  }

  void switchTool(FarmTool newTool) => model.switchTool(newTool);
  void restoreEnergy() => model.restoreEnergy();

  // Private helpers
  void _handleStaminaRegeneration() {
    if (_hasStaminaRegenScheduled) return;
    _hasStaminaRegenScheduled = true;
    Future.delayed(SunnyPlayerConfig.kStaminaRegenDebounce, () {
      _hasStaminaRegenScheduled = false;
      model.regenerateStamina();
    });
  }

  void _handleEnemyVision() {
    onCheckEnemyVision(
      visionRadius: SunnyPlayerConfig.kVisionRadius,
      notObserved: () => model.isObservingEnemy = false,
      observed: (enemies) {
        if (model.isObservingEnemy) return;
        model.isObservingEnemy = true;
        onShowExclamation();
      },
    );
  }
}
