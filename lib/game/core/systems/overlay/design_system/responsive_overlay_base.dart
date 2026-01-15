/// **ResponsiveOverlayBase - Base para overlays responsivos**
import 'package:dawnforge/game/core/systems/overlay/design_system/overlay_design_system_extension.dart';
import 'package:flutter/widgets.dart';

abstract class ResponsiveOverlayBase extends StatelessWidget {
  const ResponsiveOverlayBase({super.key});

  ValueNotifier<bool> get visibilityNotifier;
  Widget buildOverlayContent(BuildContext context);
  OverlayPosition getOverlayPosition(BuildContext context);
  String get overlayId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibilityNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();
        return child!;
      },
      child: _buildPositionedOverlay(context),
    );
  }

  Widget _buildPositionedOverlay(BuildContext context) {
    final position = getOverlayPosition(context);
    final constraints = context.overlayConstraints.forOverlay(overlayId);

    Widget content = buildOverlayContent(context);

    content = ConstrainedBox(constraints: constraints, child: content);

    return Align(
      alignment: position.alignment,
      child: SafeArea(minimum: position.safeAreaPadding, child: content),
    );
  }
}

@immutable
final class OverlayPosition {
  final Alignment alignment;
  final EdgeInsets safeAreaPadding;

  const OverlayPosition({
    required this.alignment,
    this.safeAreaPadding = EdgeInsets.zero,
  });

  factory OverlayPosition.topRight({
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) => OverlayPosition(
    alignment: Alignment.topRight,
    safeAreaPadding: safeAreaPadding,
  );

  factory OverlayPosition.bottomRight({
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) => OverlayPosition(
    alignment: Alignment.bottomRight,
    safeAreaPadding: safeAreaPadding,
  );

  /// Posição centralizada na parte inferior
  factory OverlayPosition.bottomCenter({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.bottomCenter,
    );
  }

  /// Posição no canto inferior esquerdo
  factory OverlayPosition.bottomLeft({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.bottomLeft,
    );
  }

  /// Posição customizada
  factory OverlayPosition.custom({
    double? left,
    double? top,
    double? right,
    double? bottom,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
    Alignment alignment = Alignment.center,
  }) {
    return OverlayPosition(
      safeAreaPadding: safeAreaPadding,
      alignment: alignment,
    );
  }
}
