import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_animated_sprite_widget.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_radio_button.dart';
import 'package:darkness_dungeon/presentation/design_system/constants/typography_constants.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Main menu screen for Darkness Dungeon game
/// Provides navigation to gameplay and control configuration options
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

abstract class MenuScreenViewModel extends State<MenuScreen> {
  // 1. Constantes (agrupadas por tipo)
  final Duration kAnimationDuration = Duration(milliseconds: 300);
  final Duration kCharacterAnimationInterval = Duration(seconds: 2);

  // 2. Variáveis de instância privadas
  bool _isSplashScreenVisible = true;
  int _currentCharacterSpriteIndex = 0;
  late async.Timer _characterAnimationTimer;

  // 3. Lista de animações (constante)
  late final List<Future<SpriteAnimation>> _characterSpriteAnimations = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  // 4. Métodos de ciclo de vida
  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  // 6. Event Handlers (agrupados)
  /// Handles splash screen completion event
  void _onSplashScreenCompleted(BuildContext context) {
    setState(() {
      _isSplashScreenVisible = false;
    });
    _initializeCharacterAnimation();
  }

  /// Handles control method selection changes
  void _onControlMethodChanged(bool selectedValue) {
    setState(() {
      Gameplay.useJoystickControls = selectedValue;
    });
  }

  // 7. Métodos de navegação
  /// Navigates to the main gameplay screen
  void _navigateToGameplayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Gameplay()),
    );
  }

  // 8. Métodos de gerenciamento de animação
  /// Initializes the character sprite animation timer
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

  // 9. Métodos utilitários
  /// Cleanup method to properly dispose resources
  void _cleanupResources() {
    GameplayAudioManager.stopBackgroundMusic();
    _characterAnimationTimer.cancel();
  }

  /// Opens external URLs in the default browser
  async.Future<void> _openExternalURL(String targetUrl) async {
    final parsedUri = Uri.parse(targetUrl);
    if (await canLaunchUrl(parsedUri)) {
      await launchUrl(parsedUri);
    } else {
      throw 'Could not launch $targetUrl';
    }
  }
}

/// State management for the menu screen following CLAUDE.md patterns
/// Handles splash screen transitions and character sprite animations
///
/// This screen manages:
/// - Splash screen display and transition
/// - Character animation carousel
/// - Control method selection (keyboard/joystick)
/// - Navigation to gameplay screen
class _MenuScreenState extends MenuScreenViewModel {
  // 5. Métodos de build
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kAnimationDuration,
      child: _isSplashScreenVisible ? _createSplashScreen() : _createMainMenu(),
    );
  }

  /// Creates the main menu interface
  Widget _createMainMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _TitleWidget(),
              const SizedBox(height: 20),
              if (_characterSpriteAnimations.isNotEmpty)
                _CharacterAnimationWidget(
                  animation:
                      _characterSpriteAnimations[_currentCharacterSpriteIndex],
                ),
              const SizedBox(height: 30),
              _PlayButtonWidget(onPressed: _navigateToGameplayScreen),
              const SizedBox(height: 20),
              _ControlsWidget(onControlMethodChanged: _onControlMethodChanged),
              const SizedBox(height: 20),
              if (!Gameplay.useJoystickControls) const _KeyboardTipWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _FooterWidget(onOpenURL: _openExternalURL),
    );
  }

  /// Creates the splash screen interface
  Widget _createSplashScreen() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: _onSplashScreenCompleted,
    );
  }
}

// ========================================
// PRIVATE WIDGETS FOR PERFORMANCE OPTIMIZATION
// ========================================

/// Private widget for the main title display
/// Uses const constructor for optimal performance
class _TitleWidget extends StatelessWidget {
  const _TitleWidget();

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

/// Private widget for character animation display
/// Optimized to prevent unnecessary rebuilds
class _CharacterAnimationWidget extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const _CharacterAnimationWidget({required this.animation});

  @override
  Widget build(BuildContext context) {
    final double kCharacterAnimationSize = 100.0;

    return SizedBox(
      height: kCharacterAnimationSize,
      width: kCharacterAnimationSize,
      child: AppAnimatedSpriteWidget(animation: animation),
    );
  }
}

/// Private widget for the play button
/// Uses const constructor where possible for performance
class _PlayButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButtonWidget({required this.onPressed});

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
        AppBar(),
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
              getString('play_cap'),
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

/// Private widget for control method selection
/// Encapsulates radio button logic for cleaner code
class _ControlsWidget extends StatelessWidget {
  final void Function(bool) onControlMethodChanged;

  const _ControlsWidget({required this.onControlMethodChanged});

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

/// Private widget for keyboard controls tip display
/// Const widget for maximum performance
class _KeyboardTipWidget extends StatelessWidget {
  const _KeyboardTipWidget();

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

/// Private widget for footer links and credits
/// Optimized to prevent unnecessary rebuilds
class _FooterWidget extends StatelessWidget {
  final Future<void> Function(String) onOpenURL;

  const _FooterWidget({required this.onOpenURL});

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
                    getString('powered_by'),
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
                    getString('built_with'),
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
