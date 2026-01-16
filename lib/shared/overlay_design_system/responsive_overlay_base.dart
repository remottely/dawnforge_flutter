/// **ResponsiveOverlayBase - Base para overlays responsivos**
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system_extension.dart';
import 'package:flutter/widgets.dart';

abstract class ResponsiveOverlayBase extends StatelessWidget {
  const ResponsiveOverlayBase({super.key});

  ValueNotifier<bool> get visibilityNotifier;
  Widget buildOverlayContent(BuildContext context);
  String get overlayId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibilityNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();
        return child!;
      },
      child: _buildOverlay(context),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final constraints = AppDesignSystem.of(
      context,
    ).constraints.forOverlay(overlayId);

    Widget content = buildOverlayContent(context);

    content = ConstrainedBox(constraints: constraints, child: content);

    return SafeArea(child: content);
  }
}
