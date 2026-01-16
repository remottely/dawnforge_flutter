import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

enum DFFontSizeType { small, body, caption, display }

@immutable
final class AppTypography {
  final ScreenSizeType _screenType;
  const AppTypography(this._screenType);

  static const ScreenSizeValue<double> _fontSizeTiny = ScreenSizeValue<double>(
    mobile: 10.0,
    tablet: 12.0,
    desktop: 14.0,
  );
  static const ScreenSizeValue<double> _fontSizeSmall = ScreenSizeValue<double>(
    mobile: 12.0,
    tablet: 14.0,
    desktop: 16.0,
  );

  static const ScreenSizeValue<double> _fontSizeCaption =
      ScreenSizeValue<double>(mobile: 14.0, tablet: 16.0, desktop: 18.0);
  static const ScreenSizeValue<double> _fontSizeBody = ScreenSizeValue<double>(
    mobile: 18.0,
    tablet: 20.0,
    desktop: 22.0,
  );
  static const ScreenSizeValue<double> _fontSizeHeadline =
      ScreenSizeValue<double>(mobile: 22.0, tablet: 24.0, desktop: 26.0);
  static const ScreenSizeValue<double> _fontSizeDisplay =
      ScreenSizeValue<double>(mobile: 30.0, tablet: 32.0, desktop: 34.0);

  static const ScreenSizeValue<double> _baseFontSizeValue =
      ScreenSizeValue<double>(mobile: 10.0, tablet: 11.0, desktop: 12.0);

  static const ScreenSizeValue<double> _titleFontSizeValue =
      ScreenSizeValue<double>(mobile: 14.0, tablet: 16.0, desktop: 18.0);

  double get fontSizeTiny => _fontSizeTiny.get(_screenType);
  double get fontSizeSmall => _fontSizeSmall.get(_screenType);
  double get fontSizeCaption => _fontSizeCaption.get(_screenType);
  double get fontSizeBody => _fontSizeBody.get(_screenType);
  double get fontSizeHeadline => _fontSizeHeadline.get(_screenType);
  double get fontSizeDisplay => _fontSizeDisplay.get(_screenType);

  double get baseFontSize => _baseFontSizeValue.get(_screenType);
  double get titleFontSize => _titleFontSizeValue.get(_screenType);

  getFontSizeByType(DFFontSizeType type) {
    return switch (type) {
      DFFontSizeType.small => fontSizeSmall,
      DFFontSizeType.body => fontSizeBody,
      DFFontSizeType.caption => fontSizeCaption,
      DFFontSizeType.display => fontSizeDisplay,
    };
  }
}
