import 'package:darkness_dungeon/gameplay/core/config/gameplay_ui_config.dart';
import 'package:flutter/material.dart';

class AppStyledDialog extends StatelessWidget {
  static const _kStandardBackgroundColor = GameplayUIConfig.kTransparentColor;

  final Color backgroundColor;
  final List<Widget> children;

  const AppStyledDialog({
    super.key,
    this.backgroundColor = _kStandardBackgroundColor,
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
