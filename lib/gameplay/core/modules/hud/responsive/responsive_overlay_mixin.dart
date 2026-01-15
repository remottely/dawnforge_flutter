import 'package:dawnforge/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:flutter/widgets.dart';

/// Mixin que fornece funcionalidades responsivas para overlays
mixin ResponsiveOverlayMixin {
  /// Obtém o tamanho da tela
  MediaQueryData _getMediaQuery(BuildContext context) => MediaQuery.of(context);

  /// Obtém o tamanho da tela
  Size getScreenDimensions(BuildContext context) =>
      _getMediaQuery(context).size;

  /// Obtém safe area insets
  EdgeInsets getSafeAreaInsets(BuildContext context) =>
      _getMediaQuery(context).padding;

  /// Obtém o tamanho da tela atual
  ScreenSizeType getScreenSizeType(BuildContext context) {
    final width = getScreenDimensions(context).width;
    return OverlayResponsiveConfig.getScreenSizeType(width);
  }

  /// Obtém a orientação da tela atual
  ScreenOrientation getOrientation(BuildContext context) {
    final size = getScreenDimensions(context);
    return OverlayResponsiveConfig.getOrientation(size);
  }

  /// Verifica se está em modo portrait
  bool isPortrait(BuildContext context) =>
      getOrientation(context) == ScreenOrientation.portrait;

  /// Verifica se está em modo landscape
  bool isLandscape(BuildContext context) =>
      getOrientation(context) == ScreenOrientation.landscape;

  /// Verifica se é uma tela pequena (mobile)
  bool isMobileScreen(BuildContext context) =>
      getScreenSizeType(context) == ScreenSizeType.mobile;

  /// Verifica se é uma tela média (tablet)
  bool isTabletScreen(BuildContext context) =>
      getScreenSizeType(context) == ScreenSizeType.tablet;

  /// Verifica se é uma tela grande (desktop)
  bool isDesktopScreen(BuildContext context) =>
      getScreenSizeType(context) == ScreenSizeType.desktop;

  /// Obtém margem responsiva
  double getResponsiveMargin(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getMargin(screenSize);
  }

  /// Obtém padding responsivo
  double getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getPadding(screenSize);
  }

  /// Obtém tamanho de fonte base responsivo
  double getResponsiveBaseFontSize(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getBaseFontSize(screenSize);
  }

  /// Obtém tamanho de fonte de título responsivo
  double getResponsiveTitleFontSize(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getTitleFontSize(screenSize);
  }

  /// Obtém tamanho de slot responsivo
  double getResponsiveSlotSize(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getSlotSize(screenSize);
  }

  /// Obtém tamanho de slot de equipamento responsivo
  double getResponsiveEquipmentSlotSize(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getEquipmentSlotSize(screenSize);
  }

  /// Obtém espaçamento responsivo
  double getResponsiveSpacing(BuildContext context) {
    final screenSize = getScreenSizeType(context);
    return OverlayResponsiveConfig.getSpacing(screenSize);
  }

  /// Obtém escala responsiva
  double getResponsiveScale(BuildContext context) {
    final width = getScreenDimensions(context).width;
    return OverlayResponsiveConfig.getScale(width);
  }

  /// Calcula largura responsiva baseada em percentual da tela
  double getResponsiveWidth(BuildContext context, double percentage) {
    final screenWidth = getScreenDimensions(context).width;
    return screenWidth * percentage;
  }

  /// Calcula altura responsiva baseada em percentual da tela
  double getResponsiveHeight(BuildContext context, double percentage) {
    final screenHeight = getScreenDimensions(context).height;
    return screenHeight * percentage;
  }

  /// Retorna valor baseado na orientação
  T valueByOrientation<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  /// Retorna valor baseado no tamanho da tela
  T valueByScreenSize<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSizeType(context);
    switch (screenSize) {
      case ScreenSizeType.mobile:
        return mobile;
      case ScreenSizeType.tablet:
        return tablet ?? mobile;
      case ScreenSizeType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Calcula posicionamento responsivo
  Offset getResponsivePosition(
    BuildContext context, {
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final size = getScreenDimensions(context);
    final safeArea = getSafeAreaInsets(context);

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
