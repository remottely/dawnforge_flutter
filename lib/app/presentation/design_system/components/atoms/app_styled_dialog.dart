import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_button.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_styled_text.dart';
import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// UI component AppStyledDialog for the Darkness Dungeon game
/// Following Flutter naming conventions for design system components
///
/// This class handles:
/// - Consistent dialog styling throughout the application
/// - Custom backgrounds and child widget composition
/// - Factory methods for common dialog scenarios
///
/// Usage patterns:
/// ```dart
/// final dialog = AppStyledDialog(children: [Text('Content')]);
/// AppStyledDialog.gameOver(onRetry: () {});
/// AppStyledDialog.victory(onContinue: () {});
/// ```
class AppStyledDialog extends StatelessWidget {
  // 1. Constantes de configuração
  /// Standard background color for dialogs
  static const Color kStandardBackgroundColor =
      GameplayUIConstants.kTransparentColor;

  // 2. Propriedades da classe
  /// Background color of the dialog
  final Color backgroundColor;

  /// List of child widgets to display in the dialog
  final List<Widget> children;

  // 3. Construtor principal
  /// Creates a styled dialog with transparent background
  const AppStyledDialog({
    super.key,
    this.backgroundColor = kStandardBackgroundColor,
    required this.children,
  });

  // 4. Factory constructors
  /// Creates a styled dialog with custom background color
  const AppStyledDialog.withBackground({
    super.key,
    required this.backgroundColor,
    required this.children,
  });

  /// Factory constructor for game over dialog
  ///
  /// Provides a standardized game over dialog with retry functionality.
  ///
  /// Usage:
  /// ```dart
  /// AppStyledDialog.gameOver(
  ///   onRetry: () => Navigator.pop(context),
  /// )
  /// ```
  AppStyledDialog.gameOver({super.key, required VoidCallback onRetry})
    : backgroundColor = kStandardBackgroundColor,
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

  /// Factory constructor for victory dialog
  ///
  /// Provides a standardized victory dialog with continue functionality.
  ///
  /// Usage:
  /// ```dart
  /// AppStyledDialog.victory(
  ///   onContinue: () => Navigator.pop(context),
  /// )
  /// ```
  AppStyledDialog.victory({super.key, required VoidCallback onContinue})
    : backgroundColor = kStandardBackgroundColor,
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

  /// Factory constructor for confirmation dialog
  ///
  /// Provides a standardized confirmation dialog with customizable message.
  ///
  /// Usage:
  /// ```dart
  /// AppStyledDialog.confirmation(
  ///   message: 'Are you sure you want to quit?',
  ///   onConfirm: () => Navigator.pop(context, true),
  ///   onCancel: () => Navigator.pop(context, false),
  /// )
  /// ```
  AppStyledDialog.confirmation({
    super.key,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) : backgroundColor = kStandardBackgroundColor,
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
       ]; // 5. Método build
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
