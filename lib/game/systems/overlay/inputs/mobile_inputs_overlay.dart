/// **MobileInputsOverlay - COMPLETO E MIGRADO**
/// • Usa o novo OverlayDesignSystem
/// • Remove ResponsiveOverlayData
/// • Corrige erro de isMobileScreen
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/overlay/inputs/mobile_inputs_state.dart';

import 'package:dawnforge/game/systems/input_actions/joysctick_setup.dart';
import 'package:dawnforge/game/utils/app_environment.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system_extension.dart';
import 'package:dawnforge/shared/overlay_design_system/responsive_overlay_base.dart';
import 'package:flutter/material.dart';

/// Mobile touch inputs overlay with buttons for all game actions
final class MobileInputsOverlay extends ResponsiveOverlayBase {
  final PlayerController? playerController;

  const MobileInputsOverlay({super.key, this.playerController});

  @override
  String get overlayId => 'mobile_inputs';

  @override
  ValueNotifier<bool> get visibilityNotifier =>
      MobileInputsState.instance.isVisible;

  @override
  Widget buildOverlayContent(BuildContext context) {
    // 🔥 Acessa tokens uma única vez
    final sizes = context.ds.sizes;
    final spacing = context.ds.spacing;
    final screenHeight = context.overlayScreenDimensions.height;

    final buttonSize = sizes.actionButton;
    final utilityButtonSize = sizes.utilityButton;

    // Estima altura necessária (2 action buttons + utility buttons)
    final utilityButtonsCount = _countUtilityButtons();
    final estimatedHeight =
        (buttonSize * 2) + // Action buttons (apenas 2)
        spacing.spacing + // Spacing entre action buttons
        (utilityButtonSize * utilityButtonsCount) + // Utility buttons
        (spacing.spacing * (utilityButtonsCount - 1)) + // Spacing entre utility
        (spacing.margin * 2); // Margens

    final needsScroll = estimatedHeight > screenHeight * 0.8;

    // Botões alinhados à direita (sem Stack/Positioned)
    return Padding(
      padding: EdgeInsets.all(spacing.margin),
      child: needsScroll
          ? ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._buildUtilityButtons(context),
                    ..._buildActionButtons(context),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._buildUtilityButtons(context),
                ..._buildActionButtons(context),
              ],
            ),
    );
  }

  int _countUtilityButtons() {
    int count = 1; // Esc button
    if (AppEnvironment.kIsDebugMode) {
      count += 3; // Inv + Items + Clear
    }
    return count;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final sizes = context.ds.sizes;
    final spacing = context.ds.spacing;

    return [
      _buildActionButton(
        context: context,
        label: 'Interact',
        icon: Icons.touch_app,
        size: sizes.actionButton,
        actionId: JoystickSetup.kInteractionId,
        color: Colors.green,
      ),
      SizedBox(height: spacing.spacing),
      _buildActionButton(
        context: context,
        label: 'Run',
        icon: Icons.directions_run,
        size: sizes.actionButton,
        actionId: JoystickSetup.kRunId,
        color: Colors.blue,
      ),
    ];
  }

  List<Widget> _buildUtilityButtons(BuildContext context) {
    final sizes = context.ds.sizes;
    final spacing = context.ds.spacing;

    return [
      _buildActionButton(
        context: context,
        label: 'Esc',
        icon: Icons.settings,
        size: sizes.utilityButton,
        actionId: JoystickSetup.kToggleTutorialInputsId,
        color: Colors.brown,
      ),
      if (AppEnvironment.kIsDebugMode) ...[
        SizedBox(height: spacing.spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Inv',
          icon: Icons.backpack,
          size: sizes.utilityButton,
          actionId: JoystickSetup.kToggleInventoryId,
          color: Colors.brown,
        ),
        SizedBox(height: spacing.spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Items',
          icon: Icons.add_box,
          size: sizes.utilityButton,
          actionId: JoystickSetup.kAddTestItemsId,
          color: Colors.teal,
        ),
        SizedBox(height: spacing.spacing / 2),
        _buildActionButton(
          context: context,
          label: 'Clear',
          icon: Icons.delete_forever,
          size: sizes.utilityButton,
          actionId: JoystickSetup.kClearSaveId,
          color: Colors.red,
        ),
      ],
    ];
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
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
            Icon(icon, size: size * 0.4, color: Colors.white),
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
      JoystickActionEvent(id: actionId, event: event),
    );
  }
}
