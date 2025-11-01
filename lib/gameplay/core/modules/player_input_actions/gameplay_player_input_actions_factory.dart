import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/player_input_actions/gameplay_player_input_actions_config.dart';
import 'package:flutter/material.dart';

class GameplayPlayerInputActionsFactory {
  static bool isJoystickInputSelected =
      false; // TODO(Kevin): now, change this logic

  static PlayerController createPlayerInput() =>
      isJoystickInputSelected ? _createJoystickInput() : _createKeyboardInput();

  static PlayerController _createJoystickInput() {
    return Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: GameplayPlayerInputActionsConfig.kJoystickComponentSize,
        isFixed: false,
      ),
      actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
    );
  }

  static JoystickAction _createPrimaryAttackAction() {
    return JoystickAction(
      actionId: GameplayPlayerInputActionsConfig.kJoystickPrimaryAttackId,
      sprite: Sprite.load('joystick_attack.png'),
      spritePressed: Sprite.load('joystick_attack_selected.png'),
      size: GameplayPlayerInputActionsConfig.kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: GameplayPlayerInputActionsConfig.kActionButtonMarginBottom,
        right: GameplayPlayerInputActionsConfig.kPrimaryActionMarginRight,
      ),
    );
  }

  static JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: GameplayPlayerInputActionsConfig.kJoystickFireballAttackId,
      sprite: Sprite.load('joystick_attack_range.png'),
      spritePressed: Sprite.load('joystick_attack_range_selected.png'),
      size: GameplayPlayerInputActionsConfig.kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: GameplayPlayerInputActionsConfig.kActionButtonMarginBottom,
        right: GameplayPlayerInputActionsConfig.kSecondaryActionMarginRight,
      ),
    );
  }

  static PlayerController _createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys:
            GameplayPlayerInputActionsConfig.fKeyboardDirectionalKeys,
        acceptedKeys: GameplayPlayerInputActionsConfig.fKeyboardAcceptedKeys,
      ),
    );
  }
}
