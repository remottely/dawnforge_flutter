import 'package:flutter/widgets.dart';

/// Enumeração de breakpoints para diferentes tamanhos de tela
enum ScreenSizeType {
  mobile, // Mobile (portrait and landscape)
  tablet, // Tablet
  desktop, // Desktop/Large screens
}

/// Enumeração de orientação de tela
enum ScreenOrientation { portrait, landscape }

/// Configuração responsiva para overlays
class OverlayResponsiveConfig {
  // Breakpoints (simplificado para 3 níveis)
  static const double kMobileBreakpoint = 768; // Até 768px = mobile
  static const double kTabletBreakpoint = 1280; // 768-1280px = tablet

  // Margins e paddings responsivos
  static const Map<ScreenSizeType, double> kMargins = {
    ScreenSizeType.mobile: 8.0,
    ScreenSizeType.tablet: 16.0,
    ScreenSizeType.desktop: 24.0,
  };

  static const Map<ScreenSizeType, double> kPaddings = {
    ScreenSizeType.mobile: 4.0,
    ScreenSizeType.tablet: 6.0,
    ScreenSizeType.desktop: 8.0,
  };

  // Font sizes responsivos
  static const Map<ScreenSizeType, double> kBaseFontSize = {
    ScreenSizeType.mobile: 10.0,
    ScreenSizeType.tablet: 11.0,
    ScreenSizeType.desktop: 12.0,
  };

  static const Map<ScreenSizeType, double> kTitleFontSize = {
    ScreenSizeType.mobile: 14.0,
    ScreenSizeType.tablet: 16.0,
    ScreenSizeType.desktop: 18.0,
  };

  // Icon/slot sizes responsivos
  static const Map<ScreenSizeType, double> kSlotSize = {
    ScreenSizeType.mobile: 52.0,
    ScreenSizeType.tablet: 64.0,
    ScreenSizeType.desktop: 64.0,
  };

  // Equipment slot sizes (menores que inventory slots)
  static const Map<ScreenSizeType, double> kEquipmentSlotSize = {
    ScreenSizeType.mobile: 12.0,
    ScreenSizeType.tablet: 18.0,
    ScreenSizeType.desktop: 24.0,
  };

  static const Map<ScreenSizeType, double> kSpacing = {
    ScreenSizeType.mobile: 4.0,
    ScreenSizeType.tablet: 6.0,
    ScreenSizeType.desktop: 8.0,
  };

  /// Determina o tamanho da tela baseado na largura
  static ScreenSizeType getScreenSizeType(double width) {
    if (width < kMobileBreakpoint) {
      return ScreenSizeType.mobile;
    } else if (width < kTabletBreakpoint) {
      return ScreenSizeType.tablet;
    }
    return ScreenSizeType.desktop;
  }

  /// Determina a orientação da tela
  static ScreenOrientation getOrientation(Size size) {
    return size.width > size.height
        ? ScreenOrientation.landscape
        : ScreenOrientation.portrait;
  }

  /// Obtém a margem responsiva
  static double getMargin(ScreenSizeType size) =>
      kMargins[size] ?? kMargins[ScreenSizeType.tablet]!;

  /// Obtém o padding responsivo
  static double getPadding(ScreenSizeType size) =>
      kPaddings[size] ?? kPaddings[ScreenSizeType.tablet]!;

  /// Obtém o tamanho de fonte base responsivo
  static double getBaseFontSize(ScreenSizeType size) =>
      kBaseFontSize[size] ?? kBaseFontSize[ScreenSizeType.tablet]!;

  /// Obtém o tamanho de fonte de título responsivo
  static double getTitleFontSize(ScreenSizeType size) =>
      kTitleFontSize[size] ?? kTitleFontSize[ScreenSizeType.tablet]!;

  /// Obtém o tamanho de slot responsivo
  static double getSlotSize(ScreenSizeType size) =>
      kSlotSize[size] ?? kSlotSize[ScreenSizeType.tablet]!;

  /// Obtém o tamanho de slot de equipamento responsivo (menor)
  static double getEquipmentSlotSize(ScreenSizeType size) =>
      kEquipmentSlotSize[size] ?? kEquipmentSlotSize[ScreenSizeType.tablet]!;

  /// Obtém o espaçamento responsivo
  static double getSpacing(ScreenSizeType size) =>
      kSpacing[size] ?? kSpacing[ScreenSizeType.tablet]!;

  /// Calcula escala baseada na largura da tela
  static double getScale(double width) {
    if (width < kMobileBreakpoint) {
      return 0.85; // Mobile: menor
    } else if (width < kTabletBreakpoint) {
      return 1.0; // Tablet: normal
    }
    return 1.15; // Desktop: maior
  }

  // Constraints simplificados para overlays (apenas width, height automático)
  static const Map<String, BoxConstraints> kOverlayConstraints = {
    'equipment': BoxConstraints(minWidth: 100, maxWidth: 200),
    'inventory': BoxConstraints(minWidth: 200, maxWidth: 550),
    'tutorial_inputs': BoxConstraints(minWidth: 300, maxWidth: 500),
    'mobile_inputs': BoxConstraints(
      minWidth: double.infinity,
      maxWidth: double.infinity,
      minHeight: double.infinity,
      maxHeight: double.infinity,
    ),
    'joystick_actions': BoxConstraints(
      minWidth: double.infinity,
      maxWidth: double.infinity,
      minHeight: double.infinity,
      maxHeight: double.infinity,
    ),
  };

  /// Obtém constraints para um overlay específico
  static BoxConstraints getOverlayConstraints(
    String overlayId, {
    ScreenSizeType? screenSize,
  }) {
    final baseConstraints =
        kOverlayConstraints[overlayId] ??
        const BoxConstraints(minWidth: 200, maxWidth: 400);

    // Ajusta constraints para mobile (reduz 15%)
    if (screenSize == ScreenSizeType.mobile) {
      return BoxConstraints(
        minWidth: baseConstraints.minWidth * 0.85,
        maxWidth: baseConstraints.maxWidth * 0.85,
        minHeight: baseConstraints.minHeight,
        maxHeight: baseConstraints.maxHeight,
      );
    }

    return baseConstraints;
  }
}
