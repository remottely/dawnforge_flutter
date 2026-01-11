import 'package:dawnforge/shared/design_system/dd_design_system.dart';
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
    return InkWell(
      onTap: () {
        onChange?.call(value);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(),
          if (label != null) ...[
            const SizedBox(width: DDDesignSystem.kSpacingExtraSmall),
            _buildLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
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
        margin: const EdgeInsets.all(DDDesignSystem.kSpacingSuperSmall),
        color: value == group
            ? DDDesignSystem.kBorderColor
            : Colors.transparent,
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      label!,
      style: const TextStyle(color: DDDesignSystem.kTextColor),
    );
  }
}
