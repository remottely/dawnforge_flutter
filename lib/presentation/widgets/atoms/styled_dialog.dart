import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_state_manager.dart';
import 'package:flutter/material.dart';

/// Creates a styled dialog widget following Flutter UI patterns
/// This is a reusable component for dialog creation
class StyledDialog extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;

  const StyledDialog({
    super.key,
    this.backgroundColor = GameplayUIStateManager.kTransparentColor,
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
