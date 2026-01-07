import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_widget.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/equipment_overlay.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/inventory_overlay.dart';
import 'package:darkness_dungeon/gameplay/market/market_state.dart';
import 'package:darkness_dungeon/gameplay/market/widgets/market_panel.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/debug/debug_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/widgets/mobile_inputs_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/widgets/joystick_actions_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;
import 'package:darkness_dungeon/gameplay/time/widgets/time_hud_panel.dart';
import 'package:flutter/material.dart';

/// Overlay unificado que organiza todos os componentes da HUD em um grid 3x3
/// Grid com proporções: coluna 1 (flex 1), coluna 2 (flex 2), coluna 3 (flex 1)
/// Linha 1 (flex 1), Linha 2 (flex 2), Linha 3 (flex 1)
class UnifiedGameOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  final dynamic player;
  final PlayerController? playerController;

  const UnifiedGameOverlay({
    super.key,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final flexA = 1;
    final flexB = 6;
    final flexC = flexA + flexB;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = isDesktopScreen(context);

        return IgnorePointer(
          ignoring: false,
          child: Row(
            children: [
              Expanded(
                flex: flexA,
                child: Container(
                  color: AppEnvironment.kIsDebugMode
                      ? Colors.purple.withOpacity(0.05)
                      : null,
                  alignment: Alignment.centerLeft,
                  child: !isDesktop
                      ? const InventoryOverlay()
                      : const SizedBox.shrink(),
                ),
              ),
              Expanded(
                flex: flexC,
                child: Column(
                  children: [
                    // Linha 1 (Top) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Row(
                        children: [
                          // // Quadrante 1 (Top Left) - flex 1
                          // Expanded(
                          //   flex: flexA,
                          //   child: Container(
                          //     color: AppEnvironment.kIsDebugMode
                          //         ? Colors.red.withOpacity(0.05)
                          //         : null,
                          //     alignment: Alignment.topLeft,
                          //     // child: PlayerVitalStatsOverlay(player: player),
                          //   ),
                          // ),
                          // Quadrante 2 (Top Center) - flex 2
                          Expanded(
                            flex: flexB,
                            child: Container(
                              color: AppEnvironment.kIsDebugMode
                                  ? Colors.blue.withOpacity(0.05)
                                  : null,
                              // alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 8),
                                  DebugOverlay(
                                    player: player,
                                    // showFps: AppEnvironment.kIsDevToolsMode,
                                    // showPosition: AppEnvironment.kIsDevToolsMode,
                                    // showEntities: AppEnvironment.kIsDevToolsMode,
                                  ),
                                  const SizedBox(width: 8),
                                  const OverlayMessageWidget(),
                                ],
                              ),
                            ),
                          ),
                          // Quadrante 3 (Top Right) - flex 1
                          Expanded(
                            flex: flexA,
                            child: Container(
                              color: AppEnvironment.kIsDebugMode
                                  ? Colors.green.withOpacity(0.05)
                                  : null,
                              alignment: Alignment.topRight,
                              child: Stack(
                                children: [
                                  // if (AppEnvironment.kIsDebugMode)
                                  // const Align(
                                  //   alignment: Alignment.topRight,
                                  //   child: EquipmentOverlay(),
                                  // ),
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
                        ],
                      ),
                    ),
                    // Linha 2 (Middle) - flex 2
                    Expanded(
                      flex: flexB,
                      child: Row(
                        children: [
                          // // Quadrante 4 (Middle Left) - flex 1
                          // // Mobile/Tablet: InventoryOverlay aqui
                          // Expanded(
                          //   flex: flexA,
                          //   child: Container(
                          //     color: AppEnvironment.kIsDebugMode
                          //         ? Colors.pink.withOpacity(0.05)
                          //         : null,
                          //     alignment: Alignment.centerLeft,
                          //     child: !isDesktop
                          //         ? const InventoryOverlay()
                          //         : const SizedBox.shrink(),
                          //   ),
                          // ),
                          // Quadrante 5 (Center) - flex 2
                          Expanded(
                            flex: flexB,
                            child: Container(
                              color: AppEnvironment.kIsDebugMode
                                  ? Colors.yellow.withOpacity(0.05)
                                  : null,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  const TutorialInputsOverlay(),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: MarketState.instance.isOpen,
                                    builder: (context, isOpen, _) {
                                      if (!isOpen) return const SizedBox.shrink();
                                      return ValueListenableBuilder(
                                        valueListenable:
                                            MarketState.instance.activePlayer,
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
                                  ),
                                  // if (SettingsManager.instance.inputSelected ==
                                  //     InputActionsType.joystick)
                                  //   MobileInputsOverlay(
                                  //     playerController: playerController,
                                  //   ),
                                ],
                              ),
                            ),
                          ),
                          // Quadrante 6 (Middle Right) - flex 1
                          Expanded(
                            flex: flexA,
                            child: Container(
                              color: AppEnvironment.kIsDebugMode
                                  ? Colors.brown.withOpacity(0.05)
                                  : null,
                              child:
                                  SettingsManager.instance.inputSelected ==
                                      InputActionsType.joystick
                                  ? MobileInputsOverlay(
                                      playerController: playerController,
                                    )
                                  : const SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Linha 3 (Bottom) - flex 1
                    Expanded(
                      flex: flexA + 1,
                      child: Row(
                        children: [
                          // // Quadrante 7 (Bottom Left) - flex 1
                          // Expanded(
                          //   flex: flexA,
                          //   child: Container(
                          //     color: AppEnvironment.kIsDebugMode
                          //         ? Colors.purple.withOpacity(0.05)
                          //         : null,
                          //     child: const SizedBox(
                          //       width: double.infinity,
                          //       height: double.infinity,
                          //     ),
                          //   ),
                          // ),
                          // Quadrante 8 (Bottom Center) - flex 2
                          // Desktop: InventoryOverlay aqui
                          // Mobile: não existe (removido)
                          if (isDesktop)
                            Expanded(
                              flex: flexB,
                              child: Container(
                                color: AppEnvironment.kIsDebugMode
                                    ? Colors.orange.withOpacity(0.05)
                                    : null,
                                alignment: Alignment.bottomCenter,
                                child: const InventoryOverlay(),
                              ),
                            ),
                          // Quadrante 9 (Bottom Right) - flex 1
                          // JoystickActionsOverlay sempre no último quadrante
                          Expanded(
                            flex: flexA,
                            child: Container(
                              color: AppEnvironment.kIsDebugMode
                                  ? Colors.grey.withOpacity(0.05)
                                  : null,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child:
                                          SettingsManager
                                                  .instance
                                                  .inputSelected ==
                                              InputActionsType.joystick
                                          ? JoystickActionsOverlay(
                                              playerController:
                                                  playerController,
                                            )
                                          : const SizedBox(
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                    ),
                                    PlayerVitalStatsOverlay(player: player),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
