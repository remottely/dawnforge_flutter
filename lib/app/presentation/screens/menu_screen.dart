import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/app/presentation/screens/menu_screen_config.dart';
import 'package:darkness_dungeon/app/presentation/screens/menu_screen_viewmodel.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/shared/components/dd_sprite_animation_widget.dart';
import 'package:darkness_dungeon/shared/components/dd_sprite_widget.dart';
import 'package:darkness_dungeon/shared/design_system/components/atoms/dd_radio_button.dart';
import 'package:darkness_dungeon/shared/design_system/dd_design_system.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends MenuScreenViewModel {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MenuScreenConfig.kCharacterAnimationDuration,
      child: isSplashScreenVisible ? _createSplashScreen() : _createMainMenu(),
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
              if (MenuScreenConfig.characterSpriteAnimations.isNotEmpty) ...[
                _CharacterAnimation(
                  animation: MenuScreenConfig
                      .characterSpriteAnimations[currentCharacterSpriteIndex],
                ),
              ],
              _StartButton(onPressed: navigateToGameplayScreen),
              _Controls(onControlMethodChanged: onControlMethodChanged),
              switch (SettingsManager.instance.vIsJoystickInputSelected) {
                InputActionsType.joystick =>
                  const SizedBox.shrink(), // TODO(Kevin): Replace with joystick tip widget
                InputActionsType.keyboard => _KeyboardTip(),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: _Footer(onOpenURL: openExternalURL),
    );
  }

  Widget _createSplashScreen() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: onSplashScreenCompleted,
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
        DDRadioButton<InputActionsType>(
          value: InputActionsType.keyboard,
          label: 'Keyboard',
          group: SettingsManager.instance.vIsJoystickInputSelected,
          onChange: onControlMethodChanged,
        ),
        DDRadioButton<InputActionsType>(
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
    return DDSpriteWidget.extraLarge(sprite: MenuScreenConfig.keyboardSprite);
  }
}

class _Footer extends StatelessWidget {
  final Future<void> Function(String) onOpenURL;

  const _Footer({required this.onOpenURL});

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
                      onOpenURL(MenuScreenConfig.kKevinKoboriUrl);
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
                      onOpenURL(MenuScreenConfig.kBonfireUrl);
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
