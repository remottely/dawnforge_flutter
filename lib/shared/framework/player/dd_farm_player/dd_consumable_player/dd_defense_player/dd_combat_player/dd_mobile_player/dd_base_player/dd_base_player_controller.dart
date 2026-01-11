import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

abstract class DDBasePlayerController<M extends DDBasePlayerModel> {
  final M model;

  final void Function() onDisplayExclamationEmote;

  final void Function({
    required double longVisionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  })
  onDetectEnemyInLongVisionRadius;

  DDBasePlayerController({
    required this.model,
    required this.onDisplayExclamationEmote,
    required this.onDetectEnemyInLongVisionRadius,
  });

  bool _isStaminaRegenerationPending = false;

  bool _isStaminaRegenerationPaused = false;

  int _activeStaminaConsumingActions = 0;

  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    GameLogger.info('[BaseController] handleInputAction chamado: ${event.id}');
  }

  void update(double dt) {
    // processStaminaRegeneration();
    processEnemyDetection();
  }

  void dispose() {
    _isStaminaRegenerationPending = false;
  }

  void processStaminaRegeneration() {
    if (_isStaminaRegenerationPending || _isStaminaRegenerationPaused) return;

    _isStaminaRegenerationPending = true;

    Future.delayed(model.config.staminaRegenDebounce, () {
      _isStaminaRegenerationPending = false;
      if (!_isStaminaRegenerationPaused) {
        model.regenerateStamina();
      }
    });
  }

  void pauseStaminaRegeneration() {
    _isStaminaRegenerationPaused = true;
  }

  void resumeStaminaRegeneration() {
    _isStaminaRegenerationPaused = false;
  }

  void beginStaminaConsumingAction() {
    _activeStaminaConsumingActions++;
    if (_activeStaminaConsumingActions == 1) {
      pauseStaminaRegeneration();
    }
  }

  void endStaminaConsumingAction() {
    _activeStaminaConsumingActions--;
    if (_activeStaminaConsumingActions <= 0) {
      _activeStaminaConsumingActions = 0;
      resumeStaminaRegeneration();
    }
  }

  void processEnemyDetection() {
    onDetectEnemyInLongVisionRadius(
      longVisionRadius: model.config.longVisionRadius,
      notObserved: () => model.stopObservingEnemy(),
      observed: (List<Enemy> detectedEnemies) {
        if (model.isObservingEnemy) return;

        model.startObservingEnemy();
        onDisplayExclamationEmote();
      },
    );
  }

  void restoreEnergy() => model.restoreEnergy();
}
