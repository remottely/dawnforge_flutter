import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// [AppStyledButton] responsible for providing styled buttons following game's visual theme
///
/// This component provides consistent button styling throughout the application,
/// supporting multiple variants (primary, transparent) with proper theming.
///
/// Usage examples:
/// ```dart
/// AppStyledButton(text: 'Click me', onPressed: () {})
/// AppStyledButton.primary(text: 'Primary Action', onPressed: () {})
/// AppStyledButton.transparent(text: 'Secondary', onPressed: () {})
/// ```
///
/// Following CLAUDE.md patterns for Flutter StatelessWidget components
class AppStyledButton extends StatelessWidget {
  // 1. Constantes de configuração
  /// Font family used throughout the game
  static const String kFontFamily = 'Normal';

  /// Default font size for buttons
  static const double kNormalFontSize = 20.0;

  /// Default button font size for primary buttons
  static const double kButtonFontSize = 16.0;

  /// Default text color
  static const Color kDefaultTextColor = Colors.white;

  /// Default button background color
  static const Color kPrimaryBackgroundColor = Color.fromARGB(255, 118, 82, 78);

  /// Border radius for styled buttons
  static const double kButtonBorderRadius = 4.0;

  // 2. Propriedades da classe
  /// The button text content
  final String text;

  /// Callback function when button is pressed
  final VoidCallback onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Font size for button text
  final double fontSize;

  // 3. Construtor principal
  /// Creates a styled button following game's visual theme
  /// Following Flutter pattern of customizable button widgets
  const AppStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = kNormalFontSize,
  });

  // 4. Factory constructors
  /// Creates a primary styled button with default game colors
  const AppStyledButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = kPrimaryBackgroundColor,
    this.fontSize = kButtonFontSize,
  });

  /// Creates a transparent styled button for secondary actions
  const AppStyledButton.transparent({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = kNormalFontSize,
  });

  // 5. Método build
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape: backgroundColor != GameplayUIConstants.kTransparentColor
            ? WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kButtonBorderRadius),
                ),
              )
            : null,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: kDefaultTextColor,
          fontFamily: kFontFamily,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
