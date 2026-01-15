hj eu possuo AppDesignSystemProvider e OverlayDesignSystemProvider, porém deveria ser 1 provider só, o AppDesignSystemProvider. O mesmo ocorre para overlay_tokens.dart q deveriam fazer parte de app_tokens.dart. o mesmo vale para AppDesignSystem e OverlayDesignSystem q deveriam estar tudo em AppDesignSystem. unifique para mim o codigo abaixo:
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';


@immutable
final class AppSpacing {
final ScreenSizeType _screenType;
const AppSpacing(this._screenType);


static const double _superSmall = 2.0;
static const double _extraSmall = 4.0;
static const double _small = 8.0;
static const double _medium = 16.0;
static const double _large = 24.0;
static const double _extraLarge = 32.0;
static const double _superLarge = 48.0;


static const _logoValue = ScreenSizeValue<double>(
mobile: _large,
tablet: _extraLarge,
desktop: _superLarge,
);
static const _contentValue = ScreenSizeValue<double>(
mobile: _medium,
tablet: _large,
desktop: _extraLarge,
);
static const _screenValue = ScreenSizeValue<double>(
mobile: _medium,
tablet: _large,
desktop: _extraLarge,
);
static const _textFormFieldValue = ScreenSizeValue<double>(
mobile: _extraSmall,
tablet: _small,
desktop: _small,
);
static const _authFormContentValue = ScreenSizeValue<double>(
mobile: _large,
tablet: _extraLarge,
desktop: _superLarge,
);
static const _authFormFieldsValue = ScreenSizeValue<double>(
mobile: _small,
tablet: _medium,
desktop: _medium,
);


double get logo => _logoValue.get(_screenType);
double get content => _contentValue.get(_screenType);
double get screen => _screenValue.get(_screenType);
double get textFormField => _textFormFieldValue.get(_screenType);
double get authFormContent => _authFormContentValue.get(_screenType);
double get authFormFields => _authFormFieldsValue.get(_screenType);
}


@immutable
final class AppRadius {
final ScreenSizeType _screenType;
const AppRadius(this._screenType);


static const double _small = 4.0;
static const double _medium = 8.0;
static const double _large = 16.0;


static const _textFormFieldValue = ScreenSizeValue<double>(
mobile: _small,
tablet: _medium,
desktop: _medium,
);
static const _buttonValue = ScreenSizeValue<double>(
mobile: _small,
tablet: _medium,
desktop: _medium,
);


double get textFormField => _textFormFieldValue.get(_screenType);
double get button => _buttonValue.get(_screenType);
}


@immutable
final class AppSizes {
final ScreenSizeType _screenType;
const AppSizes(this._screenType);


static const _iconSmallValue = ScreenSizeValue<double>(
mobile: 12.0,
tablet: 16.0,
desktop: 24.0,
);
static const _iconMediumValue = ScreenSizeValue<double>(
mobile: 16.0,
tablet: 24.0,
desktop: 32.0,
);
static const _iconLargeValue = ScreenSizeValue<double>(
mobile: 24.0,
tablet: 32.0,
desktop: 40.0,
);


double get minTouchTarget => 44.0;
double get buttonHeight => 48.0;


double get avatarSmall => 40.0;
double get avatarMedium => 56.0;


double get iconSmall => _iconSmallValue.get(_screenType);
double get iconMedium => _iconMediumValue.get(_screenType);
double get iconLarge => _iconLargeValue.get(_screenType);
}
import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';


final class AppDesignSystem extends InheritedWidget {
final ScreenSizeInfo screenSize;
final AppSpacing spacing;
final AppRadius radius;
final AppSizes sizes;
final bool debugIsOn;


const AppDesignSystem({
super.key,
required super.child,
required this.screenSize,
required this.spacing,
required this.radius,
required this.sizes,
this.debugIsOn = false,
});


static AppDesignSystem of(BuildContext context) {
final AppDesignSystem? result = context
.dependOnInheritedWidgetOfExactType<AppDesignSystem>();
assert(result != null, 'No AppDesignSystem found in context');
return result!;
}


static ScreenSizeInfo screenSizeOf(BuildContext context) {
return of(context).screenSize;
}


@override
bool updateShouldNotify(AppDesignSystem oldWidget) {
return screenSize != oldWidget.screenSize ||
spacing != oldWidget.spacing ||
radius != oldWidget.radius ||
sizes != oldWidget.sizes ||
debugIsOn != oldWidget.debugIsOn;
}
}


final class AppDesignSystemProvider extends StatelessWidget {
final Widget child;
final bool debugIsOn;


const AppDesignSystemProvider({
super.key,
required this.child,
this.debugIsOn = false,
});


@override
Widget build(BuildContext context) {
return LayoutBuilder(
builder: (context, constraints) {
final mediaQuery = MediaQuery.of(context);


    final screenSize = ScreenSizeInfo.fromSize(
      mediaQuery.size,
      mediaQuery.orientation,
    );

    final screenType = screenSize.type;
    final spacing = AppSpacing(screenType);
    final radius = AppRadius(screenType);
    final sizes = AppSizes(screenType);

    return AppDesignSystem(
      screenSize: screenSize,
      spacing: spacing,
      radius: radius,
      sizes: sizes,
      debugIsOn: debugIsOn,
      child: child,
    );
  },
);

}
}


final darkTheme = ThemeData(
useMaterial3: false,
scaffoldBackgroundColor: Colors.black,
colorScheme: ColorScheme.dark(primary: Color(0xffef6f3b)),
);
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:dawnforge/shared/design_system/theme/app_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';


