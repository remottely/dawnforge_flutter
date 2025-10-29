import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_dialog.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/app/presentation/screens/menu_screen.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_ui_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameplayUIManager {
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
              GameplayUIConfig.kGameOverAsset,
              height: GameplayUIConfig.kGameOverImageHeight,
            ),
            const SizedBox(height: GameplayUIConfig.kStandardSpacing),
            AppStyledButton(
              text: GameplayStringsLocation.instance.getString(
                'play_again_cap',
              ),
              onPressed: () => onRetryPressed(dialogContext),
            ),
          ],
        );
      },
    );
  }

  static void displayVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppStyledDialog(
          children: [
            AppStyledText.large(
              text: GameplayStringsLocation.instance.getString(
                'congratulations',
              ),
            ),
            const SizedBox(height: GameplayUIConfig.kStandardSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GameplayUIConfig.kHorizontalPadding,
              ),
              child: AppStyledText.small(
                text: GameplayStringsLocation.instance.getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: GameplayUIConfig.kLargeSpacing),
            AppStyledButton.primary(
              text: "OK",
              onPressed: () => _navigateToMainMenu(context),
            ),
          ],
        );
      },
    );
  }

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
          logicalKeyboardKeysToNext ??
          [GameplayInputActionsConfig.kKeyboardMeleeAttack],
    );
  }

  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
