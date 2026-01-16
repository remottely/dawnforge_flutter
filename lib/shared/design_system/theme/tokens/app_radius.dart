import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

@immutable
final class AppRadius {
  final ScreenSizeType _screenType;
  const AppRadius(this._screenType);

  static const double _small = 4.0;
  static const double _medium = 8.0;
  static const double _large = 12.0;

  static const _textFormFieldValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );
  static const _buttonValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _small,
    desktop: _medium,
  );

  double get kButtonBorderRadius => _small;

  double get textFormField => _textFormFieldValue.get(_screenType);
  double get button => _buttonValue.get(_screenType);
}
