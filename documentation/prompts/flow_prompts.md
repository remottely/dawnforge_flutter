me gere ambos os codigos completos prontos para copiar e colar:
/// **InventoryOverlay - Composite Pattern + MVVM**
/// Sistema de inventário responsivo com suporte a venda no market
/// Utiliza composition pattern para separar responsabilidades
import 'package:dawnforge/features/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:dawnforge/features/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:dawnforge/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/features/inventory/state/equipment_state.dart';
import 'package:dawnforge/features/inventory/state/inventory_state.dart';
import 'package:dawnforge/features/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/features/inventory/entities/hand_item.dart';
import 'package:dawnforge/features/inventory/widgets/item_sprite_widget.dart';
import 'package:dawnforge/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/features/market/market_state.dart';
import 'package:dawnforge/features/market/market_manager.dart';
import 'package:dawnforge/features/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/features/overlay/overlay_message_service.dart';
import 'package:flutter/material.dart';

/// **COMPOSITION CORE:** Entry Point - Gerencia visibilidade e responsividade
class InventoryOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  const InventoryOverlay({super.key});

  // @override
  // String get overlayId => 'inventory';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InventoryState.instance.isVisible,
      builder: (context, isVisible, _) {
        if (!isVisible) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) =>
              _InventoryContainer(screenSize: getScreenSizeType(context)),
        );
      },
    );
  }
}

/// **Container:** Gerencia decoração e layout responsivo
class _InventoryContainer extends StatelessWidget {
  final ScreenSizeType screenSize;

  const _InventoryContainer({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final config = _ResponsiveConfig(screenSize);

    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xfffebc6e),
          border: config.border,
        ),
        child: _InventoryGrid(config: config),
      ),
    );
  }
}

/// **Grid:** Lista de slots com orientação responsiva
class _InventoryGrid extends StatelessWidget {
  final _ResponsiveConfig config;

  const _InventoryGrid({required this.config});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: getIt<EquipmentManager>().selectedSlotIndexNotifier,
      builder: (context, selectedIndex, _) {
        return ValueListenableBuilder<List<InventorySlot>>(
          valueListenable: getIt<InventoryManager>().slotsNotifier,
          builder: (context, slots, _) {
            return ValueListenableBuilder<HandItem?>(
              valueListenable: EquipmentState.instance.equippedItem,
              builder: (context, equippedItem, _) {
                return _buildAdaptiveLayout(
                  context,
                  slots,
                  selectedIndex,
                  equippedItem,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAdaptiveLayout(
    BuildContext context,
    List<InventorySlot> slots,
    int selectedIndex,
    HandItem? equippedItem,
  ) {
    final isDesktop = config.screenSize == ScreenSizeType.desktop;

    return SingleChildScrollView(
      scrollDirection: isDesktop ? Axis.horizontal : Axis.vertical,
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: slots.map((slot) {
          return _InventorySlotWidget(
            slot: slot,
            config: config,
            isSelected: selectedIndex == slot.index,
            equippedItem: equippedItem,
            onTap: () => _handleSlotTap(slot),
          );
        }).toList(),
      ),
    );
  }

  void _handleSlotTap(InventorySlot slot) {
    // Modo venda: Market aberto
    if (MarketState.instance.isOpen.value) {
      _handleMarketSale(slot);
      return;
    }

    // Modo normal: Seleção de slot
    getIt<EquipmentManager>().selectSlotIndex(slot.index);
  }

  void _handleMarketSale(InventorySlot slot) {
    final messageService = OverlayMessageService.instance;

    if (slot.isEmpty || slot.item == null) {
      messageService.showError('Slot vazio.');
      return;
    }

    final player =
        MarketState.instance.activePlayer.value ??
        PlayerStateManager.instance.lastPlayerModel;

    if (player == null) {
      messageService.showError('Player não disponível.');
      return;
    }

    final inventoryManager = getIt<InventoryManager>();
    final marketManager = MarketManager.instance;

    if (!marketManager.canSellItem(slot.item!.id, inventoryManager)) {
      messageService.showError('Item não vendável no market.');
      return;
    }

    final result = marketManager.sellItem(
      slot.item!.id,
      1,
      player,
      inventoryManager,
    );

    if (result.success) {
      messageService.showSuccess(result.message);
    } else {
      messageService.showError(result.message);
    }
  }
}

/// **Slot Widget:** Renderiza um slot individual com item e indicadores
class _InventorySlotWidget extends StatelessWidget {
  final InventorySlot slot;
  final _ResponsiveConfig config;
  final bool isSelected;
  final HandItem? equippedItem;
  final VoidCallback onTap;

  const _InventorySlotWidget({
    required this.slot,
    required this.config,
    required this.isSelected,
    required this.equippedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final slotColor = _getSlotColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: config.slotSize * 1.2,
        height: config.slotSize,
        decoration: BoxDecoration(color: isSelected ? Colors.white : slotColor),
        child: Stack(
          children: [
            _SlotNumberIndicator(index: slot.index, config: config),
            if (slot.item != null) ...[
              _SlotItemIcon(item: slot.item!, config: config),
              if (slot.quantity > 1)
                _SlotQuantityIndicator(quantity: slot.quantity, config: config),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSlotColor() {
    final item = slot.item;

    // Item equipado: vermelho
    if (item != null && equippedItem != null && equippedItem!.id == item.id) {
      return Colors.red.withValues(alpha: 0.5);
    }

    // Alternância de cores por índice
    return slot.index % 2 == 0
        ? const Color(0xfffebc6e)
        : const Color(0xfff5aa66);
  }
}

/// **Indicador de Número:** Atalho de teclado (1-9, 0, -, +)
class _SlotNumberIndicator extends StatelessWidget {
  final int index;
  final _ResponsiveConfig config;

  const _SlotNumberIndicator({required this.index, required this.config});

  @override
  Widget build(BuildContext context) {
    final label = _getSlotLabel();

    if (label == null) return const SizedBox.shrink();

    return Positioned(
      top: 1,
      left: 2,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.spacing / 2,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: config.baseFontSize - 4,
            fontWeight: FontWeight.bold,
            fontFamily: 'Normal',
          ),
        ),
      ),
    );
  }

  String? _getSlotLabel() {
    if (index < 9) return '${index + 1}';
    if (index == 9) return '0';
    if (index == 10) return '-';
    if (index == 11) return '+';
    return null;
  }
}

/// **Ícone do Item:** Sprite centralizado
class _SlotItemIcon extends StatelessWidget {
  final HandItem item;
  final _ResponsiveConfig config;

  const _SlotItemIcon({required this.item, required this.config});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(config.spacing),
        child: ItemSpriteWidget(
          iconData: item.iconData,
          size: config.slotSize - (config.spacing * 2),
        ),
      ),
    );
  }
}

/// **Indicador de Quantidade:** Badge amarelo com contador
class _SlotQuantityIndicator extends StatelessWidget {
  final int quantity;
  final _ResponsiveConfig config;

  const _SlotQuantityIndicator({required this.quantity, required this.config});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 2,
      left: 2,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.spacing / 2,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          'x$quantity',
          style: TextStyle(
            color: Colors.yellow,
            fontSize: config.baseFontSize - 4,
            fontFamily: 'Normal',
          ),
        ),
      ),
    );
  }
}

