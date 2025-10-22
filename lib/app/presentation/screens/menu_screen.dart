import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/presentation/design_system/components/atoms/app_radio_button.dart';
import 'package:darkness_dungeon/app/presentation/design_system/constants/typography_constants.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

abstract class MenuScreenViewModel extends State<MenuScreen> {
  final Duration kAnimationDuration = Duration(milliseconds: 300);
  final Duration kCharacterAnimationInterval = Duration(seconds: 2);

  bool _isSplashScreenVisible = true;
  int _currentCharacterSpriteIndex = 0;
  late async.Timer _characterAnimationTimer;

  late final List<Future<SpriteAnimation>> _characterSpriteAnimations = [
    PlayerSpriteAnimations.knightPlayerIdleRight6(),
    EnemySpriteAnimations.goblinEnemyIdleRight6(),
    EnemySpriteAnimations.impEnemyIdleRight4(),
    EnemySpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    EnemySpriteAnimations.dungeonBossEnemyIdleRight4(),
  ];

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _onSplashScreenCompleted(BuildContext context) {
    setState(() {
      _isSplashScreenVisible = false;
    });
    _initializeCharacterAnimation();
  }

  void _onControlMethodChanged(bool selectedValue) {
    setState(() {
      Gameplay.useJoystickControls = selectedValue;
    });
  }

  void _navigateToGameplayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Gameplay()),
    );
  }

  void _initializeCharacterAnimation() {
    _characterAnimationTimer = async.Timer.periodic(
      kCharacterAnimationInterval,
      (timer) {
        setState(() {
          _currentCharacterSpriteIndex++;
          if (_currentCharacterSpriteIndex >
              _characterSpriteAnimations.length - 1) {
            _currentCharacterSpriteIndex = 0;
          }
        });
      },
    );
  }

  void _cleanupResources() {
    GameplayAudioManager.stopBackgroundMusic();
    _characterAnimationTimer.cancel();
  }

  async.Future<void> _openExternalURL(String targetUrl) async {
    final parsedUri = Uri.parse(targetUrl);
    if (await canLaunchUrl(parsedUri)) {
      await launchUrl(parsedUri);
    } else {
      throw 'Could not launch $targetUrl';
    }
  }
}

class _MenuScreenState extends MenuScreenViewModel {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kAnimationDuration,
      child: _isSplashScreenVisible ? _createSplashScreen() : _createMainMenu(),
    );
  }

  Widget _createMainMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _Title(),
              const SizedBox(height: 20),
              if (_characterSpriteAnimations.isNotEmpty)
                _CharacterAnimation(
                  animation:
                      _characterSpriteAnimations[_currentCharacterSpriteIndex],
                ),
              const SizedBox(height: 30),
              _StartButton(onPressed: _navigateToGameplayScreen),
              const SizedBox(height: 20),
              _Controls(onControlMethodChanged: _onControlMethodChanged),
              const SizedBox(height: 20),
              if (!Gameplay.useJoystickControls) const _KeyboardTip(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _Footer(onOpenURL: _openExternalURL),
    );
  }

  Widget _createSplashScreen() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: _onSplashScreenCompleted,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Darkness Dungeon',
      style: TextStyle(
        color: Colors.white,
        fontFamily: TypographyConstants.kPrimaryFontFamily,
        fontSize: TypographyConstants.kDisplayFontSize,
      ),
    );
  }
}

class _CharacterAnimation extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const _CharacterAnimation({required this.animation});

  @override
  Widget build(BuildContext context) {
    final double kCharacterAnimationSize = 100.0;

    return SizedBox(
      height: kCharacterAnimationSize,
      width: kCharacterAnimationSize,
      child: DFAnimatedSpriteWidget(animation: animation),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  // final BuildContext context;

  // late final ThemeData _theme = Theme.of(context);
  // late final ColorScheme _colors = _theme.colorScheme;
  // late final TextTheme _textTheme = _theme.textTheme;

  static const double kButtonWidth = 150.0;
  static const double kButtonMinHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: kButtonWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size(100, kButtonMinHeight),
            ),
            onPressed: onPressed,
            child: Text(
              GameplayStringsLocation.instance.getString('play_cap'),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: TypographyConstants.kPrimaryFontFamily,
                fontSize: TypographyConstants.kCaptionFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final void Function(bool) onControlMethodChanged;

  const _Controls({required this.onControlMethodChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppRadioButton<bool>(
          value: false,
          label: 'Keyboard',
          group: Gameplay.useJoystickControls,
          onChange: onControlMethodChanged,
        ),
        const SizedBox(height: 10),
        AppRadioButton<bool>(
          value: true,
          group: Gameplay.useJoystickControls,
          label: 'Joystick',
          onChange: onControlMethodChanged,
        ),
      ],
    );
  }
}

class _KeyboardTip extends StatelessWidget {
  const _KeyboardTip();

  static const double kKeyboardTipHeight = 80.0;
  static const double kKeyboardTipWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kKeyboardTipHeight,
      width: kKeyboardTipWidth,
      child: Sprite.load('keyboard_tip.png').asWidget(),
    );
  }
}

class _Footer extends StatelessWidget {
  final Future<void> Function(String) onOpenURL;

  const _Footer({required this.onOpenURL});

  static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 20,
        margin: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    GameplayStringsLocation.instance.getString('powered_by'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: TypographyConstants.kPrimaryFontFamily,
                      fontSize: TypographyConstants.kTinyFontSize,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(kKevinKoboriUrl);
                    },
                    child: const Text(
                      'kevinkobori',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontFamily: TypographyConstants.kPrimaryFontFamily,
                        fontSize: TypographyConstants.kTinyFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    GameplayStringsLocation.instance.getString('built_with'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: TypographyConstants.kPrimaryFontFamily,
                      fontSize: TypographyConstants.kTinyFontSize,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(kBonfireUrl);
                    },
                    child: const Text(
                      'Bonfire',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontFamily: TypographyConstants.kPrimaryFontFamily,
                        fontSize: TypographyConstants.kTinyFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
