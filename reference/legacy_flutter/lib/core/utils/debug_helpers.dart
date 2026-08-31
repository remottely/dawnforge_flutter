import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/material.dart';

abstract class DebugColors {
  static const Color gameplayOverlayLeftArea = Colors.purple;

  static const Color gameplayOverlayTopCenterArea = Colors.blue;
  static const Color gameplayOverlayTopRightArea = Colors.green;

  static const Color gameplayOverlayCenterArea = Colors.yellow;
  static const Color gameplayOverlayCenterRightArea = Colors.brown;

  static const Color gameplayOverlayBottomCenterArea = Colors.orange;
  static const Color gameplayOverlayBottomRightArea = Colors.grey;
}

final class DebugContainer extends StatelessWidget {
  final Color color;
  final Widget? child;

  const DebugContainer({super.key, required this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final debugIsOn = AppDesignSystem.of(context).debugIsOn;

    return Container(
      // color: debugIsOn ? color.withValues(alpha: 0.3) : Colors.transparent,
      color: debugIsOn ? color.withValues(alpha: 1) : Colors.transparent,
      child: child,
    );
  }
}
