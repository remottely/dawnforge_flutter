import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';
import 'package:dawnforge/core/utils/debug_helpers.dart';
import 'package:dawnforge/game/features/time/time_manager.dart';
import 'package:dawnforge/game/features/time/widgets/time_hud_panel.dart';
import 'package:dawnforge/game/systems/overlay/debug/debug_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/mobile_inputs_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inputs/widgets/joystick_actions_overlay.dart';
import 'package:dawnforge/game/systems/overlay/inventory/inventory_overlay.dart';
import 'package:dawnforge/game/systems/overlay/message/message_overlay.dart';
import 'package:dawnforge/game/systems/overlay/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

class GameplayResumedHud extends StatelessWidget {
  const GameplayResumedHud({
    required this.flexA,
    required this.isDesktop,
    required this.flexC,
    required this.flexB,
    required this.player,
    required this.playerInput,
  });

  final int flexA;
  final bool isDesktop;
  final int flexC;
  final int flexB;
  final DDBasePlayerView player;
  final PlayerController playerInput;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Row(
        children: [
          _LeftArea(flex: flexA, isDesktop: isDesktop),
          _MainArea(
            flex: flexC,
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerInput: playerInput,
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

  const _LeftArea({required this.flex, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayLeftArea,
        child: Container(
          alignment: Alignment.centerLeft,
          child: !isDesktop
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

  const _MainArea({
    required this.flex,
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    required this.playerInput,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          _TopRow(flexA: flexA, flexB: flexB, player: player),
          _MiddleRow(flexA: flexA, flexB: flexB, playerInput: playerInput),
          _BottomRow(
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerInput: playerInput,
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

  const _TopRow({
    required this.flexA,
    required this.flexB,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA,
      child: Row(
        children: [
          _TopCenterArea(flex: flexB, player: player),
          _TopRightArea(flex: flexA),
        ],
      ),
    );
  }
}

final class _TopCenterArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;

  const _TopCenterArea({required this.flex, required this.player});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopCenterArea,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            DebugOverlay(player: player),
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

  const _TopRightArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopRightArea,
        child: Container(
          alignment: Alignment.topRight,
          child: Stack(
            children: [
              TimeHudPanel(timeManager: TimeManager.instance),
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

  const _MiddleRow({
    required this.flexA,
    required this.flexB,
    required this.playerInput,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexB,
      child: Row(
        children: [
          _CenterArea(flex: flexB),
          _CenterRightArea(flex: flexA, playerInput: playerInput),
        ],
      ),
    );
  }
}

final class _CenterArea extends StatelessWidget {
  final int flex;

  const _CenterArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterArea,
        child: Container(alignment: Alignment.center),
      ),
    );
  }
}

final class _CenterRightArea extends StatelessWidget {
  final int flex;
  final PlayerController playerInput;

  const _CenterRightArea({required this.flex, required this.playerInput});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterRightArea,
        child:
            SettingsManager.instance.inputSelected == InputActionsType.joystick
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

  const _BottomRow({
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    required this.playerInput,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA + 1,
      child: Row(
        children: [
          if (isDesktop) _BottomCenterArea(flex: flexB),
          _BottomRightArea(
            flex: flexA,
            player: player,
            playerInput: playerInput,
          ),
        ],
      ),
    );
  }
}

final class _BottomCenterArea extends StatelessWidget {
  final int flex;

  const _BottomCenterArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomCenterArea,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: const InventoryOverlay(),
        ),
      ),
    );
  }
}

final class _BottomRightArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;
  final PlayerController playerInput;

  const _BottomRightArea({
    required this.flex,
    required this.player,
    required this.playerInput,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomRightArea,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _JoystickArea(playerInput: playerInput),
              PlayerVitalStatsOverlay(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

final class _JoystickArea extends StatelessWidget {
  final PlayerController playerInput;

  const _JoystickArea({required this.playerInput});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SettingsManager.instance.inputSelected == InputActionsType.joystick
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
