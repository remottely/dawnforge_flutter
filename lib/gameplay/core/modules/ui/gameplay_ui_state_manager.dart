import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_dialog.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/app/presentation/screens/menu_screen.dart';
import 'package:darkness_dungeon/gameplay/core/modules/player_input_actions/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/gameplay_ui_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_game_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameplayUIStateManager {
  static final instance = GameplayUIStateManager();

  var isShowingConversation = false;

  void displayGameOverDialog(
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

  void displayVictoryDialog(BuildContext context) {
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

  void showConversation(
    BuildContext context, {
    required Player player,
    required List<Say> conversationSequence,
    Function(int)? onChangeTalk,
    VoidCallback? onFinish,
    VoidCallback? onClose,
    List<LogicalKeyboardKey>? logicalKeyboardKeysToNext,
  }) {
    GameplayGameStateManager.stopPlayerMovement(player);

    TalkDialog.show(
      context,
      conversationSequence,
      onChangeTalk: onChangeTalk,
      onFinish: onFinish,
      onClose: onClose,
      logicalKeyboardKeysToNext:
          logicalKeyboardKeysToNext ??
          [GameplayPlayerInputActionsConfig.kKeyboardPrimaryAttack],
    );
  }

  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
