import 'package:flutter/material.dart';

/// [AppRadioButton] responsible for providing styled radio buttons following game's visual theme
///
/// This component provides consistent radio button styling throughout the application,
/// supporting custom values and labels with proper state management.
///
/// Usage examples:
/// ```dart
/// AppRadioButton<String>(
///   value: 'option1',
///   group: selectedValue,
///   label: 'Option 1',
///   onChange: (value) => setState(() => selectedValue = value),
/// )
/// ```
///
/// Following CLAUDE.md patterns for Flutter StatelessWidget components
class AppRadioButton<T> extends StatelessWidget {
  // 1. Constantes de configuração
  /// Default border color for radio buttons
  static const Color kBorderColor = Colors.white;

  /// Default text color for labels
  static const Color kTextColor = Colors.white;

  /// Border width for radio button
  static const double kBorderWidth = 2.0;

  /// Size of the radio button indicator
  static const double kIndicatorSize = 8.0;

  /// Margin around the indicator
  static const double kIndicatorMargin = 2.0;

  /// Spacing between radio button and label
  static const double kLabelSpacing = 10.0;

  // 2. Propriedades da classe
  /// The value represented by this radio button
  final T value;

  /// The currently selected value in the group
  final T? group;

  /// Optional label text to display next to the radio button
  final String? label;

  /// Callback function when the radio button is selected
  final ValueChanged<T>? onChange;

  // 3. Construtor principal
  /// Creates a styled radio button with optional label
  const AppRadioButton({
    super.key,
    required this.value,
    this.group,
    this.label,
    this.onChange,
  });

  // 5. Método build
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

  // 6. Métodos privados auxiliares
  /// Creates the radio button indicator
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

  /// Creates the label text widget
  Widget _buildLabel() {
    return Text(label!, style: const TextStyle(color: kTextColor));
  }
}
