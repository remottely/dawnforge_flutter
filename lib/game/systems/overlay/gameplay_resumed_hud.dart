import 'package:bonfire/bonfire.dart';

import 'package:dawnforge/game/state/game_state_machine.dart';
import 'package:dawnforge/game/systems/overlay/message/message_overlay.dart';
import 'package:dawnforge/game/systems/overlay/tutorial_inputs/tutorial_inputs_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inventory/inventory_overlay.dart';
import 'package:dawnforge/game/systems/overlay/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:dawnforge/game/systems/overlay/debug/debug_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/mobile_inputs_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/widgets/joystick_actions_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';
import 'package:dawnforge/game/features/time/time_manager.dart';
import 'package:dawnforge/game/features/time/widgets/time_hud_panel.dart';
import 'package:dawnforge/core/utils/debug_helpers.dart';
import 'package:flutter/material.dart';

class GameplayResumedHud extends StatelessWidget {
  const GameplayResumedHud({
    required this.flexA,
    required this.isDesktop,
    required this.flexC,
    required this.flexB,
    required this.player,
    required this.playerInput,
    required this.gameState,
  });

  final int flexA;
  final bool isDesktop;
  final int flexC;
  final int flexB;
  final DDBasePlayerView<
    DDBasePlayerController<DDBasePlayerModel>,
    DDBasePlayerModel
  >
  player;
  final PlayerController playerInput;
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Row(
        children: [
          _LeftArea(flex: flexA, isDesktop: isDesktop, gameState: gameState),
          _MainArea(
            flex: flexC,
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerInput: playerInput,
            gameState: gameState,
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// LEFT AREA
// ====================================================================

final class _LeftArea extends StatelessWidget {
  final int flex;
  final bool isDesktop;
  final GameState gameState;

  const _LeftArea({
    required this.flex,
    required this.isDesktop,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Esconde inventário em certos estados
    final showInventory =
        gameState == GameState.gameplayResumed ||
        gameState == GameState.gameplayPaused;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayLeftArea,
        child: Container(
          alignment: Alignment.centerLeft,
          child: !isDesktop && showInventory
              ? const InventoryOverlay()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ====================================================================
// MAIN AREA
// ====================================================================

final class _MainArea extends StatelessWidget {
  final int flex;
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController playerInput;
  final GameState gameState;

  const _MainArea({
    required this.flex,
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    required this.playerInput,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          _TopRow(
            flexA: flexA,
            flexB: flexB,
            player: player,
            gameState: gameState,
          ),
          _MiddleRow(
            flexA: flexA,
            flexB: flexB,
            playerInput: playerInput,
            gameState: gameState,
          ),
          _BottomRow(
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerInput: playerInput,
            gameState: gameState,
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// TOP ROW
// ====================================================================

final class _TopRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final DDBasePlayerView player;
  final GameState gameState;

  const _TopRow({
    required this.flexA,
    required this.flexB,
    required this.player,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA,
      child: Row(
        children: [
          _TopCenterArea(flex: flexB, player: player, gameState: gameState),
          _TopRightArea(flex: flexA, gameState: gameState),
        ],
      ),
    );
  }
}

final class _TopCenterArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;
  final GameState gameState;

  const _TopCenterArea({
    required this.flex,
    required this.player,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Esconde em alguns estados
    final showDebug = gameState == GameState.gameplayResumed;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopCenterArea,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            if (showDebug) DebugOverlay(player: player),
            const SizedBox(width: 8),
            const MessageOverlay(), // Sempre visível
          ],
        ),
      ),
    );
  }
}

final class _TopRightArea extends StatelessWidget {
  final int flex;
  final GameState gameState;

  const _TopRightArea({required this.flex, required this.gameState});

  @override
  Widget build(BuildContext context) {
    // ✅ Esconde HUD de tempo em certos estados
    final showTimeHUD = GameStateMachine.instance.shouldShowHUD;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopRightArea,
        child: Container(
          alignment: Alignment.topRight,
          child: Stack(
            children: [
              if (showTimeHUD) TimeHudPanel(timeManager: TimeManager.instance),
              const Align(
                alignment: Alignment.topRight,
                child: FullscreenButtonOverlay(), // Sempre visível
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// MIDDLE ROW
// ====================================================================

final class _MiddleRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final PlayerController playerInput;
  final GameState gameState;

  const _MiddleRow({
    required this.flexA,
    required this.flexB,
    required this.playerInput,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexB,
      child: Row(
        children: [
          _CenterArea(flex: flexB, gameState: gameState),
          _CenterRightArea(
            flex: flexA,
            playerInput: playerInput,
            gameState: gameState,
          ),
        ],
      ),
    );
  }
}

final class _CenterArea extends StatelessWidget {
  final int flex;
  final GameState gameState;

  const _CenterArea({required this.flex, required this.gameState});

  @override
  Widget build(BuildContext context) {
    // ✅ Tutorial só em playing
    final showTutorial = gameState == GameState.gameplayResumed;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterArea,
        child: Container(
          alignment: Alignment.center,
          child: showTutorial
              ? const TutorialInputsOverlay()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

final class _CenterRightArea extends StatelessWidget {
  final int flex;
  final PlayerController playerInput;
  final GameState gameState;

  const _CenterRightArea({
    required this.flex,
    required this.playerInput,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Esconde joystick mobile em certos estados
    final showJoystick = gameState == GameState.gameplayResumed;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterRightArea,
        child:
            SettingsManager.instance.inputSelected ==
                    InputActionsType.joystick &&
                showJoystick
            ? MobileInputsOverlay(playerInput: playerInput)
            : const SizedBox(width: double.infinity, height: double.infinity),
      ),
    );
  }
}

// ====================================================================
// BOTTOM ROW
// ====================================================================

final class _BottomRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController playerInput;
  final GameState gameState;

  const _BottomRow({
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    required this.playerInput,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA + 1,
      child: Row(
        children: [
          if (isDesktop) _BottomCenterArea(flex: flexB, gameState: gameState),
          _BottomRightArea(
            flex: flexA,
            player: player,
            playerInput: playerInput,
            gameState: gameState,
          ),
        ],
      ),
    );
  }
}

final class _BottomCenterArea extends StatelessWidget {
  final int flex;
  final GameState gameState;

  const _BottomCenterArea({required this.flex, required this.gameState});

  @override
  Widget build(BuildContext context) {
    // ✅ Mostra inventário apenas em certos estados
    final showInventory =
        gameState == GameState.gameplayResumed ||
        gameState == GameState.gameplayPaused;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomCenterArea,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: showInventory
              ? const InventoryOverlay()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

final class _BottomRightArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;
  final PlayerController playerInput;
  final GameState gameState;

  const _BottomRightArea({
    required this.flex,
    required this.player,
    required this.playerInput,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Sempre mostra stats (mas pode esconder em cutscenes)
    final showStats = GameStateMachine.instance.shouldShowHUD;

    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomRightArea,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _JoystickArea(playerInput: playerInput, gameState: gameState),
              if (showStats) PlayerVitalStatsOverlay(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

final class _JoystickArea extends StatelessWidget {
  final PlayerController playerInput;
  final GameState gameState;

  const _JoystickArea({required this.playerInput, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final showJoystick = gameState == GameState.gameplayResumed;

    return Expanded(
      child:
          SettingsManager.instance.inputSelected == InputActionsType.joystick &&
              showJoystick
          ? JoystickActionsOverlay(playerInput: playerInput)
          : const SizedBox(width: double.infinity, height: double.infinity),
    );
  }
}

final class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
