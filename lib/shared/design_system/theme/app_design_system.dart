import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

/// **AppDesignSystem Unificado**
/// Contém tokens gerais (App) e tokens de overlays (Overlay)
final class AppDesignSystem extends InheritedWidget {
  final ScreenSizeInfo screenSize;
  final bool debugIsOn;

  // 🔥 Tokens Gerais
  final AppSpacing spacing;
  final AppRadius radius;
  final AppSizes sizes;

  // 🔥 Tokens de Overlays
  final OverlaySpacing overlaySpacing;
  final OverlaySizes overlaySizes;
  final OverlayTypography overlayTypography;
  final OverlayScale overlayScale;
  final OverlayConstraints overlayConstraints;

  const AppDesignSystem({
    super.key,
    required super.child,
    required this.screenSize,
    required this.spacing,
    required this.radius,
    required this.sizes,
    required this.overlaySpacing,
    required this.overlaySizes,
    required this.overlayTypography,
    required this.overlayScale,
    required this.overlayConstraints,
    this.debugIsOn = false,
  });

  static AppDesignSystem of(BuildContext context) {
    final AppDesignSystem? result =
        context.dependOnInheritedWidgetOfExactType<AppDesignSystem>();
    assert(result != null, 'No AppDesignSystem found in context');
    return result!;
  }

  static ScreenSizeInfo screenSizeOf(BuildContext context) {
    return of(context).screenSize;
  }

  @override
  bool updateShouldNotify(AppDesignSystem oldWidget) {
    return screenSize != oldWidget.screenSize ||
        spacing != oldWidget.spacing ||
        radius != oldWidget.radius ||
        sizes != oldWidget.sizes ||
        overlaySpacing != oldWidget.overlaySpacing ||
        overlaySizes != oldWidget.overlaySizes ||
        overlayTypography != oldWidget.overlayTypography ||
        overlayScale != oldWidget.overlayScale ||
        overlayConstraints != oldWidget.overlayConstraints ||
        debugIsOn != oldWidget.debugIsOn;
  }
}

/// **Provider Unificado**
final class AppDesignSystemProvider extends StatelessWidget {
  final Widget child;
  final bool debugIsOn;

  const AppDesignSystemProvider({
    super.key,
    required this.child,
    this.debugIsOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);

        final screenSize = ScreenSizeInfo.fromSize(
          mediaQuery.size,
          mediaQuery.orientation,
        );

        final screenType = screenSize.type;

        return AppDesignSystem(
          screenSize: screenSize,
          // Tokens Gerais
          spacing: AppSpacing(screenType),
          radius: AppRadius(screenType),
          sizes: AppSizes(screenType),
          // Tokens de Overlays
          overlaySpacing: OverlaySpacing(screenType),
          overlaySizes: OverlaySizes(screenType),
          overlayTypography: OverlayTypography(screenType),
          overlayScale: OverlayScale(screenType),
          overlayConstraints: OverlayConstraints(screenType),
          debugIsOn: debugIsOn,
          child: child,
        );
      },
    );
  }
}

final darkTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(primary: Color(0xffef6f3b)),
);