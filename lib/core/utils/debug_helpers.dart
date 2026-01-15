import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/material.dart';

abstract class DebugColors {
  static const gameplayOverlayLeftArea = Colors.purple;

  static const gameplayOverlayTopCenterArea = Colors.blue;
  static const gameplayOverlayTopRightArea = Colors.green;

  static const gameplayOverlayCenterArea = Colors.yellow;
  static const gameplayOverlayCenterRightArea = Colors.brown;

  static const gameplayOverlayBottomCenterArea = Colors.orange;
  static const gameplayOverlayBottomRightArea = Colors.grey;
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
