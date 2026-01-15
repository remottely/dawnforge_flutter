faça a migracao dessas classes para utilizar a nova base de codigo:
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/mobile_inputs_state.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:dawnforge/gameplay/inventory/entities/hand_item.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/gameplay/inventory/state/equipment_state.dart';
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
    return ValueListenableBuilder<HandItem?>(
      valueListenable: EquipmentState.instance.equippedItem,
      builder: (context, equippedItem, _) {
        final hasIronSword = equippedItem?.id == HandItemId.ironSword;

        return Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Secondary attack button - only visible with ironSword
              if (hasIronSword) ...[
                _buildActionButton(
                  context: context,
                  actionId: JoystickSetup.kInteractionId,
                  assetPath:
                      'assets/images/joystick/joystick_ranged_attack_default.png',
                  assetPathPressed:
                      'assets/images/joystick/joystick_ranged_attack_pressed.png',
                  size: JoystickSetup.kActionButtonSize,
                  marginBottom: JoystickSetup.kActionButtonMarginBottom,
                ),
                SizedBox(width: data.spacing),
              ],
              // Primary attack button - always visible
              _buildActionButton(
                context: context,
                actionId: JoystickSetup.kPrimaryActionId,
                assetPath:
                    'assets/images/joystick/joystick_melee_attack_default.png',
                assetPathPressed:
                    'assets/images/joystick/joystick_melee_attack_pressed.png',
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
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/mobile_inputs_state.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:dawnforge/gameplay/core/utils/app_environment.dart';
import 'package:dawnforge/overlay_design_system_extension.dart';
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
  OverlayPosition getOverlayPosition(BuildContext context) {
    return OverlayPosition.bottomRight(safeAreaPadding: EdgeInsets.zero);
  }

  @override
  Widget buildOverlayContent(BuildContext context, ResponsiveOverlayData data) {
    // 🔥 Acessa tokens uma única vez
    final sizes = context.overlaySizes;
    final spacing = context.overlaySpacing;
    final screenHeight = context.overlayScreenDimensions.height;

    final buttonSize = sizes.actionButton;
    final utilityButtonSize = sizes.utilityButton;

    // // Calcula a altura total necessária para os botões
    // final buttonSize = data.isMobileScreen ? 50.0 : 60.0;
    // final utilityButtonSize = data.isMobileScreen ? 40.0 : 50.0;
    // final spacing = data.spacing;

    // Estima altura necessária (3 action buttons + utility buttons)
    final utilityButtonsCount = _countUtilityButtons();
    final estimatedHeight =
        (buttonSize * 3) + // Action buttons
        (spacing.spacing * 2) + // Spacing entre action buttons
        (utilityButtonSize * utilityButtonsCount) + // Utility buttons
        (spacing.spacing /
            2 *
            (utilityButtonsCount - 1)) + // Spacing entre utility buttons
        (data.margin * 2); // Margens

    // final screenHeight = MediaQuery.of(context).size.height;
    final needsScroll = estimatedHeight > screenHeight * 0.8;

    // Botões alinhados à direita (sem Stack/Positioned)
    return Padding(
      padding: EdgeInsets.all(data.margin),
      child: needsScroll
          ? ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._buildUtilityButtons(context, data),
                    ..._buildActionButtons(context, data),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._buildUtilityButtons(context, data),
                ..._buildActionButtons(context, data),
              ],
            ),
    );
  }

  int _countUtilityButtons() {
    int count = 1; // Esc button sempre visível
    if (AppEnvironment.kIsDebugMode) count++; // Inv button
    count++; // Next Day button
    if (AppEnvironment.kIsDebugMode) {
      count++; // Items button
      count++; // Clear button
    }
    return count;
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    final buttonSize = data.isMobileScreen ? 50.0 : 60.0;
    final spacing = data.spacing;

    return [
      _buildActionButton(
        context: context,
        label: 'Interact',
        icon: Icons.touch_app,
        size: buttonSize,
        actionId: JoystickSetup.kInteractionId,
        color: Colors.green,
      ),
      SizedBox(height: spacing),
      // _buildActionButton(
      //   context: context,
      //   label: 'Defense', // 'Secondary'
      //   icon: Icons.auto_awesome,
      //   size: buttonSize,
      //   actionId: JoystickSetup.kSecondaryActionId,
      //   color: Colors.purple,
      // ),
      // SizedBox(height: spacing),
      _buildActionButton(
        context: context,
        label: 'Run',
        icon: Icons.directions_run,
        size: buttonSize,
        actionId: JoystickSetup.kRunId,
        color: Colors.blue,
      ),
    ];
  }

  // Widget _buildEquipmentButtons(
  //   BuildContext context,
  //   ResponsiveOverlayData data,
  // ) {
  //   final buttonSize = data.isMobileScreen ? 45.0 : 55.0;
  //   final spacing = data.spacing;

  //   return
  //   // Column(
  //   //   mainAxisSize: MainAxisSize.min,
  //   //   crossAxisAlignment: CrossAxisAlignment.start,
  //   //   children: [
  //   Row(
  //     children: [
  //       _buildActionButton(
  //         context: context,
  //         label: 'Prev',
  //         icon: Icons.arrow_back_ios,
  //         size: buttonSize,
  //         actionId: JoystickSetup.kEquipMainHandReverseId,
  //         color: Colors.orange,
  //       ),
  //       SizedBox(width: spacing / 2),
  //       _buildActionButton(
  //         context: context,
  //         label: 'Next',
  //         icon: Icons.arrow_forward_ios,
  //         size: buttonSize,
  //         actionId: JoystickSetup.kEquipMainHandId,
  //         color: Colors.orange,
  //       ),
  //     ],
  //     // ),
  //     // SizedBox(height: spacing / 2),
  //     // _buildActionButton(
  //     //   context: context,
  //     //   label: 'Unequip',
  //     //   icon: Icons.close,
  //     //   size: buttonSize,
  //     //   actionId: JoystickSetup.kUnequipMainHandId,
  //     //   color: Colors.red.shade300,
  //     // ),
  //     // ],
  //   );
  // }

  List<Widget> _buildUtilityButtons(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    final buttonSize = data.isMobileScreen ? 40.0 : 50.0;
    final spacing = data.spacing;

    return [
      _buildActionButton(
        context: context,
        label: 'Esc',
        icon: Icons.settings,
        size: buttonSize,
        actionId: JoystickSetup.kToggleTutorialInputsId,
        color: Colors.brown,
      ),
      AppEnvironment.kIsDebugMode
          ? _buildActionButton(
              context: context,
              label: 'Inv',
              icon: Icons.backpack,
              size: buttonSize,
              actionId: JoystickSetup.kToggleInventoryId,
              color: Colors.brown,
            )
          : SizedBox.shrink(),
      // SizedBox(height: spacing / 2),
      // _buildActionButton(
      //   context: context,
      //   label: 'Next Day',
      //   icon: Icons.wb_sunny,
      //   size: buttonSize,
      //   actionId: JoystickSetup.kAdvanceDayId,
      //   color: Colors.amber,
      // ),
      SizedBox(height: spacing / 2),
      if (AppEnvironment.kIsDebugMode) ...[
        _buildActionButton(
          context: context,
          label: 'Items',
          icon: Icons.add_box,
          size: buttonSize,
          actionId: JoystickSetup.kAddTestItemsId,
          color: Colors.teal,
        ),
        SizedBox(height: spacing / 2),
      ],
      AppEnvironment.kIsDebugMode
          ? _buildActionButton(
              context: context,
              label: 'Clear',
              icon: Icons.delete_forever,
              size: buttonSize,
              actionId: JoystickSetup.kClearSaveId,
              color: Colors.red,
            )
          : SizedBox.shrink(),
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
import 'package:dawnforge/app/screens/menu_screen.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_hud_def.dart';
import 'package:dawnforge/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_state.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:dawnforge/shared/managers/settings_manager.dart';
import 'package:flutter/material.dart';

class TutorialInputsOverlay extends ResponsiveOverlayBase {
  const TutorialInputsOverlay({super.key});

  @override
  String get overlayId => 'tutorial_inputs';

  @override
  ValueNotifier<bool> get visibilityNotifier =>
      TutorialInputsState.instance.isVisible;

  @override
  OverlayPosition getOverlayPosition(BuildContext context) {
    final margin = getResponsiveMargin(context);
    return OverlayPosition.bottomLeft(
      margin: margin,
      safeAreaPadding: EdgeInsets.all(margin / 2),
    );
  }

  @override
  Widget buildOverlayContent(BuildContext context, ResponsiveOverlayData data) {
    final keyBoxWidth = valueByScreenSize(
      context,
      mobile: 80.0,
      tablet: 96.0,
      desktop: 120.0,
    );

    final isKeyboardMode =
        SettingsManager.instance.inputSelected == InputActionsType.keyboard;

    return Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.all(data.padding),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(data.isMobileScreen ? 6 : 8),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToMainMenu(context),
                  child: const Text('Sair para Menu Principal'),
                ),
                if (isKeyboardMode)
                  ...List.generate(
                    TutorialInputsHUDDef.inputGuide.length,
                    (index) => _buildInputRow(
                      context,
                      data,
                      TutorialInputsHUDDef.inputGuide[index]['key']!,
                      TutorialInputsHUDDef.inputGuide[index]['desc']!,
                      keyBoxWidth,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context,
    ResponsiveOverlayData data,
    String key,
    String description,
    double keyBoxWidth,
  ) {
    final rowHeight = valueByScreenSize(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 26.0,
    );

    final keyBoxHeight = valueByScreenSize(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    return Container(
      height: rowHeight,
      margin: EdgeInsets.only(bottom: data.spacing / 2),
      child: Row(
        children: [
          Container(
            width: keyBoxWidth,
            height: keyBoxHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(data.isMobileScreen ? 3 : 4),
            ),
            padding: EdgeInsets.symmetric(horizontal: data.spacing),
            alignment: Alignment.centerLeft,
            child: Text(
              key,
              style: TextStyle(
                color: const Color(0xFF00FFAA),
                fontWeight: FontWeight.bold,
                fontSize: data.baseFontSize - 1,
                fontFamily: 'Normal',
              ),
            ),
          ),
          SizedBox(width: data.spacing * 1.5),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: data.baseFontSize,
                fontFamily: 'Normal',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMainMenu(BuildContext context) {
    AudioManager.instance.stopBackgroundMusic();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_widget.dart';
import 'package:dawnforge/gameplay/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:dawnforge/gameplay/inventory/widgets/inventory_overlay.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/gameplay/market/widgets/market_panel.dart';
import 'package:dawnforge/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/debug/debug_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/widgets/mobile_inputs_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/widgets/joystick_actions_overlay.dart';
import 'package:dawnforge/gameplay/core/modules/hud/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/managers/settings_manager.dart';
import 'package:dawnforge/gameplay/time/time_manager.dart' as new_time;
import 'package:dawnforge/gameplay/time/widgets/time_hud_panel.dart';
import 'package:dawnforge/shared/utils/debug_helpers.dart';
import 'package:flutter/material.dart';

/// Overlay unificado que organiza todos os componentes da HUD em um grid 3x3
/// Grid com proporções: coluna 1 (flex 1), coluna 2 (flex 2), coluna 3 (flex 1)
/// Linha 1 (flex 1), Linha 2 (flex 2), Linha 3 (flex 1)
final class UnifiedGameOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const UnifiedGameOverlay({
    super.key,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopScreen(context);
    
    const flexA = 1;
    const flexB = 6;
    const flexC = flexA + flexB;

    return IgnorePointer(
      ignoring: false,
      child: Row(
        children: [
          _LeftArea(
            flex: flexA,
            isDesktop: isDesktop,
          ),
          _MainArea(
            flex: flexC,
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área lateral esquerda - Inventário mobile
final class _LeftArea extends StatelessWidget {
  final int flex;
  final bool isDesktop;

  const _LeftArea({
    required this.flex,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayLeftArea,
        child: Container(
          alignment: Alignment.centerLeft,
          child: !isDesktop
              ? const InventoryOverlay()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Área principal que contém as 3 linhas (top, middle, bottom)
final class _MainArea extends StatelessWidget {
  final int flex;
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _MainArea({
    required this.flex,
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          _TopRow(
            flexA: flexA,
            flexB: flexB,
            player: player,
          ),
          _MiddleRow(
            flexA: flexA,
            flexB: flexB,
            playerController: playerController,
          ),
          _BottomRow(
            flexA: flexA,
            flexB: flexB,
            isDesktop: isDesktop,
            player: player,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Linha superior (Top Row)
final class _TopRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final DDBasePlayerView player;

  const _TopRow({
    required this.flexA,
    required this.flexB,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA,
      child: Row(
        children: [
          _TopCenterArea(
            flex: flexB,
            player: player,
          ),
          _TopRightArea(flex: flexA),
        ],
      ),
    );
  }
}

/// Área central superior - Debug e Mensagens
final class _TopCenterArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;

  const _TopCenterArea({
    required this.flex,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopCenterArea,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            DebugOverlay(player: player),
            const SizedBox(width: 8),
            const OverlayMessageWidget(),
          ],
        ),
      ),
    );
  }
}

/// Área direita superior - Tempo e Fullscreen
final class _TopRightArea extends StatelessWidget {
  final int flex;

  const _TopRightArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayTopRightArea,
        child: Container(
          alignment: Alignment.topRight,
          child: Stack(
            children: [
              TimeHudPanel(
                timeManager: new_time.TimeManager.instance,
              ),
              const Align(
                alignment: Alignment.topRight,
                child: FullscreenButtonOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha do meio (Middle Row)
final class _MiddleRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final PlayerController? playerController;

  const _MiddleRow({
    required this.flexA,
    required this.flexB,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexB,
      child: Row(
        children: [
          _CenterArea(flex: flexB),
          _CenterRightArea(
            flex: flexA,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área central - Tutorial e Market
final class _CenterArea extends StatelessWidget {
  final int flex;

  const _CenterArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterArea,
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              const TutorialInputsOverlay(), // TODO(kevin)
              _MarketPanelArea(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Área do painel de mercado (Market)
final class _MarketPanelArea extends StatelessWidget {
  const _MarketPanelArea();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MarketState.instance.isOpen,
      builder: (context, isOpen, _) {
        if (!isOpen) return const SizedBox.shrink();
        
        return ValueListenableBuilder(
          valueListenable: MarketState.instance.activePlayer,
          builder: (context, player, __) {
            if (player == null) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.center,
              child: MarketPanel(player: player),
            );
          },
        );
      },
    );
  }
}

/// Área direita central - Mobile Inputs
final class _CenterRightArea extends StatelessWidget {
  final int flex;
  final PlayerController? playerController;

  const _CenterRightArea({
    required this.flex,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayCenterRightArea,
        child: SettingsManager.instance.inputSelected ==
                InputActionsType.joystick
            ? MobileInputsOverlay(
                playerController: playerController,
              ) // TODO(Kevin)
            : const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}

/// Linha inferior (Bottom Row)
final class _BottomRow extends StatelessWidget {
  final int flexA;
  final int flexB;
  final bool isDesktop;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _BottomRow({
    required this.flexA,
    required this.flexB,
    required this.isDesktop,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexA + 1,
      child: Row(
        children: [
          if (isDesktop)
            _BottomCenterArea(flex: flexB),
          _BottomRightArea(
            flex: flexA,
            player: player,
            playerController: playerController,
          ),
        ],
      ),
    );
  }
}

/// Área central inferior - Inventário desktop
final class _BottomCenterArea extends StatelessWidget {
  final int flex;

  const _BottomCenterArea({required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomCenterArea,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: const InventoryOverlay(),
        ),
      ),
    );
  }
}

/// Área direita inferior - Joystick Actions e Vital Stats
final class _BottomRightArea extends StatelessWidget {
  final int flex;
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const _BottomRightArea({
    required this.flex,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DebugContainer(
        color: DebugColors.gameplayOverlayBottomRightArea,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _JoystickArea(playerController: playerController),
              PlayerVitalStatsOverlay(player: player),
            ],
          ),
        ),
      ),
    );
  }
}

/// Área do Joystick Actions
final class _JoystickArea extends StatelessWidget {
  final PlayerController? playerController;

  const _JoystickArea({this.playerController});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SettingsManager.instance.inputSelected ==
              InputActionsType.joystick
          ? JoystickActionsOverlay(
              playerController: playerController,
            )
          : const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }
}
