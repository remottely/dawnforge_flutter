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


  T responsive<T>({required T mobile, required T tablet, required T desktop}) {
    final value = ScreenSizeValue<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return value.get(screenType);
  }

  T responsiveOr<T>({required T mobile, T? tablet, T? desktop}) {
    return responsive(
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }

  OverlayConstraints get overlayConstraints => ds.overlayConstraints;

  EdgeInsets get overlaySafeArea => MediaQuery.of(this).padding;
  Size get overlayScreenDimensions => MediaQuery.of(this).size;

  double overlayWidth(double percentage) {
    return overlayScreenDimensions.width * percentage;
  }

  double overlayHeight(double percentage) {
    return overlayScreenDimensions.height * percentage;
  }

  T overlayValueByOrientation<T>({required T portrait, required T landscape}) {
    return ds.screenSize.isPortrait ? portrait : landscape;
  }

  T overlayValueByScreenSize<T>({required T mobile, T? tablet, T? desktop}) {
    return switch (ds.screenSize.type) {
      ScreenSizeType.mobile => mobile,
      ScreenSizeType.tablet => tablet ?? mobile,
      ScreenSizeType.desktop => desktop ?? tablet ?? mobile,
    };
  }

  Offset overlayPosition({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final size = overlayScreenDimensions;
    final safeArea = overlaySafeArea;

    double x = 0;
    double y = 0;

    if (left != null) {
      x = left + safeArea.left;
    } else if (right != null) {
      x = size.width - right - safeArea.right;
    }

    if (top != null) {
      y = top + safeArea.top;
    } else if (bottom != null) {
      y = size.height - bottom - safeArea.bottom;
    }

    return Offset(x, y);
  }
}
