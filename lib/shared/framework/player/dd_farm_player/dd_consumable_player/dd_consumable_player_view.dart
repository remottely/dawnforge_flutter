import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_consumable_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_defense_player_view.dart';
import 'package:flutter/foundation.dart';

abstract class DDConsumablePlayerView<
  C extends DDConsumablePlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDDefensePlayerView<C, M> {
  @protected
  final DDCombatPlayerViewConfig config;

  // ✅ FLAG para garantir inicialização única
  bool _consumableListenerInitialized = false;

  DDConsumablePlayerView({
    required this.config,
    required super.position,
    required super.model,
  }) : super(config: config);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ TENTA INICIALIZAR (se falhar, será tentado no update)
    _tryInitializeConsumableListener();
  }

  @override
  void update(double dt) {
    if (isDead) return;

    controller.update(dt);

    // ✅ INICIALIZA LISTENER (apenas uma vez)
    // _tryInitializeConsumableListener(); TODO(Kevin): put it back? no

    super.update(dt);
  }

  /// ✅ Tenta inicializar listener (só executa uma vez)
  void _tryInitializeConsumableListener() {
    if (_consumableListenerInitialized) return;

    try {
      controller.initializeConsumableListener(
        this,
      ); // error: The method 'initializeConsumableListener' isn't defined for the type '<unknown>'.
      // Try correcting the name to the name of an existing method, or defining a method named 'initializeConsumableListener'.
      _consumableListenerInitialized = true;

      if (kDebugMode) {
        GameLogger.debug(
          '[DDConsumablePlayerView] ✅ Consumable listener initialized',
        );
      }
    } catch (e) {
      // Silenciosamente falha se EquipmentManager ainda não estiver pronto
      // Será tentado novamente no próximo update
      if (kDebugMode) {
        GameLogger.debug(
          '[DDConsumablePlayerView] ⏳ Waiting for initialization: $e',
        );
      }
    }
  }

  @override
  C createCombatController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
  }) {
    return createConsumableController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
    );
  }

  C createConsumableController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
  });
}
