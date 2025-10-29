import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_ui_config.dart';
import 'package:flutter/material.dart';

class AppStyledDialog extends StatelessWidget {
  static const _kStandardBackgroundColor = GameplayUIConfig.kTransparentColor;

  final Color backgroundColor;
  final List<Widget> children;

  const AppStyledDialog({
    super.key,
    this.backgroundColor = _kStandardBackgroundColor,
    required this.children,
  });

  const AppStyledDialog.withBackground({
    super.key,
    required this.backgroundColor,
    required this.children,
  });

  AppStyledDialog.gameOver({super.key, required VoidCallback onRetry})
    : backgroundColor = _kStandardBackgroundColor,
      children = [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppStyledText(
                text: 'Game Over',
                fontSize: TypographyConstants.kHeadlineFontSize,
                color: Colors.red,
              ),
              const SizedBox(height: 16.0),
              const AppStyledText(
                text: 'Try again?',
                fontSize: TypographyConstants.kCaptionFontSize,
                color: Colors.white,
              ),
              const SizedBox(height: 20.0),
              AppStyledButton.primary(text: 'Retry', onPressed: onRetry),
            ],
          ),
        ),
      ];

  AppStyledDialog.victory({super.key, required VoidCallback onContinue})
    : backgroundColor = _kStandardBackgroundColor,
      children = [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppStyledText(
                text: 'Victory!',
                fontSize: TypographyConstants.kHeadlineFontSize,
                color: Colors.green,
              ),
              const SizedBox(height: 16.0),
              const AppStyledText(
                text: 'Congratulations!',
                fontSize: TypographyConstants.kCaptionFontSize,
                color: Colors.white,
              ),
              const SizedBox(height: 20.0),
              AppStyledButton.primary(text: 'Continue', onPressed: onContinue),
            ],
          ),
        ),
      ];

  AppStyledDialog.confirmation({
    super.key,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) : backgroundColor = _kStandardBackgroundColor,
       children = [
         Padding(
           padding: const EdgeInsets.all(20.0),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               const AppStyledText(
                 text: 'Confirm',
                 fontSize: TypographyConstants.kBodyFontSize,
                 color: Colors.white,
               ),
               const SizedBox(height: 16.0),
               AppStyledText(
                 text: message,
                 fontSize: TypographyConstants.kCaptionFontSize,
                 color: Colors.white70,
               ),
               const SizedBox(height: 20.0),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   if (onCancel != null)
                     AppStyledButton.transparent(
                       text: 'Cancel',
                       onPressed: onCancel,
                     ),
                   AppStyledButton.primary(
                     text: 'Confirm',
                     onPressed: onConfirm,
                   ),
                 ],
               ),
             ],
           ),
         ),
       ];
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
