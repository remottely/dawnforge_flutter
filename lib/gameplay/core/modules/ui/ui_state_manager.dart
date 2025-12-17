import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/screens/menu_screen.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_def.dart';
import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:darkness_dungeon/shared/design_system/widgets/atoms/dd_button.dart';
import 'package:darkness_dungeon/shared/design_system/widgets/atoms/dd_dialog_widget.dart';
import 'package:darkness_dungeon/shared/design_system/widgets/atoms/dd_text.dart';
import 'package:flutter/material.dart';

final class UIStateManager {
  UIStateManager._();

  static final UIStateManager instance = UIStateManager._();

  bool isShowingConversation = false;

  void displayGameOverDialog(
    BuildContext context,
    Function(BuildContext) onRetryPressed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DDDialogWidget(
          children: [
            Image.asset(
              UIStateDef.kGameOverAsset,
              height: UIStateDef.kGameOverImageHeight,
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
        return DDDialogWidget(
          children: [
            DDText.large(
              text: GameplayStringsLocation.instance.getString(
                'congratulations',
              ),
            ),
            const SizedBox(height: DDDesignSystem.kSpacingExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIStateDef.kHorizontalSpacing,
              ),
              child: DDText.small(
                text: GameplayStringsLocation.instance.getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DDDesignSystem.kSpacingExtraLarge),
            DDButton.elevated(
              labelText: "OK",
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
    Function(int)? onChangeConversation,
    VoidCallback? onFinishConversation,
    VoidCallback? onCloseConversation,
  }) {
    GameStateManager.stopPlayerMovement(player);

    TalkDialog.show(
      // TODO(Kevin): ConversationDisplay.show(...)
      context,
      conversationSequence,
      onChangeTalk: onChangeConversation,
      onFinish: onFinishConversation,
      onClose: onCloseConversation,
      logicalKeyboardKeysToNext: [KeyboardSetup.kPrimaryActionKey],
    );
  }

  static void _navigateToMainMenu(BuildContext context) {
    AudioManager.instance.stopBackgroundMusic();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
