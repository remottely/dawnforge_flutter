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
