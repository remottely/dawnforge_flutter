import 'package:flutter/material.dart';

/// [AppStyledText] responsible for providing styled text following game's visual theme
/// Following Flutter naming conventions for reusable text widgets
class AppStyledText extends StatelessWidget {
  /// The text content to display
  final String text;

  /// Font size for the text
  final double fontSize;

  /// Text color
  final Color color;

  /// Text alignment
  final TextAlign textAlign;

  /// Font family used throughout the game
  static const String _kFontFamily = 'Normal';

  /// Default font size for normal text
  static const double _kNormalFontSize = 20.0;

  /// Default text color
  static const Color _kWhiteColor = Colors.white;

  /// Creates a styled text widget with game font
  /// Following Flutter pattern of named constructors for different text styles
  const AppStyledText({
    super.key,
    required this.text,
    this.fontSize = _kNormalFontSize,
    this.color = _kWhiteColor,
    this.textAlign = TextAlign.start,
  });

  /// Creates a large styled text for headings
  const AppStyledText.large({
    super.key,
    required this.text,
    this.fontSize = 32.0,
    this.color = _kWhiteColor,
    this.textAlign = TextAlign.start,
  });

  /// Creates a small styled text for secondary content
  const AppStyledText.small({
    super.key,
    required this.text,
    this.fontSize = 18.0,
    this.color = _kWhiteColor,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
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
}
