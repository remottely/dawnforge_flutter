import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';

class AppRadioButton<T> extends StatelessWidget {
  static const Color _kBorderColor = Colors.white;
  static const Color _kTextColor = Colors.white;
  static const double _kBorderWidth = 2.0;
  static const double _kIndicatorSize = 8.0;
  static const double _kIndicatorMargin = 2.0;

  final T value;
  final T? group;
  final String? label;
  final ValueChanged<T>? onChange;

  const AppRadioButton({
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
          _buildRadioIndicator(),
          if (label != null) ...[
            const SizedBox(width: DDDesignSystem.kSpacingExtraSmall),
            _buildLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _kBorderColor, width: _kBorderWidth),
      ),
      child: Container(
        width: _kIndicatorSize,
        height: _kIndicatorSize,
        margin: const EdgeInsets.all(_kIndicatorMargin),
        color: value == group ? _kBorderColor : Colors.transparent,
      ),
    );
  }

  Widget _buildLabel() {
    return Text(label!, style: const TextStyle(color: _kTextColor));
  }
}
