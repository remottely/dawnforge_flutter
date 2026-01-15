/// **Extension para acesso fácil ao OverlayDesignSystem**
import 'package:dawnforge/game/core/modules/overlay/design_system/overlay_design_system.dart';
import 'package:dawnforge/game/core/modules/overlay/design_system/overlay_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/widgets.dart';

extension OverlayDesignSystemExtension on BuildContext {
  OverlayDesignSystem get overlayDs => OverlayDesignSystem.of(this);

  OverlaySpacing get overlaySpacing => overlayDs.spacing;
  OverlaySizes get overlaySizes => overlayDs.sizes;
  OverlayTypography get overlayTypography => overlayDs.typography;
  OverlayScale get overlayScale => overlayDs.scale;
  OverlayConstraints get overlayConstraints => overlayDs.constraints;

  ScreenSizeInfo get overlayScreenSize => overlayDs.screenSize;
  
  bool get isOverlayPortrait => overlayScreenSize.isPortrait;
  bool get isOverlayLandscape => overlayScreenSize.isLandscape;

  bool get isOverlayMobile => overlayScreenSize.isMobile;
  bool get isOverlayTablet => overlayScreenSize.isTablet;
  bool get isOverlayDesktop => overlayScreenSize.isDesktop;

  EdgeInsets get overlaySafeArea => MediaQuery.of(this).padding;
  Size get overlayScreenDimensions => MediaQuery.of(this).size;

  double overlayWidth(double percentage) {
    return overlayScreenDimensions.width * percentage;
  }

  double overlayHeight(double percentage) {
    return overlayScreenDimensions.height * percentage;
  }

  T overlayValueByOrientation<T>({
    required T portrait,
    required T landscape,
  }) {
    return isOverlayPortrait ? portrait : landscape;
  }

  T overlayValueByScreenSize<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (overlayScreenSize.type) {
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