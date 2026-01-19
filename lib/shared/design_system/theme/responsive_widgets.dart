import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';

final class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSizeInfo info)? builder;
  final Widget Function(BuildContext context, ScreenSizeInfo info) mobile;
  final Widget Function(BuildContext context, ScreenSizeInfo info) tablet;
  final Widget Function(BuildContext context, ScreenSizeInfo info) desktop;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = AppDesignSystem.screenSizeOf(context);

    if (builder != null) {
      return builder!(context, screenSize);
    } else {
      return switch (screenSize.type) {
        ScreenSizeType.mobile => mobile(context, screenSize),
        ScreenSizeType.tablet => (tablet)(context, screenSize),
        ScreenSizeType.desktop => (desktop)(context, screenSize),
      };
    }
  }
}

final class ResponsiveValue<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value) builder;
  final T mobile;
  final T tablet;
  final T desktop;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = AppDesignSystem.screenSizeOf(context).type;

    final value = switch (screenType) {
      ScreenSizeType.mobile => mobile,
      ScreenSizeType.tablet => tablet,
      ScreenSizeType.desktop => desktop,
    };

    return builder(context, value);
  }
}
