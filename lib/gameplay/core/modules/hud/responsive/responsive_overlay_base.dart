import 'package:dawnforge/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:flutter/widgets.dart';

/// Interface base para todos os overlays responsivos
abstract class ResponsiveOverlayBase extends StatelessWidget
    with ResponsiveOverlayMixin {
  const ResponsiveOverlayBase({super.key});

  /// Define a visibilidade do overlay através de um ValueNotifier
  ValueNotifier<bool> get visibilityNotifier;

  /// Constrói o conteúdo do overlay com informações responsivas
  Widget buildOverlayContent(BuildContext context, ResponsiveOverlayData data);

  /// Define a posição do overlay na tela
  OverlayPosition getOverlayPosition(BuildContext context);

  /// ID único do overlay para buscar constraints específicas
  String get overlayId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibilityNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        return child!;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final data = ResponsiveOverlayData.fromContext(context);
          final position = getOverlayPosition(context);
          final overlayConstraints =
              OverlayResponsiveConfig.getOverlayConstraints(
                overlayId,
                screenSize: getScreenSizeType(context),
              );

          Widget content = buildOverlayContent(context, data);

          // Aplica constraints ao conteúdo
          content = ConstrainedBox(
            constraints: overlayConstraints,
            child: content,
          );

          return Align(
            alignment: position.alignment,
            child: SafeArea(minimum: position.safeAreaPadding, child: content),
          );
        },
      ),
    );
  }
}

/// Dados responsivos calculados para o overlay
class ResponsiveOverlayData {
  final Size screenSize;
  final double margin;
  final double padding;
  final double baseFontSize;
  final double titleFontSize;
  final double slotSize;
  final double equipmentSlotSize;
  final double spacing;
  final double scale;
  final bool isPortrait;
  final bool isMobileScreen;
  final bool isTabletScreen;
  final bool isDesktopScreen;
  final EdgeInsets safeAreaInsets;

  const ResponsiveOverlayData({
    required this.screenSize,
    required this.margin,
    required this.padding,
    required this.baseFontSize,
    required this.titleFontSize,
    required this.slotSize,
    required this.equipmentSlotSize,
    required this.spacing,
    required this.scale,
    required this.isPortrait,
    required this.isMobileScreen,
    required this.isTabletScreen,
    required this.isDesktopScreen,
    required this.safeAreaInsets,
  });

  factory ResponsiveOverlayData.fromContext(BuildContext context) {
    final mixin = _ResponsiveOverlayMixinHelper();

    return ResponsiveOverlayData(
      screenSize: mixin.getScreenDimensions(context),
      margin: mixin.getResponsiveMargin(context),
      padding: mixin.getResponsivePadding(context),
      baseFontSize: mixin.getResponsiveBaseFontSize(context),
      titleFontSize: mixin.getResponsiveTitleFontSize(context),
      slotSize: mixin.getResponsiveSlotSize(context),
      equipmentSlotSize: mixin.getResponsiveEquipmentSlotSize(context),
      spacing: mixin.getResponsiveSpacing(context),
      scale: mixin.getResponsiveScale(context),
      isPortrait: mixin.isPortrait(context),
      isMobileScreen: mixin.isMobileScreen(context),
      isTabletScreen: mixin.isTabletScreen(context),
      isDesktopScreen: mixin.isDesktopScreen(context),
      safeAreaInsets: mixin.getSafeAreaInsets(context),
    );
  }
}

/// Helper class para usar o mixin sem herança
class _ResponsiveOverlayMixinHelper with ResponsiveOverlayMixin {}

/// Define a posição do overlay na tela
class OverlayPosition {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final EdgeInsets safeAreaPadding;
  final Alignment alignment;

  const OverlayPosition({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.safeAreaPadding = EdgeInsets.zero,
    this.alignment = Alignment.center,
  });

  /// Posição no canto superior direito
  factory OverlayPosition.topRight({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      top: margin,
      right: margin,
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.topRight,
    );
  }

  /// Posição no canto inferior esquerdo
  factory OverlayPosition.bottomLeft({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      bottom: margin,
      left: margin,
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.bottomLeft,
    );
  }

  /// Posição centralizada na parte inferior
  factory OverlayPosition.bottomCenter({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      bottom: margin,
      left: 0,
      right: 0,
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.bottomCenter,
    );
  }

  /// Posição no canto inferior esquerdo
  factory OverlayPosition.bottomRight({
    double margin = 20,
    EdgeInsets safeAreaPadding = const EdgeInsets.all(8),
  }) {
    return OverlayPosition(
      bottom: margin,
      right: margin,
      safeAreaPadding: safeAreaPadding,
      alignment: Alignment.bottomRight,
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
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      safeAreaPadding: safeAreaPadding,
      alignment: alignment,
    );
  }
}
