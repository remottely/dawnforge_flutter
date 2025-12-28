import 'package:flutter/widgets.dart';

/// Enumeração de breakpoints para diferentes tamanhos de tela
enum ScreenSize {
  small, // Mobile portrait
  medium, // Mobile landscape / Tablet portrait
  large, // Tablet landscape / Desktop
  extraLarge, // Large desktop
}

/// Enumeração de orientação de tela
enum ScreenOrientation {
  portrait,
  landscape,
}

/// Configuração responsiva para overlays
class OverlayResponsiveConfig {
  // Breakpoints
  static const double kSmallBreakpoint = 600;
  static const double kMediumBreakpoint = 960;
  static const double kLargeBreakpoint = 1280;

  // Margins e paddings responsivos
  static const Map<ScreenSize, double> kMargins = {
    ScreenSize.small: 8.0,
    ScreenSize.medium: 12.0,
    ScreenSize.large: 16.0,
    ScreenSize.extraLarge: 20.0,
  };

  static const Map<ScreenSize, double> kPaddings = {
    // ScreenSize.small: 8.0,
    // ScreenSize.medium: 12.0,
    // ScreenSize.large: 16.0,
    // ScreenSize.extraLarge: 20.0,
    ScreenSize.small: 2.0,
    ScreenSize.medium: 4.0,
    ScreenSize.large: 6.0,
    ScreenSize.extraLarge: 8.0,
  };

  // Font sizes responsivos
  static const Map<ScreenSize, double> kBaseFontSize = {
    ScreenSize.small: 9.0,
    ScreenSize.medium: 10.0,
    ScreenSize.large: 11.0,
    ScreenSize.extraLarge: 12.0,
  };

  static const Map<ScreenSize, double> kTitleFontSize = {
    ScreenSize.small: 14.0,
    ScreenSize.medium: 16.0,
    ScreenSize.large: 18.0,
    ScreenSize.extraLarge: 20.0,
  };

  // Icon/slot sizes responsivos
  static const Map<ScreenSize, double> kSlotSize = {
    ScreenSize.small: 36.0,
    ScreenSize.medium: 40.0,
    ScreenSize.large: 44.0,
    ScreenSize.extraLarge: 48.0,
  };

  static const Map<ScreenSize, double> kSpacing = {
    ScreenSize.small: 4.0,
    ScreenSize.medium: 6.0,
    ScreenSize.large: 8.0,
    ScreenSize.extraLarge: 10.0,
  };

  /// Determina o tamanho da tela baseado na largura
  static ScreenSize getScreenSize(double width) {
    if (width < kSmallBreakpoint) {
      return ScreenSize.small;
    } else if (width < kMediumBreakpoint) {
      return ScreenSize.medium;
    } else if (width < kLargeBreakpoint) {
      return ScreenSize.large;
    }
    return ScreenSize.extraLarge;
  }

  /// Determina a orientação da tela
  static ScreenOrientation getOrientation(Size size) {
    return size.width > size.height
        ? ScreenOrientation.landscape
        : ScreenOrientation.portrait;
  }

  /// Obtém a margem responsiva
  static double getMargin(ScreenSize size) {
    return kMargins[size] ?? kMargins[ScreenSize.medium]!;
  }

  /// Obtém o padding responsivo
  static double getPadding(ScreenSize size) {
    return kPaddings[size] ?? kPaddings[ScreenSize.medium]!;
  }

  /// Obtém o tamanho de fonte base responsivo
  static double getBaseFontSize(ScreenSize size) {
    return kBaseFontSize[size] ?? kBaseFontSize[ScreenSize.medium]!;
  }

  /// Obtém o tamanho de fonte de título responsivo
  static double getTitleFontSize(ScreenSize size) {
    return kTitleFontSize[size] ?? kTitleFontSize[ScreenSize.medium]!;
  }

  /// Obtém o tamanho de slot responsivo
  static double getSlotSize(ScreenSize size) {
    return kSlotSize[size] ?? kSlotSize[ScreenSize.medium]!;
  }

  /// Obtém o espaçamento responsivo
  static double getSpacing(ScreenSize size) {
    return kSpacing[size] ?? kSpacing[ScreenSize.medium]!;
  }

  /// Calcula escala baseada na largura da tela
  static double getScale(double width) {
    if (width < kSmallBreakpoint) {
      return 0.8;
    } else if (width < kMediumBreakpoint) {
      return 0.9;
    } else if (width < kLargeBreakpoint) {
      return 1.0;
    }
    return 1.1;
  }

  // Constraints de largura e altura para overlays
  static const Map<String, BoxConstraints> kOverlayConstraints = {
    'equipment': BoxConstraints(
      minWidth: 96,
      maxWidth: 180,
      minHeight: 80,
      maxHeight: 400,
    ),
    'inventory': BoxConstraints(
      minWidth: 200,
      maxWidth: 270,
      minHeight: 80,
      maxHeight: 300,
    ),
    'tutorial_inputs': BoxConstraints(
      minWidth: 280,
      maxWidth: 500,
      minHeight: 200,
      maxHeight: 500,
    ),
    'mobile_inputs': BoxConstraints(
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
        const BoxConstraints(
          minWidth: 200,
          maxWidth: 600,
          minHeight: 100,
          maxHeight: 400,
        );

    // Ajusta constraints baseado no tamanho da tela
    if (screenSize == ScreenSize.small) {
      return BoxConstraints(
        minWidth: baseConstraints.minWidth * 0.8,
        maxWidth: baseConstraints.maxWidth * 0.9,
        minHeight: baseConstraints.minHeight * 0.8,
        maxHeight: baseConstraints.maxHeight * 0.9,
      );
    }

    return baseConstraints;
  }
}
