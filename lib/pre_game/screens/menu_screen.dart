import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/pre_game/screens/menu_screen_def.dart';
import 'package:dawnforge/pre_game/screens/menu_screen_viewmodel.dart';
import 'package:dawnforge/game/systems/localization/gameplay_strings_location.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system_old/dd_design_system.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_radio_button.dart';
import 'package:dawnforge/shared/framework/widgets/dd_sprite_animation_widget.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';
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
      duration: MenuScreenDef.kCharacterAnimationDuration,
      child: isSplashScreenVisible ? _createSplashScreen() : _createMainMenu(),
    );
  }

  Widget _createMainMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DDDesignSystem.kSpacingLarge,
            runSpacing: DDDesignSystem.kSpacingLarge,
            children: <Widget>[
              const _Title(),
              if (MenuScreenDef.characterSpriteAnimations.isNotEmpty) ...[
                _CharacterAnimation(
                  animation: MenuScreenDef
                      .characterSpriteAnimations[currentCharacterSpriteIndex],
                ),
              ],
              _Controls(
                onControlMethodChanged: onControlMethodChanged,
              ), // TODO(Kevin): NOW - put it back
              switch (SettingsManager.instance.inputSelected) {
                InputActionsType.joystick =>
                  const SizedBox.shrink(), // TODO(Kevin): Replace with joystick tip widget
                InputActionsType.keyboard => const _KeyboardTip(),
              },
              _StartButton(onPressed: navigateToGameplayScreen),
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
    return Text(
      'Greenleaf Valley',
      style: TextStyle(
        color: Colors.white,
        fontSize: AppDesignSystem.of(
          context,
        ).typography.fontSizeDisplay,
      ),
    );
  }
}

class _CharacterAnimation extends StatelessWidget {
  const _CharacterAnimation({required this.animation});
  final Future<SpriteAnimation> animation;

  @override
  Widget build(BuildContext context) {
    return DDSpriteAnimationWidget.large(animation: animation);
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});
  final VoidCallback onPressed;

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
            backgroundColor: Colors.blue,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: const Size(100, 40),
          ),
          onPressed: onPressed,
          child: Text(
            GameplayStringsLocation.instance.getString('play_cap'),
            style: TextStyle(
              color: Colors.white,

              fontSize: AppDesignSystem.of(
                context,
              ).typography.fontSizeCaption,
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.onControlMethodChanged});

  final void Function(InputActionsType) onControlMethodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: DDDesignSystem.kSpacingExtraSmall,
      children: [
        DDRadioButton<InputActionsType>(
          value: InputActionsType.keyboard,
          label: 'Keyboard',
          group: SettingsManager.instance.inputSelected,
          onChange: onControlMethodChanged,
        ),
        DDRadioButton<InputActionsType>(
          // TODO(Kevin): NOW - put it back
          value: InputActionsType.joystick,
          group: SettingsManager.instance.inputSelected,
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
    return const SizedBox.shrink();
    // return DDSpriteWidget.extraLarge(sprite: MenuScreenDef.keyboardSprite); // TODO(Kevin): NOW - put it back
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onOpenURL});
  final Future<void> Function(String) onOpenURL;

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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDesignSystem.of(
                        context,
                      ).typography.fontSizeTiny,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(MenuScreenDef.kKevinKoboriUrl);
                    },
                    child: Text(
                      'kevinkobori',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: AppDesignSystem.of(
                          context,
                        ).typography.fontSizeTiny,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDesignSystem.of(
                        context,
                      ).typography.fontSizeTiny,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onOpenURL(MenuScreenDef.kBonfireUrl);
                    },
                    child: Text(
                      'Bonfire',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: AppDesignSystem.of(
                          context,
                        ).typography.fontSizeTiny,
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
