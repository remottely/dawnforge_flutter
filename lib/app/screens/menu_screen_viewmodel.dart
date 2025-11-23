import 'dart:async' as async;

import 'package:darkness_dungeon/app/screens/menu_screen.dart';
import 'package:darkness_dungeon/app/screens/menu_screen_config.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class MenuScreenViewModel extends State<MenuScreen> {
  bool isSplashScreenVisible = true;
  int currentCharacterSpriteIndex = 0;
  late async.Timer _characterAnimationTimer;

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _initializeCharacterAnimation() {
    _characterAnimationTimer = async.Timer.periodic(
      MenuScreenConfig.kCharacterAnimationInterval,
      (timer) {
        setState(() {
          currentCharacterSpriteIndex++;
          if (currentCharacterSpriteIndex >
              MenuScreenConfig.characterSpriteAnimations.length - 1) {
            currentCharacterSpriteIndex = 0;
          }
        });
      },
    );
  }

  void _cleanupResources() {
    // NÃO para a música - deixa o AudioManager gerenciar entre telas
    _characterAnimationTimer.cancel();
  }

  void onSplashScreenCompleted(BuildContext context) {
    setState(() {
      isSplashScreenVisible = false;
    });
    _initializeCharacterAnimation();
  }

  void onControlMethodChanged(InputActionsType selectedInput) {
    setState(() {
      SettingsManager.instance.setInputSelected(selectedInput);
    });
  }

  void navigateToGameplayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameplayScreen()),
    );
  }

  Future<void> openExternalURL(String targetUrl) async {
    final parsedUri = Uri.parse(targetUrl);
    if (await canLaunchUrl(parsedUri)) {
      await launchUrl(parsedUri);
    } else {
      throw 'Could not launch $targetUrl';
    }
  }
}
