/// **UnifiedGameOverlay - MIGRADO PARA NOVA ARQUITETURA**
/// Overlay unificado que organiza todos os componentes da HUD em um grid 3x3
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/overlay/design_system/overlay_design_system_extension.dart';
import 'package:dawnforge/gameplay/overlay/overlay_message_widget.dart';
import 'package:dawnforge/gameplay/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:dawnforge/gameplay/overlay/inventory_overlay.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/gameplay/market/widgets/market_panel.dart';
import 'package:dawnforge/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/debug/debug_overlay.dart';
import 'package:dawnforge/gameplay/overlay/mobile_inputs_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/widgets/joystick_actions_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/managers/settings_manager.dart';
import 'package:dawnforge/gameplay/time/time_manager.dart' as new_time;
import 'package:dawnforge/gameplay/time/widgets/time_hud_panel.dart';
import 'package:dawnforge/core/utils/debug_helpers.dart';
import 'package:flutter/material.dart';

/// Overlay unificado que organiza todos os componentes da HUD em um grid 3x3
final class UnifiedGameOverlay extends StatelessWidget {
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const UnifiedGameOverlay({
    super.key,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Usa extension para verificar se é desktop
    final isDesktop = context.isOverlayDesktop;

    const flexA = 1;
    const flexB = 6;
    const flexC = flexA + flexB;

    return IgnorePointer(
      ignoring: false,
      child: Row(
        children: [
          _LeftArea(
            flex: flexA,
            isDesktop: isDesktop,
          ),
          _MainArea(
            flex: flexC,
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área lateral esquerda - Inventário mobile
final class _LeftArea extends StatelessWidget {
  final int flex;
  final bool isDesktop;

  const _LeftArea({
    required this.flex,
    required this.isDesktop,
  });

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

/// Área principal que contém as 3 linhas (top, middle, bottom)
final class _MainArea extends StatelessWidget {
  final int flex;
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _MainArea({
    required this.flex,
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    this.playerController,
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
          ),
          _MiddleRow(
            flexA: flexA,
            flexB: flexB,
            playerController: playerController,
          ),
          _BottomRow(
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Linha superior (Top Row)
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
          _TopCenterArea(
            flex: flexB,
            player: player,
          ),
          _TopRightArea(flex: flexA),
        ],
      ),
    );
  }
}

/// Área central superior - Debug e Mensagens
final class _TopCenterArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;

  const _TopCenterArea({
    required this.flex,
    required this.player,
  });

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
            const OverlayMessageWidget(),
          ],
        ),
      ),
    );
  }
}

/// Área direita superior - Tempo e Fullscreen
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
              TimeHudPanel(
                timeManager: new_time.TimeManager.instance,
              ),
              const Align(
                alignment: Alignment.topRight,
                child: FullscreenButtonOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha do meio (Middle Row)
final class _MiddleRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final PlayerController? playerController;

  const _MiddleRow({
    required this.flexA,
    required this.flexB,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexB,
      child: Row(
        children: [
          _CenterArea(flex: flexB),
          _CenterRightArea(
            flex: flexA,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área central - Tutorial e Market
final class _CenterArea extends StatelessWidget {
  final int flex;

  const _CenterArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterArea,
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              const TutorialInputsOverlay(),
              _MarketPanelArea(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Área do painel de mercado (Market)
final class _MarketPanelArea extends StatelessWidget {
  const _MarketPanelArea();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MarketState.instance.isOpen,
      builder: (context, isOpen, _) {
        if (!isOpen) return const SizedBox.shrink();

        return ValueListenableBuilder(
          valueListenable: MarketState.instance.activePlayer,
          builder: (context, player, __) {
            if (player == null) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.center,
              child: MarketPanel(player: player),
            );
          },
        );
      },
    );
  }
}

/// Área direita central - Mobile Inputs
final class _CenterRightArea extends StatelessWidget {
  final int flex;
  final PlayerController? playerController;

  const _CenterRightArea({
    required this.flex,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterRightArea,
        child: SettingsManager.instance.inputSelected ==
                InputActionsType.joystick
            ? MobileInputsOverlay(
                playerController: playerController,
              )
            : const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}

/// Linha inferior (Bottom Row)
final class _BottomRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _BottomRow({
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    this.playerController,
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
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área central inferior - Inventário desktop
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

/// Área direita inferior - Joystick Actions e Vital Stats
final class _BottomRightArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _BottomRightArea({
    required this.flex,
    required this.player,
    this.playerController,
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
              _JoystickArea(playerController: playerController),
              PlayerVitalStatsOverlay(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

/// Área do Joystick Actions
final class _JoystickArea extends StatelessWidget {
  final PlayerController? playerController;

  const _JoystickArea({this.playerController});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SettingsManager.instance.inputSelected ==
              InputActionsType.joystick
          ? JoystickActionsOverlay(
              playerController: playerController,
            )
          : const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }
}
