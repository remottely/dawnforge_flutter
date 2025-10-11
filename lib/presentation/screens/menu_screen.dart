import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/strings_location.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:darkness_dungeon/gameplay/utils/audio/sound_manager.dart';
import 'package:darkness_dungeon/gameplay/utils/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/animated_sprite_widget.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/app_radio_button.dart';
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

/// State management for the menu screen
/// Handles splash screen transitions and character sprite animations
class _MenuScreenState extends State<MenuScreen> {
  // UI State Variables
  bool _isSplashScreenVisible = true;
  int _currentCharacterSpriteIndex = 0;
  late async.Timer _characterAnimationTimer;

  // Character sprite animations for showcase
  final List<Future<SpriteAnimation>> _characterSpriteAnimations = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Cleanup method to properly dispose resources
  void _cleanupResources() {
    SoundManager.stopBackgroundMusic();
    _characterAnimationTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
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
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              if (_characterSpriteAnimations.isNotEmpty)
                SizedBox(
                  height: 100,
                  width: 100,
                  child: AnimatedSpriteWidget(
                    animation:
                        _characterSpriteAnimations[_currentCharacterSpriteIndex],
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(100, 40), //////// HERE
                  ),
                  child: Text(
                    getString('play_cap'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: 17,
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
                  height: 80,
                  width: 200,
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
                        fontSize: 12,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openExternalURL('https://github.com/kevinkobori');
                      },
                      child: const Text(
                        'kevinkobori',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12,
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
                        fontSize: 12,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openExternalURL('https://pub.dev/packages/bonfire');
                      },
                      child: const Text(
                        'Bonfire',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12,
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

  // Event Handlers

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

  /// Navigates to the main gameplay screen
  void _navigateToGameplayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Gameplay()),
    );
  }

  // Animation Management

  /// Initializes the character sprite animation timer
  void _initializeCharacterAnimation() {
    _characterAnimationTimer = async.Timer.periodic(
      const Duration(seconds: 2),
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

  // External URL Management

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
