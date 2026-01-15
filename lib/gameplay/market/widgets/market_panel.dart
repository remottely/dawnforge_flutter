import 'dart:math' as math;

import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:dawnforge/gameplay/overlay/overlay_message_service.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/gameplay/inventory/entities/hand_item.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';
import 'package:dawnforge/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:dawnforge/gameplay/market/market_manager.dart';
import 'package:dawnforge/gameplay/market/market_models.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dawnforge/core/utils/game_logger.dart';

/// Painel do market exibido dentro do grid da HUD (Quadrante 5).
class MarketPanel extends StatefulWidget {
  final DDBasePlayerModel player;

  const MarketPanel({super.key, required this.player});

  @override
  State<MarketPanel> createState() => _MarketPanelState();
}

class _MarketPanelState extends State<MarketPanel> {
  final _catalog = MarketManager.instance.getMarketCatalog();
  late final InventoryManager _inventory;
  late final ItemFactoryService _itemFactory;
  late final Map<HandItemId, HandItem> _itemCache;
  late final List<MarketItem> _visibleCatalog;
  bool _isProcessing = false;
  late final FocusNode _focusNode;
  int _selectedMarketIndex = 0;
  int _selectedInventoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _inventory = getIt<InventoryManager>();
    _itemFactory = getIt<ItemFactoryService>();
    _itemCache = {};
    _focusNode = FocusNode(debugLabel: 'MarketPanelFocus');
    // Garante player de referência para operações de compra/venda.
    PlayerStateManager.instance.setLastPlayerModel(widget.player);
    if (MarketState.instance.activePlayer.value == null) {
      MarketState.instance.activePlayer.value = widget.player;
    }
    for (final entry in _catalog) {
      final item = _itemFactory.createItem(entry.itemId);
      if (item != null) {
        _itemCache[entry.itemId] = item;
      } else {
        GameLogger.debug(
          '[MarketPanel] ItemFactoryService returned null for ${entry.itemId}',
        );
      }
    }
    _visibleCatalog = _catalog
        .where((entry) => _itemCache.containsKey(entry.itemId))
        .toList();
    GameLogger.debug(
      '[MarketPanel] visibleCatalog size=${_visibleCatalog.length}',
    );

    // Garante que o overlay pegue o foco do teclado assim que abrir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final crossAxisCount = _gridCrossAxisCount(media.size.width);