/// **Config Responsivo:** Centraliza valores de padding, spacing, tamanhos, etc.
class _ResponsiveConfig {
  final ScreenSizeType screenSize;

  late final double padding;
  late final double spacing;
  late final double slotSize;
  late final double baseFontSize;
  late final Border border;

  _ResponsiveConfig(this.screenSize) {
    padding = OverlayResponsiveConfig.getPadding(screenSize);
    spacing = OverlayResponsiveConfig.getSpacing(screenSize);
    slotSize = OverlayResponsiveConfig.getSlotSize(screenSize);
    baseFontSize = OverlayResponsiveConfig.getBaseFontSize(screenSize);
    border = _buildBorder();
  }

  Border _buildBorder() {
    const borderColor = Color(0xff68280d);
    final borderWidth = _getBorderWidth();

    return screenSize == ScreenSizeType.desktop
        ? Border(
            left: BorderSide(color: borderColor, width: borderWidth),
            top: BorderSide(color: borderColor, width: borderWidth),
            right: BorderSide(color: borderColor, width: borderWidth),
          )
        : Border(
            right: BorderSide(color: borderColor, width: borderWidth),
          );
  }

  double _getBorderWidth() {
    switch (screenSize) {
      case ScreenSizeType.mobile:
        return 3.0;
      case ScreenSizeType.tablet:
        return 5.0;
      case ScreenSizeType.desktop:
        return 6.0;
    }
  }
}
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/overlay/overlay_message_widget.dart';
import 'package:dawnforge/features/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:dawnforge/features/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:dawnforge/features/overlay/inventory_overlay.dart';
import 'package:dawnforge/features/market/market_state.dart';
import 'package:dawnforge/features/market/widgets/market_panel.dart';
import 'package:dawnforge/features/core/modules/hud/player_vital_stats/player_vital_stats_overlay.dart';
import 'package:dawnforge/features/core/modules/hud/debug/debug_overlay.dart';
import 'package:dawnforge/features/overlay/mobile_inputs_overlay.dart';
import 'package:dawnforge/features/core/modules/hud/inputs/widgets/joystick_actions_overlay.dart';
import 'package:dawnforge/features/core/modules/hud/inputs/widgets/fullscreen_button_overlay.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/managers/settings_manager.dart';
import 'package:dawnforge/features/time/time_manager.dart' as new_time;
import 'package:dawnforge/features/time/widgets/time_hud_panel.dart';
import 'package:dawnforge/core/utils/debug_helpers.dart';
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
