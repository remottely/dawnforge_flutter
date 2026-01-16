import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system_old/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final DFFontSizeType fontSizeType;

  const DDButton.text({
    required this.labelText,
    required this.onPressed,
    super.key,
  }) : backgroundColor = DDDesignSystem.kDialogBackgroundColor,
       fontSizeType = DFFontSizeType.body;

  const DDButton.elevated({
    required this.labelText,
    required this.onPressed,
    super.key,
  }) : backgroundColor = DDDesignSystem.kPrimaryBackgroundColor,
       fontSizeType = DFFontSizeType.caption;

  @override
  Widget build(BuildContext context) {
    double fontSize = AppDesignSystem.of(
      context,
    ).typography.getFontSizeByType(fontSizeType);

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        shape: backgroundColor != DDDesignSystem.kDialogBackgroundColor
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
      child: Text(labelText, style: TextStyle(fontSize: fontSize)),
    );
  }
}
