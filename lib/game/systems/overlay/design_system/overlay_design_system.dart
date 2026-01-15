/// **OverlayDesignSystem - Sistema de Design para Overlays de Gameplay**
import 'package:dawnforge/game/systems/overlay/design_system/overlay_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

final class OverlayDesignSystem extends InheritedWidget {
  final ScreenSizeInfo screenSize;
  final OverlaySpacing spacing;
  final OverlaySizes sizes;
  final OverlayTypography typography;
  final OverlayScale scale;
  final OverlayConstraints constraints;

  const OverlayDesignSystem({
    super.key,
    required super.child,
    required this.screenSize,
    required this.spacing,
    required this.sizes,
    required this.typography,
    required this.scale,
    required this.constraints,
  });

  static OverlayDesignSystem of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<OverlayDesignSystem>();
    assert(result != null, 'No OverlayDesignSystem found in context');
    return result!;
  }

  static ScreenSizeInfo screenSizeOf(BuildContext context) {
    return of(context).screenSize;
  }

  @override
  bool updateShouldNotify(OverlayDesignSystem oldWidget) {
    return screenSize != oldWidget.screenSize ||
        spacing != oldWidget.spacing ||
        sizes != oldWidget.sizes ||
        typography != oldWidget.typography ||
        scale != oldWidget.scale ||
        constraints != oldWidget.constraints;
  }
}

final class OverlayDesignSystemProvider extends StatelessWidget {
  final Widget child;

  const OverlayDesignSystemProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenSize = ScreenSizeInfo.fromSize(
      mediaQuery.size,
      mediaQuery.orientation,
    );

    final screenType = screenSize.type;

    return OverlayDesignSystem(
      screenSize: screenSize,
      spacing: OverlaySpacing(screenType),
      sizes: OverlaySizes(screenType),
      typography: OverlayTypography(screenType),
      scale: OverlayScale(screenType),
      constraints: OverlayConstraints(screenType),
      child: child,
    );
  }
}