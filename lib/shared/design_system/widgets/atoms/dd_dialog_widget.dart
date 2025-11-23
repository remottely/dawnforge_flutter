import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';

class DDDialogWidget extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;

  const DDDialogWidget({
    super.key,
    this.backgroundColor = DDDesignSystem.kDialogBackgroundColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
