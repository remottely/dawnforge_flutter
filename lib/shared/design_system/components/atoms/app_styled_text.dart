import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
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
    this.fontSize = DDDesignSystem.kTypographyBodyFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

  const AppStyledText.large({
    super.key,
    required this.text,
    this.fontSize = DDDesignSystem.kTypographyDisplayFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

  const AppStyledText.small({
    super.key,
    required this.text,
    this.fontSize = DDDesignSystem.kTypographySmallFontSize,
    this.color = _kStandardColor,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
        fontSize: fontSize,
      ),
      textAlign: textAlign,
    );
  }
}
