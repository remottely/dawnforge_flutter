import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

@immutable
final class AppRadius {
  final ScreenSizeType _screenType;
  const AppRadius(this._screenType);

  static const double _kSmall = 4.0;
  static const double _kMedium = 8.0;
  static const double _kLarge = 12.0;

  static const ScreenSizeValue<double> _textFormFieldValue = ScreenSizeValue<double>(
    mobile: _kSmall,
    tablet: _kMedium,
    desktop: _kMedium,
  );
  static const ScreenSizeValue<double> _buttonValue = ScreenSizeValue<double>(
    mobile: _kSmall,
    tablet: _kSmall,
    desktop: _kMedium,
  );

  double get kButtonBorderRadius => _kSmall;

  double get textFormField => _textFormFieldValue.get(_screenType);
  double get button => _buttonValue.get(_screenType);
}
