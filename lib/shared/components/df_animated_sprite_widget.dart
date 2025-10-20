import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// [DFAnimatedSpriteWidget] responsible for displaying animated sprites following game's visual theme
///
/// This component provides consistent sprite animation display throughout the application,
/// supporting custom sizes and proper integration with the Bonfire game engine.
///
/// Usage examples:
/// ```dart
/// DFAnimatedSpriteWidget(animation: spriteAnimationFuture)
/// DFAnimatedSpriteWidget.large(animation: spriteAnimationFuture)
/// DFAnimatedSpriteWidget.small(animation: spriteAnimationFuture)
/// ```
///
/// Following CLAUDE.md patterns for Flutter StatelessWidget components
class DFAnimatedSpriteWidget extends StatelessWidget {
  // 1. Constantes de configuração
  /// Default size for sprite animations
  static const double kDefaultSize = 100.0;

  /// Large size for sprite animations
  static const double kLargeSize = 150.0;

  /// Small size for sprite animations
  static const double kSmallSize = 50.0;

  // 2. Propriedades da classe
  /// The sprite animation to display
  final Future<SpriteAnimation> animation;

  /// Width of the sprite widget
  final double width;

  /// Height of the sprite widget
  final double height;

  // 3. Construtor principal
  /// Creates an animated sprite widget with default size
  const DFAnimatedSpriteWidget({
    super.key,
    required this.animation,
    this.width = kDefaultSize,
    this.height = kDefaultSize,
  });

  // 4. Factory constructors
  /// Creates a large animated sprite widget
  const DFAnimatedSpriteWidget.large({
    super.key,
    required this.animation,
    this.width = kLargeSize,
    this.height = kLargeSize,
  });

  /// Creates a small animated sprite widget
  const DFAnimatedSpriteWidget.small({
    super.key,
    required this.animation,
    this.width = kSmallSize,
    this.height = kSmallSize,
  });

  // 5. Método build
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: animation.asWidget());
  }
}
