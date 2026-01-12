import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';

class SafeFlameSplashScreen extends StatefulWidget {
  final FlameSplashTheme theme;
  final ValueChanged<BuildContext> onFinish;

  const SafeFlameSplashScreen({
    Key? key,
    required this.theme,
    required this.onFinish,
  }) : super(key: key);

  @override
  _SafeFlameSplashScreenState createState() => _SafeFlameSplashScreenState();
}

class _SafeFlameSplashScreenState extends State<SafeFlameSplashScreen> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlameSplashScreen(
      theme: widget.theme,
      onFinish: (ctx) {
        if (!_isDisposed) {
          widget.onFinish(ctx);
        }
      },
    );
  }
}
