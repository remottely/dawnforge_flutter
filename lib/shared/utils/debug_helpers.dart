import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/material.dart';

final class DebugColors {
  static const Color imageArea = Colors.blue;
  static const Color formArea = Colors.purple;
  static const Color buttonArea = Colors.yellow;
}

final class DebugContainer extends StatelessWidget {
  final Color color;
  final Widget? child;

  const DebugContainer({
    super.key,
    required this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final debugIsOn = AppDesignSystem.of(context).debugIsOn;

    return Container(
      color: debugIsOn ? color : Colors.transparent,
      child: child,
    );
  }
}
