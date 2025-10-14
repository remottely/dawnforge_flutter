import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_animated_sprite_widget.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_radio_button.dart';
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

/// State management for the menu screen following CLAUDE.md patterns
/// Handles splash screen transitions and character sprite animations
///
/// This screen manages:
/// - Splash screen display and transition
/// - Character animation carousel
/// - Control method selection (keyboard/joystick)
/// - Navigation to gameplay screen
class _MenuScreenState extends State<MenuScreen> {
  // 1. Constantes (agrupadas por tipo)
  static const Duration kAnimationDuration = Duration(milliseconds: 300);
  static const Duration kCharacterAnimationInterval = Duration(seconds: 2);
  static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';
  static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const double kTitleFontSize = 30.0;
  static const double kButtonFontSize = 16.0;
  static const double kFooterFontSize = 12.0;
  static const double kCharacterAnimationSize = 100.0;
  static const double kButtonWidth = 150.0;
  static const double kButtonMinHeight = 40.0;
  static const double kKeyboardTipHeight = 80.0;
  static const double kKeyboardTipWidth = 200.0;

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
              const Text(
                'Darkness Dungeon',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Normal',
                  fontSize: kTitleFontSize,
                ),
              ),
              const SizedBox(height: 20),
              if (_characterSpriteAnimations.isNotEmpty)
                SizedBox(
                  height: kCharacterAnimationSize,
                  width: kCharacterAnimationSize,
                  child: AppAnimatedSpriteWidget(
                    animation:
                        _characterSpriteAnimations[_currentCharacterSpriteIndex],
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: kButtonWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(100, kButtonMinHeight),
                  ),
                  child: Text(
                    getString('play_cap'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: kButtonFontSize,
                    ),
                  ),
                  onPressed: () {
                    _navigateToGameplayScreen();
                  },
                ),
              ),
              const SizedBox(height: 20),
              AppRadioButton<bool>(
                value: false,
                label: 'Keyboard',
                group: Gameplay.useJoystickControls,
                onChange: _onControlMethodChanged,
              ),
              const SizedBox(height: 10),
              AppRadioButton<bool>(
                value: true,
                group: Gameplay.useJoystickControls,
                label: 'Joystick',
                onChange: _onControlMethodChanged,
              ),
              const SizedBox(height: 20),
              if (!Gameplay.useJoystickControls)
                SizedBox(
                  height: kKeyboardTipHeight,
                  width: kKeyboardTipWidth,
                  child: Sprite.load('keyboard_tip.png').asWidget(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                        fontFamily: 'Normal',
                        fontSize: kFooterFontSize,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openExternalURL(kKevinKoboriUrl);
                      },
                      child: const Text(
                        'kevinkobori',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: kFooterFontSize,
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
                        fontFamily: 'Normal',
                        fontSize: kFooterFontSize,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openExternalURL(kBonfireUrl);
                      },
                      child: const Text(
                        'Bonfire',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: kFooterFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the splash screen interface
  Widget _createSplashScreen() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: _onSplashScreenCompleted,
    );
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
