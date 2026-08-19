import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_constraints.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_radius.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_scale.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_sizes.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_spacing.dart';
import 'package:dawnforge/shared/design_system/theme/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// **AppDesignSystem Unificado**
/// Contém tokens gerais (App) e tokens de overlays (Overlay)
final class AppDesignSystem extends InheritedWidget {
  final bool debugIsOn;
  final ScreenSizeInfo screenSize;
  final AppRadius radius;
  final AppSpacing spacing;
  final AppSizes sizes;
  final AppTypography typography;
  final AppScale scale;
  final AppConstraints constraints;

  const AppDesignSystem({
    super.key,
    required super.child,
    required this.debugIsOn,
    required this.screenSize,
    required this.radius,
    required this.spacing,
    required this.sizes,
    required this.typography,
    required this.scale,
    required this.constraints,
  });

  static AppDesignSystem of(BuildContext context) {
    final AppDesignSystem? result = context
        .dependOnInheritedWidgetOfExactType<AppDesignSystem>();
    assert(result != null, 'No AppDesignSystem found in context');
    return result!;
  }

  static ScreenSizeInfo screenSizeOf(BuildContext context) {
    return of(context).screenSize;
  }

  @override
  bool updateShouldNotify(AppDesignSystem oldWidget) {
    return screenSize != oldWidget.screenSize ||
        radius != oldWidget.radius ||
        spacing != oldWidget.spacing ||
        sizes != oldWidget.sizes ||
        typography != oldWidget.typography ||
        scale != oldWidget.scale ||
        constraints != oldWidget.constraints ||
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
          radius: AppRadius(screenType),
          // Tokens de Overlays
          spacing: AppSpacing(screenType),
          sizes: AppSizes(screenType),
          typography: AppTypography(screenType),
          scale: AppScale(screenType),
          constraints: AppConstraints(screenType),
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
