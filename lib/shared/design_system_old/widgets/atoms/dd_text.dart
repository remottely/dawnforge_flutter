import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_typography.dart';
import 'package:dawnforge/shared/design_system_old/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDText extends StatelessWidget {
  final String text;
  final DFFontSizeType fontSizeType;
  final Color color;
  final TextAlign textAlign;

  const DDText.small({
    super.key,
    required this.text,
    this.color = DDDesignSystem.kTextColorDefault,
    this.textAlign = TextAlign.start,
  }) : fontSizeType = DFFontSizeType.small;

  const DDText.large({
    super.key,
    required this.text,
    this.color = DDDesignSystem.kTextColorDefault,
    this.textAlign = TextAlign.start,
  }) : fontSizeType = DFFontSizeType.display;

  @override
  Widget build(BuildContext context) {
    double fontSize = AppDesignSystem.of(
      context,
    ).typography.getFontSizeByType(fontSizeType);

    return Text(
      text,
      style: TextStyle(color: color, fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}
