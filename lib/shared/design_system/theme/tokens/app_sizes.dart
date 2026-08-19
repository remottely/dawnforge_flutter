import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
final class AppSizes {
  final ScreenSizeType _screenType;
  const AppSizes(this._screenType);

  static const ScreenSizeValue<double> _slotSizeValue = ScreenSizeValue<double>(
    mobile: 52.0,
    tablet: 64.0,
    desktop: 64.0,
  );

  static const ScreenSizeValue<double> _equipmentSlotSizeValue =
      ScreenSizeValue<double>(mobile: 12.0, tablet: 18.0, desktop: 24.0);

  static const ScreenSizeValue<double> _actionButtonValue =
      ScreenSizeValue<double>(mobile: 50.0, tablet: 60.0, desktop: 60.0);

  static const ScreenSizeValue<double> _utilityButtonValue =
      ScreenSizeValue<double>(mobile: 40.0, tablet: 50.0, desktop: 50.0);

  double get slotSize => _slotSizeValue.get(_screenType);
  double get equipmentSlotSize => _equipmentSlotSizeValue.get(_screenType);
  double get actionButton => _actionButtonValue.get(_screenType);
  double get utilityButton => _utilityButtonValue.get(_screenType);
}
