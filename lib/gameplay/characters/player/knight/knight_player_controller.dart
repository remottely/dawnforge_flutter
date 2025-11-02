import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_player_input_actions_config.dart';

/// Controller: Lógica de negócio e orquestração
/// Não conhece detalhes de implementação da View
class KnightPlayerController {
  final KnightPlayerModel model;
  final void Function(double damage) onPrimaryAttack;
  final void Function(double damage) onFireballAttack;
  final void Function() onToolUse;
  final void Function() onShowExclamation;
  final void Function({
    required double radiusVision,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  })
  onCheckEnemyVision;

  bool _hasStaminaRegenScheduled = false;
  bool _isToolInUse = false;

  KnightPlayerController({
    required this.model,
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
    if (event.event != ActionEvent.DOWN) return;

    if (event.id == GameplayJoystickConfig.kJoystickPrimaryAttackId ||
        event.id == GameplayKeyboardConfig.kPrimaryAttackKey) {
      executePrimaryAttack();
    } else if (event.id == GameplayJoystickConfig.kJoystickFireballAttackId ||
        event.id == GameplayKeyboardConfig.kFireballAttackKey) {
      executeFireballAttack();
    }
  }

  // Actions
  void executePrimaryAttack() {
    if (!model.canPrimaryAttack) return;
    model.consumeStamina(KnightPlayerConfig.kPrimaryAttackStaminaCost);
    onPrimaryAttack(model.attackDamage);
  }

  void executeFireballAttack() {
    if (!model.canFireballAttack) return;
    model.consumeStamina(KnightPlayerConfig.kFireballAttackStaminaCost);
    onFireballAttack(KnightPlayerConfig.kSmallAttackDamage);
  }

  void useTool() {
    if (_isToolInUse || !model.canUseTool) return;
    _isToolInUse = true;
    model.consumeEnergy(KnightPlayerConfig.kToolUsageEnergyCost);
    onToolUse();
    Future.delayed(Duration(milliseconds: 500), () => _isToolInUse = false);
  }

  void switchTool(FarmTool newTool) => model.switchTool(newTool);
  void restoreEnergy() => model.restoreEnergy();

  // Private helpers
  void _handleStaminaRegeneration() {
    if (_hasStaminaRegenScheduled) return;
    _hasStaminaRegenScheduled = true;
    Future.delayed(KnightPlayerConfig.kStaminaRegenDebounce, () {
      _hasStaminaRegenScheduled = false;
      model.regenerateStamina();
    });
  }

  void _handleEnemyVision() {
    onCheckEnemyVision(
      radiusVision: KnightPlayerConfig.kVisionRadius,
      notObserved: () => model.isObservingEnemy = false,
      observed: (enemies) {
        if (model.isObservingEnemy) return;
        model.isObservingEnemy = true;
        onShowExclamation();
      },
    );
  }
}
