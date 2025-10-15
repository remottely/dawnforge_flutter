import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_dialog.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/presentation/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI State Manager for game dialogs and modal windows
/// Following Flutter naming conventions for UI state management systems
///
/// This class handles:
/// - Game over dialog display and retry functionality
/// - Victory dialog with congratulations message
/// - Navigation back to main menu after game completion
/// - Centralized UI constants usage for consistent styling
class GameplayUIManager {
  // 1. Public static methods for UI operations
  /// Displays the Game Over screen with retry option
  ///
  /// Takes a [context] for dialog display and [onRetryPressed] callback
  /// that receives the dialog context for proper dismissal handling
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
            Image.asset(
              GameplayUIConstants.kGameOverAssetPath,
              height: GameplayUIConstants.kGameOverImageHeight,
            ),
            const SizedBox(height: GameplayUIConstants.kDefaultSpacing),
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
  ///
  /// Shows a modal dialog with congratulations message and navigation
  /// back to main menu. Uses centralized UI constants for consistent styling.
  static void displayVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppStyledDialog(
          children: [
            AppStyledText.large(text: getString('congratulations')),
            const SizedBox(height: GameplayUIConstants.kDefaultSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GameplayUIConstants.kHorizontalPadding,
              ),
              child: AppStyledText.small(
                text: getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: GameplayUIConstants.kLargeSpacing),
            AppStyledButton.primary(
              text: "OK",
              onPressed: () => _navigateToMainMenu(context),
            ),
          ],
        );
      },
    );
  }

  /// Displays a conversation dialog using TalkDialog
  ///
  /// Shows a conversation sequence with customizable callbacks.
  /// This method centralizes TalkDialog usage to eliminate direct UI calls
  /// from gameplay entities.
  static void displayConversationDialog(
    BuildContext context,
    List<Say> dialogueSequence, {
    Function(int)? onChangeTalk,
    VoidCallback? onFinish,
    VoidCallback? onClose,
    List<LogicalKeyboardKey>? logicalKeyboardKeysToNext,
  }) {
    TalkDialog.show(
      context,
      dialogueSequence,
      onChangeTalk: onChangeTalk,
      onFinish: onFinish,
      onClose: onClose,
      logicalKeyboardKeysToNext:
          logicalKeyboardKeysToNext ?? [LogicalKeyboardKey.space],
    );
  }

  // 2. Private helper methods
  /// Private helper method to navigate back to main menu
  /// Following Flutter pattern of private utility methods with underscore prefix
  ///
  /// Performs a clean navigation that removes all previous routes from the stack,
  /// ensuring the user cannot navigate back to the game after completion.
  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
