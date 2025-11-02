import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  const DDText.small({
    super.key,
    required this.text,
    this.color = DDDesignSystem.kTextColor,
    this.textAlign = TextAlign.start,
  }) : fontSize = DDDesignSystem.kTypographySmallFontSize;

  const DDText.large({
    super.key,
    required this.text,
    this.color = DDDesignSystem.kTextColor,
    this.textAlign = TextAlign.start,
  }) : fontSize = DDDesignSystem.kTypographyDisplayFontSize;

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
