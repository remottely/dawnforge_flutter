import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

class AppStyledButton extends StatelessWidget {
  static const Color kStandardTextColor = Colors.white;

  static const Color kPrimaryBackgroundColor = Color.fromARGB(255, 118, 82, 78);

  static const double kButtonBorderRadius = 4.0;

  final String text;

  final VoidCallback onPressed;

  final Color backgroundColor;

  final double fontSize;

  const AppStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = TypographyConstants.kBodyFontSize,
  });

  const AppStyledButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = kPrimaryBackgroundColor,
    this.fontSize = TypographyConstants.kCaptionFontSize,
  });

  const AppStyledButton.transparent({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
    this.fontSize = TypographyConstants.kBodyFontSize,
  });

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
          color: kStandardTextColor,
          fontFamily: TypographyConstants.kPrimaryFontFamily,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
