/// **OverlayTokens - Design Tokens para Overlays de Gameplay**
/// • Valores responsivos otimizados para overlays do jogo
/// • Segue o padrão do novo AppDesignSystem
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';

@immutable
final class OverlaySpacing {
  final ScreenSizeType _screenType;
  const OverlaySpacing(this._screenType);

  static const double _tiny = 2.0;
  static const double _small = 4.0;
  static const double _medium = 8.0;
  static const double _large = 16.0;
  static const double _extraLarge = 24.0;

  static const _marginValue = ScreenSizeValue<double>(
    mobile: _medium,
    tablet: _large,
    desktop: _extraLarge,
  );

  static const _paddingValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );

  static const _spacingValue = ScreenSizeValue<double>(
    mobile: _small,
    tablet: _medium,
    desktop: _medium,
  );

  double get margin => _marginValue.get(_screenType);
  double get padding => _paddingValue.get(_screenType);
  double get spacing => _spacingValue.get(_screenType);
}

@immutable
final class OverlaySizes {
  final ScreenSizeType _screenType;
  const OverlaySizes(this._screenType);

  static const _slotSizeValue = ScreenSizeValue<double>(
    mobile: 52.0,
    tablet: 64.0,
    desktop: 64.0,
  );

  static const _equipmentSlotSizeValue = ScreenSizeValue<double>(
    mobile: 12.0,
    tablet: 18.0,
    desktop: 24.0,
  );

  static const _actionButtonValue = ScreenSizeValue<double>(
    mobile: 50.0,
    tablet: 60.0,
    desktop: 60.0,
  );

  static const _utilityButtonValue = ScreenSizeValue<double>(
    mobile: 40.0,
    tablet: 50.0,
    desktop: 50.0,
  );

  double get slotSize => _slotSizeValue.get(_screenType);
  double get equipmentSlotSize => _equipmentSlotSizeValue.get(_screenType);
  double get actionButton => _actionButtonValue.get(_screenType);
  double get utilityButton => _utilityButtonValue.get(_screenType);
}

@immutable
final class OverlayTypography {
  final ScreenSizeType _screenType;
  const OverlayTypography(this._screenType);

  static const _baseFontSizeValue = ScreenSizeValue<double>(
    mobile: 10.0,
    tablet: 11.0,
    desktop: 12.0,
  );

  static const _titleFontSizeValue = ScreenSizeValue<double>(
    mobile: 14.0,
    tablet: 16.0,
    desktop: 18.0,
  );

  double get baseFontSize => _baseFontSizeValue.get(_screenType);
  double get titleFontSize => _titleFontSizeValue.get(_screenType);
}

@immutable
final class OverlayScale {
  final ScreenSizeType _screenType;
  const OverlayScale(this._screenType);

  static const _scaleValue = ScreenSizeValue<double>(
    mobile: 0.85,
    tablet: 1.0,
    desktop: 1.15,
  );

  double get scale => _scaleValue.get(_screenType);
}

@immutable
final class OverlayConstraints {
  final ScreenSizeType _screenType;
  const OverlayConstraints(this._screenType);

  static const Map<String, BoxConstraints> _baseConstraints = {
    'equipment': BoxConstraints(minWidth: 100, maxWidth: 200),
    'inventory': BoxConstraints(minWidth: 200, maxWidth: 550),
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
    final base = _baseConstraints[overlayId] ??
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