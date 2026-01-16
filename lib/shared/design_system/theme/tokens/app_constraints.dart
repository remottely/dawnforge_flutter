import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';

@immutable
final class AppConstraints {
  final ScreenSizeType _screenType;
  const AppConstraints(this._screenType);

  static const Map<String, BoxConstraints> _baseConstraints = {
    'tutorial_inputs': BoxConstraints(minWidth: 300, maxWidth: 500),
    'mobile_inputs': BoxConstraints(
      minWidth: double.infinity,
      maxWidth: double.infinity,
    ),
    'joystick_actions': BoxConstraints(
      minWidth: double.infinity,
      maxWidth: double.infinity,
    ),
  };

  BoxConstraints forOverlay(String overlayId) {
    final base =
        _baseConstraints[overlayId] ??
        const BoxConstraints(minWidth: 200, maxWidth: 400);

    // Mobile reduz 15%
    if (_screenType == ScreenSizeType.mobile) {
      return BoxConstraints(
        minWidth: base.minWidth == double.infinity
            ? double.infinity
            : base.minWidth * 0.85,
        maxWidth: base.maxWidth == double.infinity
            ? double.infinity
            : base.maxWidth * 0.85,
        minHeight: base.minHeight,
        maxHeight: base.maxHeight,
      );
    }

    return base;
  }
}
