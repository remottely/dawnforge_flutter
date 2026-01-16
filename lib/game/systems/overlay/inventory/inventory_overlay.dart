import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/state/equipment_state.dart';
import 'package:dawnforge/game/features/inventory/state/inventory_state.dart';
import 'package:dawnforge/game/features/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/game/features/inventory/entities/hand_item.dart';
import 'package:dawnforge/game/features/inventory/widgets/item_sprite_widget.dart';
import 'package:dawnforge/game/features/market/market_manager.dart';
import 'package:dawnforge/game/systems/game/player_state_manager.dart';
import 'package:dawnforge/game/systems/overlay/message/message_overlay_service.dart';
import 'package:flutter/material.dart';

/// **COMPOSITION CORE:** Entry Point - Gerencia visibilidade e responsividade
class InventoryOverlay extends StatelessWidget {
  const InventoryOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InventoryState.instance.isVisible,
      builder: (context, isVisible, _) {
        if (!isVisible) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) => const _InventoryContainer(),
        );
      },
    );
  }
}

/// **Container:** Gerencia decoração e layout responsivo
class _InventoryContainer extends StatelessWidget {
  const _InventoryContainer();

  @override
  Widget build(BuildContext context) {
    final config = _ResponsiveConfig(context);

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
      valueListenable: EquipmentManager.instance.selectedSlotIndexNotifier,
      builder: (context, selectedIndex, _) {
        return ValueListenableBuilder<List<InventorySlot>>(
          valueListenable: InventoryManager.instance.slotsNotifier,
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
    final isDesktop = AppDesignSystem.of(context).screenSize.isDesktop;

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
    if (GlobalStateMachine.instance.isUiOverlayMarket) {
      _handleMarketSale(slot);
      return;
    }

    // Modo normal: Seleção de slot
    EquipmentManager.instance.selectSlotIndex(slot.index);
  }

  void _handleMarketSale(InventorySlot slot) {
    final messageService = MessageOverlayService.instance;

    if (slot.isEmpty || slot.item == null) {
      messageService.showError('Slot vazio.');
      return;
    }

    final player = PlayerStateManager.instance.lastPlayerModel;

    if (player == null) {
      messageService.showError('Player não disponível.');
      return;
    }

    final inventoryManager = InventoryManager.instance;
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
  final BuildContext context;

  late final double padding;
  late final double spacing;
  late final double slotSize;
  late final double baseFontSize;
  late final Border border;
  late final ScreenSizeType screenType;

  _ResponsiveConfig(this.context) {
    final ds = AppDesignSystem.of(context);
    screenType = ds.screenSize.type;
    padding = ds.spacing.padding;
    spacing = ds.spacing.spacing;
    slotSize = ds.sizes.slotSize;
    baseFontSize = ds.typography.baseFontSize;
    border = _buildBorder();
  }

  Border _buildBorder() {
    const borderColor = Color(0xff68280d);
    final borderWidth = _getBorderWidth();

    return screenType == ScreenSizeType.desktop
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
    return switch (screenType) {
      ScreenSizeType.mobile => 3.0,
      ScreenSizeType.tablet => 5.0,
      ScreenSizeType.desktop => 6.0,
    };
  }
}
