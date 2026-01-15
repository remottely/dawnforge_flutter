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

  static const _logoValue = ScreenSizeValue<double>(
    mobile: _large,
    tablet: _extraLarge,
    desktop: _superLarge,
  );
  static const _contentValue = ScreenSizeValue<double>(
    mobile: _medium,
    tablet: _large,
    desktop: _extraLarge,
  );
  static const _screenValue = ScreenSizeValue<double>(
    mobile: _medium,
    tablet: _large,
    desktop: _extraLarge,
  );
  static const _textFormFieldValue = ScreenSizeValue<double>(
    mobile: _extraSmall,
    tablet: _small,
    desktop: _small,
  );
  static const _authFormContentValue = ScreenSizeValue<double>(
    mobile: _large,
    tablet: _extraLarge,
    desktop: _superLarge,
  );
  static const _authFormFieldsValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );

  double get logo => _logoValue.get(_screenType);
  double get content => _contentValue.get(_screenType);
  double get screen => _screenValue.get(_screenType);
  double get textFormField => _textFormFieldValue.get(_screenType);
  double get authFormContent => _authFormContentValue.get(_screenType);
  double get authFormFields => _authFormFieldsValue.get(_screenType);
}

@immutable
final class AppRadius {
  final ScreenSizeType _screenType;
  const AppRadius(this._screenType);

  static const double _small = 4.0;
  static const double _medium = 8.0;
  static const double _large = 16.0;

  static const _textFormFieldValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );
  static const _buttonValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );

  double get textFormField => _textFormFieldValue.get(_screenType);
  double get button => _buttonValue.get(_screenType);
}

@immutable
final class AppSizes {
  final ScreenSizeType _screenType;
  const AppSizes(this._screenType);

  static const _iconSmallValue = ScreenSizeValue<double>(
    mobile: 12.0,
    tablet: 16.0,
    desktop: 24.0,
  );
  static const _iconMediumValue = ScreenSizeValue<double>(
    mobile: 16.0,
    tablet: 24.0,
    desktop: 32.0,
  );
  static const _iconLargeValue = ScreenSizeValue<double>(
    mobile: 24.0,
    tablet: 32.0,
    desktop: 40.0,
  );

  double get minTouchTarget => 44.0;
  double get buttonHeight => 48.0;

  double get avatarSmall => 40.0;
  double get avatarMedium => 56.0;

  double get iconSmall => _iconSmallValue.get(_screenType);
  double get iconMedium => _iconMediumValue.get(_screenType);
  double get iconLarge => _iconLargeValue.get(_screenType);
}
