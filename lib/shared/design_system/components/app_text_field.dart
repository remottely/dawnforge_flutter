import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/material.dart';

final class AppTextField extends StatelessWidget {
  final String labelText;
  final bool isPassword;

  const AppTextField({
    super.key,
    required this.labelText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppDesignSystem.of(context);
    final spacing = theme.spacing;
    final radius = theme.radius;

    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(radius.textFormField),
          ),
          gapPadding: spacing.textFormField,
        ),
      ),
      obscureText: isPassword,
    );
  }
}
