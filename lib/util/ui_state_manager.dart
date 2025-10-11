import 'package:darkness_dungeon/menu_screen.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:flutter/material.dart';

/// UI State Manager for game dialogs and modal windows
/// Following Flutter naming conventions for UI state management systems
class UIStateManager {
  // Flutter-style constants for UI configuration
  static const double _kGameOverImageHeight = 100.0;
  static const double _kDefaultSpacing = 10.0;
  static const double _kLargeSpacing = 30.0;
  static const double _kCongratulationsFontSize = 30.0;
  static const double _kNormalFontSize = 20.0;
  static const double _kSmallFontSize = 18.0;
  static const double _kButtonFontSize = 17.0;
  static const double _kHorizontalPadding = 100.0;
  static const double _kButtonBorderRadius = 5.0;
  static const String _kFontFamily = 'Normal';
  static const String _kGameOverAssetPath = 'assets/game_over.png';

  // Flutter-style color constants
  static const Color _kTransparentColor = Colors.transparent;
  static const Color _kWhiteColor = Colors.white;
  static const Color _kButtonBackgroundColor = Color.fromARGB(255, 118, 82, 78);

  /// Displays the Game Over screen with retry option
  static void displayGameOverDialog(
      BuildContext context, VoidCallback onRetryPressed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _createStyledDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                _kGameOverAssetPath,
                height: _kGameOverImageHeight,
              ),
              const SizedBox(height: _kDefaultSpacing),
              _createStyledButton(
                text: getString('play_again_cap'),
                onPressed: onRetryPressed,
                fontSize: _kNormalFontSize,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays the victory/congratulations screen
  static void displayVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _createStyledDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createStyledText(
                text: getString('congratulations'),
                fontSize: _kCongratulationsFontSize,
              ),
              const SizedBox(height: _kDefaultSpacing),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
                child: _createStyledText(
                  text: getString('thanks'),
                  fontSize: _kSmallFontSize,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: _kLargeSpacing),
              _createStyledButton(
                text: "OK",
                onPressed: () => _navigateToMainMenu(context),
                backgroundColor: _kButtonBackgroundColor,
                fontSize: _kButtonFontSize,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Private helper method to navigate back to main menu
  /// Following Flutter pattern of private utility methods with underscore prefix
  static void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Creates a styled dialog widget following Flutter UI patterns
  /// This is a reusable component for dialog creation
  static Widget _createStyledDialog({
    required Widget child,
    Color backgroundColor = _kTransparentColor,
  }) {
    return Material(
      color: backgroundColor,
      child: Center(child: child),
    );
  }

  /// Creates a styled text widget with game font
  /// Following Flutter's component-based approach
  static Widget _createStyledText({
    required String text,
    double fontSize = _kNormalFontSize,
    Color color = _kWhiteColor,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: _kFontFamily,
        fontSize: fontSize,
      ),
      textAlign: textAlign,
    );
  }

  /// Creates a styled button following game's visual theme
  /// Flutter-style component factory method
  static Widget _createStyledButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = _kTransparentColor,
    double fontSize = _kNormalFontSize,
  }) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape: backgroundColor != _kTransparentColor
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
