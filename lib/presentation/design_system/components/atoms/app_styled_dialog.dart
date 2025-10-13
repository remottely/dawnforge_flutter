import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// Creates a styled dialog widget following Flutter UI patterns
/// This is a reusable component for dialog creation
class AppStyledDialog extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;

  const AppStyledDialog({
    super.key,
    this.backgroundColor = GameplayUIConstants.kTransparentColor,
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
