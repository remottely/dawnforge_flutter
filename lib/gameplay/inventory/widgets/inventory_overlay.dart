/// **InventoryOverlay - Composite Pattern + MVVM**
/// Sistema de inventário responsivo com suporte a venda no market
/// Utiliza composition pattern para separar responsabilidades
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/state/equipment_state.dart';
import 'package:dawnforge/gameplay/inventory/state/inventory_state.dart';
import 'package:dawnforge/gameplay/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/gameplay/inventory/entities/hand_item.dart';
import 'package:dawnforge/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/gameplay/market/market_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_service.dart';
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
              _InventoryContainer(screenSize: getScreenSize(context)),
        );
      },
    );
  }
}

/// **Container:** Gerencia decoração e layout responsivo
class _InventoryContainer extends StatelessWidget {
  final ScreenSize screenSize;

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
    final isDesktop = config.screenSize == ScreenSize.desktop;

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
  final ScreenSize screenSize;

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

    return screenSize == ScreenSize.desktop
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
      case ScreenSize.mobile:
        return 3.0;
      case ScreenSize.tablet:
        return 5.0;
      case ScreenSize.desktop:
        return 6.0;
    }
  }
}
