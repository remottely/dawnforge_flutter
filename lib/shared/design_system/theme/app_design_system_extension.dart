import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

extension AppDesignSystemExtension on BuildContext {
  AppDesignSystem get ds => AppDesignSystem.of(this);

  AppSpacing get spacing => ds.spacing;
  AppRadius get radius => ds.radius;
  AppSizes get sizes => ds.sizes;

  ScreenSizeInfo get screenSize => ds.screenSize;
  ScreenSizeType get screenType => ds.screenSize.type;

  bool get isMobile => screenSize.isMobile;
  bool get isTablet => screenSize.isTablet;
  bool get isDesktop => screenSize.isDesktop;
  bool get isPortrait => screenSize.isPortrait;
  bool get isLandscape => screenSize.isLandscape;

  T responsive<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    final value = ScreenSizeValue<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return value.get(screenType);
  }

  T responsiveOr<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return responsive(
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }
}
