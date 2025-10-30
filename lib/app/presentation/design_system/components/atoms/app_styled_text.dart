import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:flutter/material.dart';

class AppStyledText extends StatelessWidget {
  static const Color _kStandardColor =
      Colors.white; // TODO(Kevin): Move to design system config

  final String text;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  const AppStyledText({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kBodyFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

  const AppStyledText.large({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kDisplayFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

  const AppStyledText.small({
    super.key,
    required this.text,
    this.fontSize = TypographyConstants.kSmallFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

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
