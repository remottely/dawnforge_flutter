import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
final class AppScale {
  final ScreenSizeType _screenType;
  const AppScale(this._screenType);

  static const ScreenSizeValue<double> _scaleValue = ScreenSizeValue<double>(
    mobile: 0.85,
    tablet: 1.0,
    desktop: 1.15,
  );

  double get scale => _scaleValue.get(_screenType);
}
