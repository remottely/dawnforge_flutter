import 'package:dawnforge/shared/design_system_old/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;

  const DDText.small({
    super.key,
    required this.text,
    this.color,
    this.textAlign = TextAlign.start,
  }) : fontSize = DDDesignSystem.kTypographyFontSizeSmall;

  const DDText.large({
    super.key,
    required this.text,
    this.color,
    this.textAlign = TextAlign.start,
  }) : fontSize = DDDesignSystem.kTypographyFontSizeDisplay;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}
