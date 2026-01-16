import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

@immutable
final class AppScale {
  final ScreenSizeType _screenType;
  const AppScale(this._screenType);

  static const _scaleValue = ScreenSizeValue<double>(
    mobile: 0.85,
    tablet: 1.0,
    desktop: 1.15,
  );

  double get scale => _scaleValue.get(_screenType);
}