extension AppDesignSystemExtension on BuildContext {
AppDesignSystem get ds => AppDesignSystem.of(this);


AppSpacing get spacing => ds.spacing;
AppRadius get radius => ds.radius;
AppSizes get sizes => ds.sizes;


ScreenSizeInfo get screenSize => ds.screenSize;
ScreenSizeType get screenType => ds.screenSize.type;


bool get isMobile => screenSize.isMobile;
bool get isTablet => screenSize.isTablet;
bool get isDesktop => screenSize.isDesktop;
bool get isPortrait => screenSize.isPortrait;
bool get isLandscape => screenSize.isLandscape;


T responsive<T>({
required T mobile,
required T tablet,
required T desktop,
}) {
final value = ScreenSizeValue<T>(
mobile: mobile,
tablet: tablet,
desktop: desktop,
);
return value.get(screenType);
}


T responsiveOr<T>({
required T mobile,
T? tablet,
T? desktop,
}) {
return responsive(
mobile: mobile,
tablet: tablet ?? mobile,
desktop: desktop ?? tablet ?? mobile,
);
}
}
/// OverlayTokens - Design Tokens para Overlays de Gameplay
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
/// OverlayDesignSystem - Sistema de Design para Overlays de Gameplay
import 'package:dawnforge/shared/overlay_design_system/overlay_tokens.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/material.dart';


final class OverlayDesignSystem extends InheritedWidget {
final ScreenSizeInfo screenSize;
final OverlaySpacing spacing;
final OverlaySizes sizes;
final OverlayTypography typography;
final OverlayScale scale;
final OverlayConstraints constraints;


const OverlayDesignSystem({
super.key,
required super.child,
required this.screenSize,
required this.spacing,
required this.sizes,
required this.typography,
required this.scale,
required this.constraints,
});


static OverlayDesignSystem of(BuildContext context) {
final result = context.dependOnInheritedWidgetOfExactType<OverlayDesignSystem>();
assert(result != null, 'No OverlayDesignSystem found in context');
return result!;
}


static ScreenSizeInfo screenSizeOf(BuildContext context) {
return of(context).screenSize;
}


@override
bool updateShouldNotify(OverlayDesignSystem oldWidget) {
return screenSize != oldWidget.screenSize ||
spacing != oldWidget.spacing ||
sizes != oldWidget.sizes ||
typography != oldWidget.typography ||
scale != oldWidget.scale ||
constraints != oldWidget.constraints;
}
}


final class OverlayDesignSystemProvider extends StatelessWidget {
final Widget child;


const OverlayDesignSystemProvider({
super.key,
required this.child,
});


@override
Widget build(BuildContext context) {
final mediaQuery = MediaQuery.of(context);


final screenSize = ScreenSizeInfo.fromSize(
  mediaQuery.size,
  mediaQuery.orientation,
);

final screenType = screenSize.type;

return OverlayDesignSystem(
  screenSize: screenSize,
  spacing: OverlaySpacing(screenType),
  sizes: OverlaySizes(screenType),
  typography: OverlayTypography(screenType),
  scale: OverlayScale(screenType),
  constraints: OverlayConstraints(screenType),
  child: child,
);

}
}
/// Extension para acesso fácil ao OverlayDesignSystem
import 'package:dawnforge/shared/overlay_design_system/overlay_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:flutter/widgets.dart';


extension OverlayDesignSystemExtension on BuildContext {
OverlayDesignSystem get overlayDesignSystem => OverlayDesignSystem.of(this);


EdgeInsets get overlaySafeArea => MediaQuery.of(this).padding;
Size get overlayScreenDimensions => MediaQuery.of(this).size;


double overlayWidth(double percentage) {
return overlayScreenDimensions.width * percentage;
}


double overlayHeight(double percentage) {
return overlayScreenDimensions.height * percentage;
}


T overlayValueByOrientation<T>({required T portrait, required T landscape}) {
return overlayDesignSystem.screenSize.isPortrait ? portrait : landscape;
}


T overlayValueByScreenSize<T>({required T mobile, T? tablet, T? desktop}) {
return switch (overlayDesignSystem.screenSize.type) {
ScreenSizeType.mobile => mobile,
ScreenSizeType.tablet => tablet ?? mobile,
ScreenSizeType.desktop => desktop ?? tablet ?? mobile,
};
}


Offset overlayPosition({
double? left,
double? top,
double? right,
double? bottom,
}) {
final size = overlayScreenDimensions;
final safeArea = overlaySafeArea;


double x = 0;
double y = 0;

if (left != null) {
  x = left + safeArea.left;
} else if (right != null) {
  x = size.width - right - safeArea.right;
}

if (top != null) {
  y = top + safeArea.top;
} else if (bottom != null) {
  y = size.height - bottom - safeArea.bottom;
}

return Offset(x, y);

}
}
/// ResponsiveOverlayBase - Base para overlays responsivos
import 'package:dawnforge/shared/overlay_design_system/overlay_design_system_extension.dart';
import 'package:flutter/widgets.dart';


abstract class ResponsiveOverlayBase extends StatelessWidget {
const ResponsiveOverlayBase({super.key});


ValueNotifier<bool> get visibilityNotifier;
Widget buildOverlayContent(BuildContext context);
String get overlayId;


@override
Widget build(BuildContext context) {
return ValueListenableBuilder<bool>(
valueListenable: visibilityNotifier,
builder: (context, isVisible, child) {
if (!isVisible) return const SizedBox.shrink();
return child!;
},
child: _buildOverlay(context),
);
}


Widget _buildOverlay(BuildContext context) {
final constraints = context.overlayDesignSystem.constraints.forOverlay(overlayId);


Widget content = buildOverlayContent(context);

content = ConstrainedBox(constraints: constraints, child: content);

return SafeArea(child: content);

}
}