import 'package:darkness_dungeon/presentation/design_system/constants/typography_constants.dart';
import 'package:flutter/material.dart';

/// [AppStyledText] responsible for providing styled text following game's visual theme
///
/// This component provides consistent text styling throughout the application,
/// supporting multiple size variants and maintaining visual consistency.
///
/// Usage examples:
/// ```dart
/// AppStyledText(text: 'Normal text')
/// AppStyledText.large(text: 'Heading text')
/// AppStyledText.small(text: 'Secondary text')
/// ```
///
/// Following CLAUDE.md patterns for Flutter StatelessWidget components
class AppStyledText extends StatelessWidget {
  // 1. Constantes de configuração
  /// Default text color
  static const Color kDefaultColor = Colors.white;

  // 2. Propriedades da classe
  /// The text content to display
  final String text;

  /// Font size for the text
  final double fontSize;

  /// Text color
  final Color color;

  /// Text alignment
  final TextAlign textAlign;

  // 3. Construtor principal
  /// Creates a styled text widget with game font
  /// Following Flutter pattern of named constructors for different text styles
  const AppStyledText({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kBodyFontSize,
    this.color = kDefaultColor,
    this.textAlign = TextAlign.start,
  });

  // 4. Factory constructors
  /// Creates a large styled text for headings
  const AppStyledText.large({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kDisplayFontSize,
    this.color = kDefaultColor,
    this.textAlign = TextAlign.start,
  });

  /// Creates a small styled text for secondary content
  const AppStyledText.small({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kSmallFontSize,
    this.color = kDefaultColor,
    this.textAlign = TextAlign.start,
  });

  // 5. Método build
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: TypographyConstants.kPrimaryFontFamily,
        fontSize: fontSize,
      ),
      textAlign: textAlign,
    );
  }
}
