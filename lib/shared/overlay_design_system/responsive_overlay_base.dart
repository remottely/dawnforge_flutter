/// **ResponsiveOverlayBase - Base para overlays responsivos**
library;

import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/widgets.dart';

abstract class ResponsiveOverlayBase extends StatelessWidget {
  const ResponsiveOverlayBase({super.key});

  Widget buildOverlayContent(BuildContext context);
  String get overlayId;

  @override
  Widget build(BuildContext context) {
    return _buildOverlay(context);
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
