import 'package:flutter/material.dart';

class AppRadioButton<T> extends StatelessWidget {
  static const Color kBorderColor = Colors.white;

  static const Color kTextColor = Colors.white;

  static const double kBorderWidth = 2.0;

  static const double kIndicatorSize = 8.0;

  static const double kIndicatorMargin = 2.0;

  static const double kLabelSpacing = 10.0;

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
            const SizedBox(width: kLabelSpacing),
            _buildLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor, width: kBorderWidth),
      ),
      child: Container(
        width: kIndicatorSize,
        height: kIndicatorSize,
        margin: const EdgeInsets.all(kIndicatorMargin),
        color: value == group ? kBorderColor : Colors.transparent,
      ),
    );
  }

  Widget _buildLabel() {
    return Text(label!, style: const TextStyle(color: kTextColor));
  }
}
