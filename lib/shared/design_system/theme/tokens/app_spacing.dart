import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
final class AppSpacing {
  final ScreenSizeType _screenType;
  const AppSpacing(this._screenType);

  static const double _kSuperSmall = 2.0;
  static const double _kExtraSmall = 4.0;
  static const double _kSmall = 8.0;
  static const double _kMedium = 16.0;
  static const double _kLarge = 24.0;
  static const double _kExtraLarge = 32.0;
  static const double _kSuperLarge = 48.0;

  static const ScreenSizeValue<double> _marginValue = ScreenSizeValue<double>(
    mobile: _kSmall,
    tablet: _kMedium,
    desktop: _kLarge,
  );

  static const ScreenSizeValue<double> _paddingValue = ScreenSizeValue<double>(
    mobile: _kExtraSmall,
    tablet: _kSmall,
    desktop: _kSmall,
  );

  static const ScreenSizeValue<double> _spacingValue = ScreenSizeValue<double>(
    mobile: _kExtraSmall,
    tablet: _kSmall,
    desktop: _kSmall,
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
