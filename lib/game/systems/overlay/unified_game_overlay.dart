import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/market/widgets/market_panel.dart';
import 'package:dawnforge/game/state/game_state_machine.dart';
import 'package:dawnforge/game/systems/overlay/gameplay_resumed_hud.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

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
    final isDesktop = AppDesignSystem.of(context).screenSize.isDesktop;

    const flexA = 1;
    const flexB = 6;
    const flexC = flexA + flexB;

    return ValueListenableBuilder<GameState>(
      valueListenable: GameStateMachine.instance.getRxCurrentState(),
      builder: (context, gameState, _) {
        return switch (gameState) {
          GameState.gameLoading => const GameLoadingScreen(),

          GameState.gameCutscene => const GameCutsceneScreen(), // TODO: Criar

          GameState.gameTransitioning =>
            const GameTransitioningScreen(), // TODO: Criar

          GameState.gameplayResumed => GameplayResumedHud(
            flexA: flexA,
            isDesktop: isDesktop,
            flexC: flexC,
            flexB: flexB,
            player: player,
            playerController: playerController,
            gameState: gameState,
          ),

          GameState.gameplayPaused => SizedBox.shrink(),

          GameState.uiMenuInventory =>
            const UIMenuInventoryPage(), // TODO: Criar

          GameState.uiMenuQuest => const UIMenuQuestPage(), // TODO: Criar

          GameState.uiMenuMap => const UIMenuMapPage(), // TODO: Criar

          GameState.uiMenuSettings => const UIMenuSettingsPage(), // TODO: Criar

          GameState.uiOverlayMinigameFishing => Stack(
            children: [
              GameplayResumedHud(
                flexA: flexA,
                isDesktop: isDesktop,
                flexC: flexC,
                flexB: flexB,
                player: player,
                playerController: playerController,
                gameState: gameState,
              ),
              const UIMinigameFishingHud(), // TODO: Criar
            ],
          ),

          GameState.uiOverlayCrafting => Column(
            children: [
              const UIOverlayCraftingPanel(), // TODO: Criar
              // TODO(Kevin): show inventory
            ],
          ),

          GameState.uiOverlayCooking => Column(
            children: [
              const UIOverlayCookingPanel(), // TODO: Criar
              // TODO(Kevin): show inventory
            ],
          ),

          GameState.uiOverlayMarket => Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UIOverlayMarketPanel(playerModel: player.controller.model),
                // TODO(Kevin): show inventory
              ],
            ),
          ),

          GameState.uiOverlayChoiceDialog =>
            const UIOverlayChoiceDialogPage(), // TODO: Criar

          GameState.uiOverlayConversation =>
            const UIOverlayConversationPage(), // TODO: Criar

          GameState.uiOverlayGameover =>
            const UIOverlayGameoverPage(), // TODO: Criar
        };
      },
    );
  }
}

// ====================================================================
// PLACEHOLDER OVERLAYS (criar depois)
// ====================================================================

class GameLoadingScreen extends StatelessWidget {
  const GameLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// TODO: Criar os overlays faltantes:
class GameCutsceneScreen extends StatelessWidget {
  const GameCutsceneScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class GameTransitioningScreen extends StatelessWidget {
  const GameTransitioningScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIMenuInventoryPage extends StatelessWidget {
  const UIMenuInventoryPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIMenuQuestPage extends StatelessWidget {
  const UIMenuQuestPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIMenuMapPage extends StatelessWidget {
  const UIMenuMapPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIMenuSettingsPage extends StatelessWidget {
  const UIMenuSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIOverlayCraftingPanel extends StatelessWidget {
  const UIOverlayCraftingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIOverlayCookingPanel extends StatelessWidget {
  const UIOverlayCookingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIOverlayChoiceDialogPage extends StatelessWidget {
  const UIOverlayChoiceDialogPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIOverlayConversationPage extends StatelessWidget {
  const UIOverlayConversationPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIMinigameFishingHud extends StatelessWidget {
  const UIMinigameFishingHud({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UIOverlayGameoverPage extends StatelessWidget {
  const UIOverlayGameoverPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
