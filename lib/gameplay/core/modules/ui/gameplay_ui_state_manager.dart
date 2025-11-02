import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/presentation/screens/menu_screen.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/gameplay_ui_config.dart';
import 'package:darkness_dungeon/shared/design_system/components/atoms/app_styled_dialog.dart';
import 'package:darkness_dungeon/shared/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/shared/design_system/components/atoms/dd_button.dart';
import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class GameplayUIStateManager {
  GameplayUIStateManager._();

  static final GameplayUIStateManager instance = GameplayUIStateManager._();

  bool isShowingConversation = false;

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
            const SizedBox(height: DDDesignSystem.kSpacingExtraSmall),
            DDButton.text(
              labelText: GameplayStringsLocation.instance.getString(
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
            const SizedBox(height: DDDesignSystem.kSpacingExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GameplayUIConfig.kHorizontalSpacing,
              ),
              child: AppStyledText.small(
                text: GameplayStringsLocation.instance.getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DDDesignSystem.kSpacingExtraLarge),
            DDButton.elevated(
              labelText: "OKay",
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
          [GameplayKeyboardConfig.kPrimaryAttackKey],
    );
  }

  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
