import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

final class AppDesignSystem extends InheritedWidget {
  final ScreenSizeInfo screenSize;
  final AppSpacing spacing;
  final AppRadius radius;
  final AppSizes sizes;
  final bool debugIsOn;

  const AppDesignSystem({
    super.key,
    required super.child,
    required this.screenSize,
    required this.spacing,
    required this.radius,
    required this.sizes,
    this.debugIsOn = false,
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
        spacing != oldWidget.spacing ||
        radius != oldWidget.radius ||
        sizes != oldWidget.sizes ||
        debugIsOn != oldWidget.debugIsOn;
  }
}

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
        final spacing = AppSpacing(screenType);
        final radius = AppRadius(screenType);
        final sizes = AppSizes(screenType);

        return AppDesignSystem(
          screenSize: screenSize,
          spacing: spacing,
          radius: radius,
          sizes: sizes,
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
