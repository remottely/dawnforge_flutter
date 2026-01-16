import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

@immutable
final class AppSpacing {
  final ScreenSizeType _screenType;
  const AppSpacing(this._screenType);

  static const double _superSmall = 2.0;
  static const double _extraSmall = 4.0;
  static const double _small = 8.0;
  static const double _medium = 16.0;
  static const double _large = 24.0;
  static const double _extraLarge = 32.0;
  static const double _superLarge = 48.0;

  static const _marginValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _large,
  );

  static const _paddingValue = ScreenSizeValue<double>(
    mobile: _extraSmall,
    tablet: _small,
    desktop: _small,
  );

  static const _spacingValue = ScreenSizeValue<double>(
    mobile: _extraSmall,
    tablet: _small,
    desktop: _small,
  );

  double get kSpacingSuperSmall => 4.0;
  double get kSpacingExtraSmall => 8.0;
  //  double get kSpacingSmall => 12.0;
  //  double get kSpacingMedium => 16.0;
  //  double get kSpacingMediumLarge => 20.0;
  double get kSpacingLarge => 24.0;
  double get kSpacingExtraLarge => 32.0;
  //  double get kSpacingSuperLarge => 48.0;

  double get margin => _marginValue.get(_screenType);
  double get padding => _paddingValue.get(_screenType);
  double get spacing => _spacingValue.get(_screenType);
}
