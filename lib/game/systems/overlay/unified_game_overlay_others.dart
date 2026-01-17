import 'package:flutter/material.dart';

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

class UiMenuInventoryPage extends StatelessWidget {
  const UiMenuInventoryPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiMenuQuestPage extends StatelessWidget {
  const UiMenuQuestPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiMenuMapPage extends StatelessWidget {
  const UiMenuMapPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiMenuSettingsPage extends StatelessWidget {
  const UiMenuSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiOverlayCraftingPanel extends StatelessWidget {
  const UiOverlayCraftingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiOverlayCookingPanel extends StatelessWidget {
  const UiOverlayCookingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiOverlayChoiceDialog extends StatelessWidget {
  const UiOverlayChoiceDialog({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiOverlayConversationDialog extends StatelessWidget {
  const UiOverlayConversationDialog({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class GameplayResumedFishingHud extends StatelessWidget {
  const GameplayResumedFishingHud({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class UiOverlayGameoverDialog extends StatelessWidget {
  const UiOverlayGameoverDialog({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
