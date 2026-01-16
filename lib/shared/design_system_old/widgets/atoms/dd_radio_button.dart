import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system_old/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDRadioButton<T> extends StatelessWidget {
  final T value;
  final T? group;
  final String? label;
  final ValueChanged<T>? onChange;

  const DDRadioButton({
    super.key,
    required this.value,
    this.group,
    this.label,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppDesignSystem.of(context).spacing;

    return InkWell(
      onTap: () => onChange?.call(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(context),
          if (label != null) ...[
            SizedBox(width: spacing.kSpacingExtraSmall),
            _buildLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: DDDesignSystem.kBorderColor,
          width: DDDesignSystem.kButtonBorderRadius,
        ),
      ),
      child: Container(
        width: DDDesignSystem.kRadioButtonDimension,
        height: DDDesignSystem.kRadioButtonDimension,
        margin: EdgeInsets.all(
          AppDesignSystem.of(context).spacing.kSpacingSuperSmall,
        ),
        color: value == group
            ? DDDesignSystem.kBorderColor
            : Colors.transparent,
      ),
    );
  }

  Widget _buildLabel() {
    return Text(label!, style: TextStyle(color: Colors.white));
  }
}
