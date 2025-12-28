import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/mobile_inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:flutter/material.dart';

/// Mobile touch inputs overlay with buttons for all game actions
class MobileInputsOverlay extends ResponsiveOverlayBase {
  final PlayerController? playerController;

  const MobileInputsOverlay({
    super.key,
    this.playerController,
  });

  @override
  String get overlayId => 'mobile_inputs';

  @override
  ValueNotifier<bool> get visibilityNotifier =>
      MobileInputsState.instance.isVisible;

  @override
  OverlayPosition getOverlayPosition(BuildContext context) {
    return OverlayPosition.custom(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      alignment: Alignment.center,
      safeAreaPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget buildOverlayContent(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    return Stack(
      children: [
        // Right side - Action buttons
        Positioned(
          right: data.margin,
          top: MediaQuery.of(context).size.height * 0.3,
          child: _buildActionButtons(context, data),
        ),
        // Left side - Equipment buttons
        Positioned(
          left: data.margin,
          top: MediaQuery.of(context).size.height * 0.3,
          child: _buildEquipmentButtons(context, data),
        ),
        // Top right - Utility buttons
        Positioned(
          right: data.margin,
          top: data.margin * 3,
          child: _buildUtilityButtons(context, data),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ResponsiveOverlayData data) {
    final buttonSize = data.isSmallScreen ? 50.0 : 60.0;
    final spacing = data.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildActionButton(
          context: context,
          label: 'Interact',
          icon: Icons.touch_app,
          size: buttonSize,
          actionId: JoystickSetup.kInteractionId,
          color: Colors.green,
        ),
        SizedBox(height: spacing),
        _buildActionButton(
          context: context,
          label: 'Run',
          icon: Icons.directions_run,
          size: buttonSize,
          actionId: JoystickSetup.kRunId,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildEquipmentButtons(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    final buttonSize = data.isSmallScreen ? 45.0 : 55.0;
    final spacing = data.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildActionButton(
              context: context,
              label: 'Prev',
              icon: Icons.arrow_back_ios,
              size: buttonSize,
              actionId: JoystickSetup.kEquipMainHandReverseId,
              color: Colors.orange,
            ),
            SizedBox(width: spacing / 2),
            _buildActionButton(
              context: context,
              label: 'Next',
              icon: Icons.arrow_forward_ios,
              size: buttonSize,
              actionId: JoystickSetup.kEquipMainHandId,
              color: Colors.orange,
            ),
          ],
        ),
        SizedBox(height: spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Unequip',
          icon: Icons.close,
          size: buttonSize,
          actionId: JoystickSetup.kUnequipMainHandId,
          color: Colors.red.shade300,
        ),
      ],
    );
  }

  Widget _buildUtilityButtons(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    final buttonSize = data.isSmallScreen ? 40.0 : 50.0;
    final spacing = data.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildActionButton(
          context: context,
          label: 'Esc',
          icon: Icons.settings,
          size: buttonSize,
          actionId: JoystickSetup.kToggleTutorialInputsId,
          color: Colors.brown,
        ),
        _buildActionButton(
          context: context,
          label: 'Inv',
          icon: Icons.backpack,
          size: buttonSize,
          actionId: JoystickSetup.kToggleInventoryId,
          color: Colors.brown,
        ),
        SizedBox(height: spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Next Day',
          icon: Icons.wb_sunny,
          size: buttonSize,
          actionId: JoystickSetup.kAdvanceDayId,
          color: Colors.amber,
        ),
        SizedBox(height: spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Items',
          icon: Icons.add_box,
          size: buttonSize,
          actionId: JoystickSetup.kAddTestItemsId,
          color: Colors.teal,
        ),
        SizedBox(height: spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Clear',
          icon: Icons.delete_forever,
          size: buttonSize,
          actionId: JoystickSetup.kClearSaveId,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double size,
    required String actionId,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: (_) => _sendAction(actionId, ActionEvent.DOWN),
      onTapUp: (_) => _sendAction(actionId, ActionEvent.UP),
      onTapCancel: () => _sendAction(actionId, ActionEvent.UP),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(size * 0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: size * 0.4,
              color: Colors.white,
            ),
            if (label.isNotEmpty && size > 45)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _sendAction(String actionId, ActionEvent event) {
    if (playerController == null) return;

    playerController!.onJoystickAction(
      JoystickActionEvent(
        id: actionId,
        event: event,
      ),
    );
  }
}
