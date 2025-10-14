import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// [AppStyledDialog] responsible for providing styled dialogs following game's visual theme
///
/// This component provides consistent dialog styling throughout the application,
/// supporting custom backgrounds and child widget composition.
///
/// Usage examples:
/// ```dart
/// AppStyledDialog(children: [Text('Content')])
/// AppStyledDialog.withBackground(
///   backgroundColor: Colors.black54,
///   children: [Button(), Text()],
/// )
/// ```
///
/// Following CLAUDE.md patterns for Flutter StatelessWidget components
class AppStyledDialog extends StatelessWidget {
  // 1. Constantes de configuração
  /// Default background color for dialogs
  static const Color kDefaultBackgroundColor =
      GameplayUIConstants.kTransparentColor;

  // 2. Propriedades da classe
  /// Background color of the dialog
  final Color backgroundColor;

  /// List of child widgets to display in the dialog
  final List<Widget> children;

  // 3. Construtor principal
  /// Creates a styled dialog with transparent background
  const AppStyledDialog({
    super.key,
    this.backgroundColor = kDefaultBackgroundColor,
    required this.children,
  });

  // 4. Factory constructors
  /// Creates a styled dialog with custom background color
  const AppStyledDialog.withBackground({
    super.key,
    required this.backgroundColor,
    required this.children,
  });

  // 5. Método build
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
