import 'package:darkness_dungeon/app/design_system/dd_design_system_config.dart';
import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:flutter/material.dart';

class AppStyledButton extends StatelessWidget {
  static const Color _kStandardTextColor =
      Colors.white; // TODO(Kevin): Move to design system config
  static const Color _kPrimaryBackgroundColor = Color.fromARGB(
    255,
    118,
    82,
    78,
  ); // TODO(Kevin): Move to design system config
  static const double _kButtonBorderRadius =
      4.0; // TODO(Kevin): Move to design system config

  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double fontSize;

  const AppStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = DDDesignSystemConfig.kStandardDialogBackgroundColor,
    this.fontSize = TypographyConstants.kBodyFontSize,
  });

  const AppStyledButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = _kPrimaryBackgroundColor,
    this.fontSize = TypographyConstants.kCaptionFontSize,
  });

  const AppStyledButton.transparent({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = DDDesignSystemConfig.kStandardDialogBackgroundColor,
    this.fontSize = TypographyConstants.kBodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape:
            backgroundColor !=
                DDDesignSystemConfig.kStandardDialogBackgroundColor
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
          color: _kStandardTextColor,
          fontFamily: TypographyConstants.kPrimaryFontFamily,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
