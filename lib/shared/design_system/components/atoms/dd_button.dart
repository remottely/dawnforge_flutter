import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double fontSize;

  const DDButton.text({
    required this.labelText,
    required this.onPressed,
    super.key,
  }) : backgroundColor = DDDesignSystem.kStandardDialogBackgroundColor,
       fontSize = DDDesignSystem.kTypographyBodyFontSize;

  const DDButton.elevated({
    required this.labelText,
    required this.onPressed,
    super.key,
  }) : backgroundColor = DDDesignSystem.kPrimaryBackgroundColor,
       fontSize = DDDesignSystem.kTypographyCaptionFontSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape: backgroundColor != DDDesignSystem.kStandardDialogBackgroundColor
            ? WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DDDesignSystem.kButtonBorderRadius,
                  ),
                ),
              )
            : null,
      ),
      onPressed: onPressed,
      child: Text(
        labelText,
        style: TextStyle(
          color: DDDesignSystem.kStandardTextColor,
          fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
