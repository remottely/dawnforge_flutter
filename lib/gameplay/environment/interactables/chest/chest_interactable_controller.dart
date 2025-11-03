import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/chest/chest_interactable_config.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/chest/chest_interactable_model.dart';
import 'package:flutter/services.dart';

/// Controller: Lógica de negócio do Chest
/// Não conhece detalhes de implementação da View
class ChestInteractableController {
  final ChestInteractableModel model;

  // Callbacks para comunicação com View
  final void Function() onShowEmote;
  final void Function() onShowInteractionPrompt;
  final void Function() onHideInteractionPrompt;
  final void Function() onOpenChest;
  final void Function({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  })
  onCheckPlayerVision;

  ChestInteractableController({
    required this.model,
    required this.onShowEmote,
    required this.onShowInteractionPrompt,
    required this.onHideInteractionPrompt,
    required this.onOpenChest,
    required this.onCheckPlayerVision,
  });

  // Lifecycle
  void update(double dt, GameComponent? player) {
    if (player == null || model.isOpened) return;
    _handlePlayerVision(player);
  }

  void dispose() {
    // Cleanup se necessário
  }

  // Input handling
  void handleKeyboardInput(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!model.canBeOpened) return;

    if (event is KeyDownEvent &&
        keysPressed.contains(LogicalKeyboardKey.space)) {
      openChest();
    }
  }

  // Actions
  void openChest() {
    if (!model.canBeOpened) return;
    model.markAsOpened();
    onOpenChest();
  }

  // Private helpers
  void _handlePlayerVision(GameComponent player) {
    onCheckPlayerVision(
      player: player,
      radiusVision: ChestInteractableConfig.kVisionRadius,
      observed: (observedPlayer) {
        if (!model.observedPlayer) {
          model.setObservedPlayer(true);
          onShowEmote();
          onShowInteractionPrompt();
        }
      },
      notObserved: () {
        if (model.observedPlayer) {
          model.setObservedPlayer(false);
          onHideInteractionPrompt();
        }
      },
    );
  }
}
