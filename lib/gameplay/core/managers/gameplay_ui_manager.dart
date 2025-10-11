import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_dialog.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/presentation/screens/menu_screen.dart';
import 'package:flutter/material.dart';

/// UI State Manager for game dialogs and modal windows
/// Following Flutter naming conventions for UI state management systems
class GameplayUIManager {
  // Flutter-style constants for UI configuration
  static const double _kGameOverImageHeight = 96.0;
  static const double _kDefaultSpacing = 8.0;
  static const double _kLargeSpacing = 32.0;
  static const double _kHorizontalPadding = 96.0;
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
        return AppStyledDialog(
          children: [
            Image.asset(_kGameOverAssetPath, height: _kGameOverImageHeight),
            const SizedBox(height: _kDefaultSpacing),
            AppStyledButton(
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
        return AppStyledDialog(
          children: [
            AppStyledText.large(text: getString('congratulations')),
            const SizedBox(height: _kDefaultSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: AppStyledText.small(
                text: getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: _kLargeSpacing),
            AppStyledButton.primary(
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
