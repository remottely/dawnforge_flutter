import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/mobile_inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/equipment_state.dart';
import 'package:flutter/material.dart';

/// Overlay for joystick action buttons (primary and secondary attacks)
class JoystickActionsOverlay extends ResponsiveOverlayBase {
  final PlayerController? playerController;

  const JoystickActionsOverlay({super.key, this.playerController});

  @override
  String get overlayId => 'joystick_actions';

  @override
  ValueNotifier<bool> get visibilityNotifier =>
      MobileInputsState.instance.isVisible;

  @override
  OverlayPosition getOverlayPosition(BuildContext context) {
    return OverlayPosition.custom(
      alignment: Alignment.bottomRight,
      safeAreaPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget buildOverlayContent(BuildContext context, ResponsiveOverlayData data) {
    return ValueListenableBuilder<Item?>(
      valueListenable: EquipmentState.instance.equippedItem,
      builder: (context, equippedItem, _) {
        final hasIronSword = equippedItem?.id == 'ironSword';

        return Padding(
          padding: EdgeInsets.all(data.margin),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Secondary attack button - only visible with ironSword
              if (hasIronSword) ...[
                _buildActionButton(
                  context: context,
                  actionId: JoystickSetup.kInteractionId,
                  assetPath: 'assets/images/joystick/joystick_ranged_attack_default.png',
                  assetPathPressed: 'assets/images/joystick/joystick_ranged_attack_pressed.png',
                  size: JoystickSetup.kActionButtonSize,
                  marginBottom: JoystickSetup.kActionButtonMarginBottom,
                ),
                SizedBox(width: data.spacing),
              ],
              // Primary attack button - always visible
              _buildActionButton(
                context: context,
                actionId: JoystickSetup.kPrimaryActionId,
                assetPath: 'assets/images/joystick/joystick_melee_attack_default.png',
                assetPathPressed: 'assets/images/joystick/joystick_melee_attack_pressed.png',
                size: JoystickSetup.kActionButtonSize,
                marginBottom: JoystickSetup.kActionButtonMarginBottom,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String actionId,
    required String assetPath,
    required String assetPathPressed,
    required double size,
    required double marginBottom,
  }) {
    return GestureDetector(
      onTapDown: (_) => _sendAction(actionId, ActionEvent.DOWN),
      onTapUp: (_) => _sendAction(actionId, ActionEvent.UP),
      onTapCancel: () => _sendAction(actionId, ActionEvent.UP),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  void _sendAction(String actionId, ActionEvent event) {
    if (playerController == null) return;

    playerController!.onJoystickAction(
      JoystickActionEvent(id: actionId, event: event),
    );
  }
}
