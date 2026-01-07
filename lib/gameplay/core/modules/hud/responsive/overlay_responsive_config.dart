import 'package:flutter/widgets.dart';

/// Enumeração de breakpoints para diferentes tamanhos de tela
enum ScreenSize {
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
  static const Map<ScreenSize, double> kMargins = {
    ScreenSize.mobile: 8.0,
    ScreenSize.tablet: 16.0,
    ScreenSize.desktop: 24.0,
  };

  static const Map<ScreenSize, double> kPaddings = {
    ScreenSize.mobile: 4.0,
    ScreenSize.tablet: 6.0,
    ScreenSize.desktop: 8.0,
  };

  // Font sizes responsivos
  static const Map<ScreenSize, double> kBaseFontSize = {
    ScreenSize.mobile: 10.0,
    ScreenSize.tablet: 11.0,
    ScreenSize.desktop: 12.0,
  };

  static const Map<ScreenSize, double> kTitleFontSize = {
    ScreenSize.mobile: 14.0,
    ScreenSize.tablet: 16.0,
    ScreenSize.desktop: 18.0,
  };

  // Icon/slot sizes responsivos
  static const Map<ScreenSize, double> kSlotSize = {
    ScreenSize.mobile: 40.0,
    ScreenSize.tablet: 52.0,
    ScreenSize.desktop: 64.0,
  };

  // Equipment slot sizes (menores que inventory slots)
  static const Map<ScreenSize, double> kEquipmentSlotSize = {
    ScreenSize.mobile: 12.0,
    ScreenSize.tablet: 18.0,
    ScreenSize.desktop: 24.0,
  };

  static const Map<ScreenSize, double> kSpacing = {
    ScreenSize.mobile: 4.0,
    ScreenSize.tablet: 6.0,
    ScreenSize.desktop: 8.0,
  };

  /// Determina o tamanho da tela baseado na largura
  static ScreenSize getScreenSize(double width) {
    if (width < kMobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < kTabletBreakpoint) {
      return ScreenSize.tablet;
    }
    return ScreenSize.desktop;
  }

  /// Determina a orientação da tela
  static ScreenOrientation getOrientation(Size size) {
    return size.width > size.height
        ? ScreenOrientation.landscape
        : ScreenOrientation.portrait;
  }

  /// Obtém a margem responsiva
  static double getMargin(ScreenSize size) {
    return kMargins[size] ?? kMargins[ScreenSize.tablet]!;
  }

  /// Obtém o padding responsivo
  static double getPadding(ScreenSize size) {
    return kPaddings[size] ?? kPaddings[ScreenSize.tablet]!;
  }

  /// Obtém o tamanho de fonte base responsivo
  static double getBaseFontSize(ScreenSize size) {
    return kBaseFontSize[size] ?? kBaseFontSize[ScreenSize.tablet]!;
  }

  /// Obtém o tamanho de fonte de título responsivo
  static double getTitleFontSize(ScreenSize size) {
    return kTitleFontSize[size] ?? kTitleFontSize[ScreenSize.tablet]!;
  }

  /// Obtém o tamanho de slot responsivo
  static double getSlotSize(ScreenSize size) {
    return kSlotSize[size] ?? kSlotSize[ScreenSize.tablet]!;
  }

  /// Obtém o tamanho de slot de equipamento responsivo (menor)
  static double getEquipmentSlotSize(ScreenSize size) {
    return kEquipmentSlotSize[size] ?? kEquipmentSlotSize[ScreenSize.tablet]!;
  }

  /// Obtém o espaçamento responsivo
  static double getSpacing(ScreenSize size) {
    return kSpacing[size] ?? kSpacing[ScreenSize.tablet]!;
  }

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
    ScreenSize? screenSize,
  }) {
    final baseConstraints =
        kOverlayConstraints[overlayId] ??
        const BoxConstraints(minWidth: 200, maxWidth: 400);

    // Ajusta constraints para mobile (reduz 15%)
    if (screenSize == ScreenSize.mobile) {
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
