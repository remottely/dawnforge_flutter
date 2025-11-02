import 'package:flutter/material.dart';

final class DDDesignSystem {
  DDDesignSystem._();

  /// Typography constants
  static const String kTypographyPrimaryFontFamily = 'Normal';
  static const double kTypographyTinyFontSize = 12.0;
  static const double kTypographySmallFontSize = 14.0;
  static const double kTypographyCaptionFontSize = 16.0;
  static const double kTypographyBodyFontSize = 20.0;
  static const double kTypographyHeadlineFontSize = 24.0;
  static const double kTypographyDisplayFontSize = 32.0;

  /// Spacing constants
  static const double kSpacingSuperSmall = 4.0;
  static const double kSpacingExtraSmall = 8.0;
  // static const double kSpacingSmall = 12.0;
  // static const double kSpacingMedium = 16.0;
  // static const double kSpacingMediumLarge = 20.0;
  static const double kSpacingLarge = 24.0;
  static const double kSpacingExtraLarge = 32.0;
  // static const double kSpacingSuperLarge = 48.0;

  /// Borders constants
  static const double _kBorderRadiusSmall = 4.0;
  // static const double kBorderRadiusMedium = 8.0;
  // static const double kBorderRadiusLarge = 12.0;

  // /// Elevation constants
  // static const double kElevationSmall = 2.0;
  // static const double kElevationMedium = 4.0;
  // static const double kElevationLarge = 8.0;

  /// Colors constants
  static const Color kTextColor = Colors.white;
  static const Color kPrimaryBackgroundColor = Color.fromARGB(255, 118, 82, 78);

  static const Color kBorderColor = Colors.white;

  /// Components
  static const double kButtonBorderRadius = _kBorderRadiusSmall;
  static const double kRadioButtonDimension = 8.0;
  static const Color kDialogBackgroundColor = Colors.transparent;
}
