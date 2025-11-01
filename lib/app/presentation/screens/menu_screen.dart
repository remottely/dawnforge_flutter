import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:darkness_dungeon/shared/components/dd_sprite_animation_widget.dart';
import 'package:darkness_dungeon/shared/components/dd_sprite_widget.dart';
import 'package:darkness_dungeon/shared/design_system/components/atoms/app_radio_button.dart';
import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';
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
    UISpriteAnimations.knightPlayerIdleRight6(),
    UISpriteAnimations.goblinEnemyIdleRight6(),
    UISpriteAnimations.impEnemyIdleRight4(),
    UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    UISpriteAnimations.dungeonBossEnemyIdleRight4(),
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

  void _onControlMethodChanged(InputActionsType selectedInput) {
    setState(() {
      SettingsManager.instance.setInputSelected(selectedInput);
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
    GameplayAudioManager.instance.stopBackgroundMusic();
    _characterAnimationTimer.cancel();
  }

  Future<void> _openExternalURL(String targetUrl) async {
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
            spacing: DDDesignSystem.kSpacingLarge,
            children: <Widget>[
              const _Title(),
              if (_characterSpriteAnimations.isNotEmpty) ...[
                _CharacterAnimation(
                  animation:
                      _characterSpriteAnimations[_currentCharacterSpriteIndex],
                ),
              ],
              _StartButton(onPressed: _navigateToGameplayScreen),
              _Controls(onControlMethodChanged: _onControlMethodChanged),
              switch (SettingsManager.instance.vIsJoystickInputSelected) {
                InputActionsType.joystick =>
                  const SizedBox.shrink(), // TODO(Kevin): Replace with joystick tip widget
                InputActionsType.keyboard => _KeyboardTip(),
              },
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
        fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
        fontSize: DDDesignSystem.kTypographyDisplayFontSize,
      ),
    );
  }
}

class _CharacterAnimation extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const _CharacterAnimation({required this.animation});

  @override
  Widget build(BuildContext context) {
    return DDSpriteAnimationWidget(animation: animation);
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  // final BuildContext context;

  // late final ThemeData _theme = Theme.of(context);
  // late final ColorScheme _colors = _theme.colorScheme;
  // late final TextTheme _textTheme = _theme.textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: Size(100, 40),
          ),
          onPressed: onPressed,
          child: Text(
            GameplayStringsLocation.instance.getString('play_cap'),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
              fontSize: DDDesignSystem.kTypographyCaptionFontSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final void Function(InputActionsType) onControlMethodChanged;

  const _Controls({required this.onControlMethodChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: DDDesignSystem.kSpacingExtraSmall,
      children: [
        AppRadioButton<InputActionsType>(
          value: InputActionsType.keyboard,
          label: 'Keyboard',
          group: SettingsManager.instance.vIsJoystickInputSelected,
          onChange: onControlMethodChanged,
        ),
        AppRadioButton<InputActionsType>(
          value: InputActionsType.joystick,
          group: SettingsManager.instance.vIsJoystickInputSelected,
          label: 'Joystick',
          onChange: onControlMethodChanged,
        ),
      ],
    );
  }
}

class _KeyboardTip extends StatelessWidget {
  const _KeyboardTip();

  @override
  Widget build(BuildContext context) {
    return DDSpriteWidget.extraLarge(sprite: Sprite.load('keyboard_tip.png'));
  }
}

class _Footer extends StatelessWidget {
  final Future<void> Function(String) onOpenURL;

  const _Footer({required this.onOpenURL});

  static const String _kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const String _kBonfireUrl = 'https://pub.dev/packages/bonfire';

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
                      fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
                      fontSize: DDDesignSystem.kTypographyTinyFontSize,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(_kKevinKoboriUrl);
                    },
                    child: const Text(
                      'kevinkobori',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
                        fontSize: DDDesignSystem.kTypographyTinyFontSize,
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
                      fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
                      fontSize: DDDesignSystem.kTypographyTinyFontSize,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(_kBonfireUrl);
                    },
                    child: const Text(
                      'Bonfire',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontFamily: DDDesignSystem.kTypographyPrimaryFontFamily,
                        fontSize: DDDesignSystem.kTypographyTinyFontSize,
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