    if (!_focusNode.hasFocus) {
      // Reaplica foco caso tenha sido perdido ao abrir o market.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1024, maxHeight: 720),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildCoinsRow(),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemCount: _visibleCatalog.length,
                itemBuilder: (context, index) {
                  final entry = _visibleCatalog[index];
                  final item = _itemCache[entry.itemId]!;
                  final isSelected = index == _selectedMarketIndex;
                  return _buildCard(entry, item, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.storefront, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        const Text(
          'Market',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Normal',
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            GameLogger.debug('[MarketPanel] close button tapped');
            MarketState.instance.close();
          },
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCoinsRow() {
    return ValueListenableBuilder<int>(
      valueListenable: widget.player.coinsNotifier,
      builder: (context, coins, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFD54F)),
              const SizedBox(width: 6),
              Text(
                coins.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Normal',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(MarketItem entry, HandItem item, bool isSelected) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.player.coinsNotifier,
      builder: (context, coins, _) {
        final canBuy = coins >= entry.buyPrice;
        final borderColor = isSelected
            ? Colors.orangeAccent
            : canBuy
            ? Colors.greenAccent.withOpacity(0.7)
            : Colors.white24;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: canBuy ? () => _handleBuy(entry, item) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1.2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(isSelected ? 0.12 : 0.06),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Colors.orangeAccent.withOpacity(0.18)
                        : Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.buyPrice}g',
                            style: TextStyle(
                              color: canBuy
                                  ? Colors.greenAccent
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Normal',
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: isSelected
                              ? Colors.orangeAccent
                              : Colors.white60,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Center(
                        child: ItemSpriteWidget(
                          iconData: item.iconData,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Normal',
                        // overflow: TextOverflow.ellipsis
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: canBuy
                                  ? Colors.greenAccent
                                  : Colors.white38,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              entry.buyPrice.toString(),
                              style: TextStyle(
                                color: canBuy
                                    ? Colors.greenAccent
                                    : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Normal',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          canBuy ? 'Comprar' : 'Sem moedas',
                          style: TextStyle(
                            color: canBuy
                                ? Colors.orangeAccent
                                : Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Normal',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBuy(MarketItem entry, HandItem item) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = MarketManager.instance.buyItem(
      entry.itemId,
      widget.player,
      _inventory,
    );

    // Feedback via overlay e snackbar curto.
    if (result.success) {
      OverlayMessageService.instance.showSuccess(result.message);
    } else {
      OverlayMessageService.instance.showError(result.message);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 650),
      ),
    );

    // Atualiza grade para refletir enable/disable (coins) e libera cliques.
    setState(() => _isProcessing = false);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Fechar market com ESC
    if (key == LogicalKeyboardKey.escape) {
      MarketState.instance.close();
      return KeyEventResult.handled;
    }

    // Navegação no grid do market via direcionais.
    if (_isUp(key)) {
      _moveMarketSelection(dRow: -1);
      return KeyEventResult.handled;
    }
    if (_isDown(key)) {
      _moveMarketSelection(dRow: 1);
      return KeyEventResult.handled;
    }
    if (_isLeft(key)) {
      _moveMarketSelection(dCol: -1);
      return KeyEventResult.handled;
    }
    if (_isRight(key)) {
      _moveMarketSelection(dCol: 1);
      return KeyEventResult.handled;
    }

    // Navegar inventário para venda com Q/E (prev/next slot nav).
    if (key == KeyboardSetup.kSlotNavPrevKey) {
      _moveInventorySelection(-1);
      return KeyEventResult.handled;
    }
    if (key == KeyboardSetup.kSlotNavNextKey) {
      _moveInventorySelection(1);
      return KeyEventResult.handled;
    }

    // Comprar item selecionado.
    if (key == KeyboardSetup.kInteractionKey) {
      _buySelected();
      return KeyEventResult.handled;
    }

    // Vender item selecionado do inventário.
    if (key == KeyboardSetup.kPrimaryActionKey) {
      _sellSelectedFromInventory();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveMarketSelection({int dRow = 0, int dCol = 0}) {
    final crossAxisCount = _currentCrossAxisCount();
    final row = _selectedMarketIndex ~/ crossAxisCount;
    final col = _selectedMarketIndex % crossAxisCount;
    var newRow = row + dRow;
    var newCol = col + dCol;

    // Clamp within grid bounds
    if (newRow < 0) newRow = 0;
    if (newCol < 0) newCol = 0;

    final maxRow = ((_visibleCatalog.length - 1) / crossAxisCount).floor();
    if (newRow > maxRow) newRow = maxRow;

    final maxColThisRow = (newRow == maxRow)
        ? (_visibleCatalog.length - 1) % crossAxisCount
        : crossAxisCount - 1;
    if (newCol > maxColThisRow) newCol = maxColThisRow;

    final newIndex = newRow * crossAxisCount + newCol;
    if (newIndex != _selectedMarketIndex && newIndex < _visibleCatalog.length) {
      setState(() => _selectedMarketIndex = newIndex);
    }
  }

  void _moveInventorySelection(int delta) {
    final slots = _inventory.slotsNotifier.value;
    if (slots.isEmpty) return;

    var newIndex = (_selectedInventoryIndex + delta) % slots.length;
    if (newIndex < 0) newIndex = slots.length - 1;

    setState(() => _selectedInventoryIndex = newIndex);
    getIt<EquipmentManager>().selectSlotIndex(newIndex);
  }

  void _buySelected() {
    if (_visibleCatalog.isEmpty) return;
    final entry =
        _visibleCatalog[_selectedMarketIndex.clamp(
          0,
          _visibleCatalog.length - 1,
        )];
    final item = _itemCache[entry.itemId];
    if (item == null) return;
    _handleBuy(entry, item);
  }

  void _sellSelectedFromInventory() {
    final slots = _inventory.slotsNotifier.value;
    if (slots.isEmpty) {
      OverlayMessageService.instance.showError('Inventário vazio.');
      return;
    }

    final slot = slots[_selectedInventoryIndex.clamp(0, slots.length - 1)];
    if (slot.isEmpty || slot.item == null) {
      OverlayMessageService.instance.showError('Slot vazio.');
      return;
    }

    final player = PlayerStateManager.instance.lastPlayerModel;
    if (player == null) {
      OverlayMessageService.instance.showError('Player não disponível.');
      return;
    }

    if (!MarketManager.instance.canSellItem(slot.item!.id, _inventory)) {
      OverlayMessageService.instance.showError('Item não vendável no market.');
      return;
    }

    final result = MarketManager.instance.sellItem(
      slot.item!.id,
      1,
      player,
      _inventory,
    );

    if (result.success) {
      OverlayMessageService.instance.showSuccess(result.message);
    } else {
      OverlayMessageService.instance.showError(result.message);
    }
  }

  int _currentCrossAxisCount() {
    final media = MediaQuery.of(context);
    // Keep navigation logic aligned with grid layout to avoid skipping items.
    return _gridCrossAxisCount(media.size.width);
  }

  int _gridCrossAxisCount(double width) {
    const double wideCardWidth = 220;
    const double narrowCardWidth =
        220; // TODO: ajusta largura alvo se precisar diferenciar mobile
    final targetCardWidth = width >= 900 ? wideCardWidth : narrowCardWidth;
    return math.max(3, (width / targetCardWidth).floor());
  }

  bool _isUp(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW;
  bool _isDown(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS;
  bool _isLeft(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA;
  bool _isRight(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD;
}
