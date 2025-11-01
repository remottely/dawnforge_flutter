import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:flutter/material.dart';

class AppStyledDialog extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;

  const AppStyledDialog({
    super.key,
    this.backgroundColor = DDDesignSystem.kStandardDialogBackgroundColor,
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
