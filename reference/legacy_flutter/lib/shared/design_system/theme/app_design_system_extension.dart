import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

extension AppDesignSystemExtension on BuildContext {
  AppDesignSystem get _ds => AppDesignSystem.of(this);

  Size get screenSize => MediaQuery.of(this).size;

  T responsive<T>({required T mobile, required T tablet, required T desktop}) {
    final value = ScreenSizeValue<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return value.get(_ds.screenSize.type);
  }

  T responsiveOr<T>({required T mobile, T? tablet, T? desktop}) {
    return responsive(
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }

  T overlayValueByOrientation<T>({required T portrait, required T landscape}) {
    return _ds.screenSize.isPortrait ? portrait : landscape;
  }

  T overlayValueByScreenSize<T>({required T mobile, T? tablet, T? desktop}) {
    return switch (_ds.screenSize.type) {
      ScreenSizeType.mobile => mobile,
      ScreenSizeType.tablet => tablet ?? mobile,
      ScreenSizeType.desktop => desktop ?? tablet ?? mobile,
    };
  }
}
