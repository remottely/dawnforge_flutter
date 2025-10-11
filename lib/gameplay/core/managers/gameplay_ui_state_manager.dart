import 'package:darkness_dungeon/gameplay/core/localization/strings_location.dart';
import 'package:darkness_dungeon/presentation/screens/menu_screen.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/styled_button.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/styled_dialog.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/styled_text.dart';
import 'package:flutter/material.dart';

/// UI State Manager for game dialogs and modal windows
/// Following Flutter naming conventions for UI state management systems
class GameplayUIStateManager {
  // Flutter-style constants for UI configuration
  static const double _kGameOverImageHeight = 100.0;
  static const double _kDefaultSpacing = 10.0;
  static const double _kLargeSpacing = 30.0;
  static const double _kHorizontalPadding = 100.0;
  static const String _kGameOverAssetPath = 'assets/game_over.png';

  /// Transparent background color
  static const Color kTransparentColor = Colors.transparent;

  /// Displays the Game Over screen with retry option
  static void displayGameOverDialog(
    BuildContext context,
    Function(BuildContext) onRetryPressed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StyledDialog(
          children: [
            Image.asset(_kGameOverAssetPath, height: _kGameOverImageHeight),
            const SizedBox(height: _kDefaultSpacing),
            StyledButton(
              text: getString('play_again_cap'),
              onPressed: () => onRetryPressed(dialogContext),
            ),
          ],
        );
      },
    );
  }

  /// Displays the victory/congratulations screen
  static void displayVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StyledDialog(
          children: [
            StyledText.large(text: getString('congratulations')),
            const SizedBox(height: _kDefaultSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: StyledText.small(
                text: getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: _kLargeSpacing),
            StyledButton.primary(
              text: "OK",
              onPressed: () => _navigateToMainMenu(context),
            ),
          ],
        );
      },
    );
  }

  /// Private helper method to navigate back to main menu
  /// Following Flutter pattern of private utility methods with underscore prefix
  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
