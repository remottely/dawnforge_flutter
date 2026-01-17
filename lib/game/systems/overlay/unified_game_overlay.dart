import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/market/widgets/market_panel.dart';
import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/game/systems/game/player_state_manager.dart';
import 'package:dawnforge/game/systems/overlay/gameplay_resumed_hud.dart';
import 'package:dawnforge/game/systems/overlay/unified_game_overlay_others.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

final class UnifiedGameOverlay extends StatelessWidget {
  final DDBasePlayerView player;
  final PlayerController playerInput;

  const UnifiedGameOverlay({
    super.key,
    required this.player,
    required this.playerInput,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDesignSystem.of(context).screenSize.isDesktop;

    const flexA = 1;
    const flexB = 6;
    const flexC = flexA + flexB;

    return ValueListenableBuilder<GlobalState>(
      valueListenable: GlobalStateMachine.instance.getRxCurrentState(),
      builder: (context, globalState, _) {
        return switch (globalState) {
          GlobalState.gameLoading => const GameLoadingScreen(),

          GlobalState.gameCutscene => const GameCutsceneScreen(), // TODO: Criar

          GlobalState.gameTransitioning =>
            const GameTransitioningScreen(), // TODO: Criar

          GlobalState.gameplayResumed => GameplayResumedHud(
            flexA: flexA,
            isDesktop: isDesktop,
            flexC: flexC,
            flexB: flexB,
            player: player,
            playerInput: playerInput,
            globalState: globalState,
          ),

          GlobalState.gameplayPaused => SizedBox.shrink(),

          GlobalState.uiMenuInventory =>
            const UIMenuInventoryPage(), // TODO: Criar

          GlobalState.uiMenuQuest => const UIMenuQuestPage(), // TODO: Criar

          GlobalState.uiMenuMap => const UIMenuMapPage(), // TODO: Criar

          GlobalState.uiMenuSettings =>
            const UIMenuSettingsPage(), // TODO: Criar

          GlobalState.uiOverlayMinigameFishing => Stack(
            children: [
              GameplayResumedHud(
                flexA: flexA,
                isDesktop: isDesktop,
                flexC: flexC,
                flexB: flexB,
                player: player,
                playerInput: playerInput,
                globalState: globalState,
              ),
              const UIMinigameFishingHud(), // TODO: Criar
            ],
          ),

          GlobalState.uiOverlayCrafting => Column(
            children: [
              const UIOverlayCraftingPanel(), // TODO: Criar
              // TODO(Kevin): show inventory
            ],
          ),

          GlobalState.uiOverlayCooking => Column(
            children: [
              const UIOverlayCookingPanel(), // TODO: Criar
              // TODO(Kevin): show inventory
            ],
          ),

          GlobalState.uiOverlayMarket => Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UIOverlayMarketPanel(
                  playerModel: PlayerStateManager.instance.lastPlayerModel!,
                ),
                // TODO(Kevin): show inventory
              ],
            ),
          ),

          GlobalState.uiOverlayChoiceDialog =>
            const UIOverlayChoiceDialogPage(), // TODO: Criar

          GlobalState.uiOverlayConversation =>
            const UIOverlayConversationPage(), // TODO: Criar

          GlobalState.uiOverlayGameover =>
            const UIOverlayGameoverPage(), // TODO: Criar
        };
      },
    );
  }
}
