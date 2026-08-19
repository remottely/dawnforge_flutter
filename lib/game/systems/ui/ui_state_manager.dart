import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/pre_game/screens/menu_screen.dart';
import 'package:dawnforge/game/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/systems/game/game_state_manager.dart';
import 'package:dawnforge/game/systems/input_actions/keyboard_setup.dart';
import 'package:dawnforge/game/systems/localization/gameplay_strings_location.dart';
import 'package:dawnforge/game/systems/ui/ui_state_def.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_button.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_dialog_widget.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_text.dart';
import 'package:flutter/material.dart';

final class UIStateManager {
  UIStateManager._();

  static final UIStateManager instance = UIStateManager._();

  bool isShowingConversation = false;

  void displayGameOverDialog(
    BuildContext context,
    Function(BuildContext) onRetryPressed,
  ) {
    final spacing = AppDesignSystem.of(context).spacing;

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
            SizedBox(height: spacing.kSpacingExtraSmall),
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
    final spacing = AppDesignSystem.of(context).spacing;

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
            SizedBox(height: spacing.kSpacingExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIStateDef.kHorizontalSpacing,
              ),
              child: DDText.small(
                text: GameplayStringsLocation.instance.getString('thanks'),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing.kSpacingExtraLarge),
            DDButton.elevated(
              labelText: 'OK',
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
      logicalKeyboardKeysToNext: [KeyboardSetup.kInteractionKey],
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
