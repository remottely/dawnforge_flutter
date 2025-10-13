import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// [AppStyledButton] responsible for providing styled buttons following game's visual theme
/// Following Flutter naming conventions for reusable button widgets
class AppStyledButton extends StatelessWidget {
  /// The button text content
  final String text;

  /// Callback function when button is pressed
  final VoidCallback onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Font size for button text
  final double fontSize;

  /// Font family used throughout the game
  static const String _kFontFamily = 'Normal';

  /// Default font size for buttons
  static const double _kNormalFontSize = 20.0;

  /// Default button font size
  static const double _kButtonFontSize = 16.0;

  /// Default text color
  static const Color _kWhiteColor = Colors.white;

  /// Default button background color
  static const Color _kButtonBackgroundColor = Color.fromARGB(255, 118, 82, 78);

  /// Border radius for styled buttons
  static const double _kButtonBorderRadius = 4.0;

  /// Creates a styled button following game's visual theme
  /// Following Flutter pattern of customizable button widgets
  const AppStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = _kNormalFontSize,
  });

  /// Creates a primary styled button with default game colors
  const AppStyledButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = _kButtonBackgroundColor,
    this.fontSize = _kButtonFontSize,
  });

  /// Creates a transparent styled button for secondary actions
  const AppStyledButton.transparent({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = _kNormalFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape: backgroundColor != GameplayUIConstants.kTransparentColor
            ? WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kButtonBorderRadius),
                ),
              )
            : null,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: _kWhiteColor,
          fontFamily: _kFontFamily,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
