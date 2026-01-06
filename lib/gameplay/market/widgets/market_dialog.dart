import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:darkness_dungeon/gameplay/market/market_manager.dart';
import 'package:darkness_dungeon/gameplay/market/market_models.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_service.dart';
import 'package:darkness_dungeon/gameplay/market/market_state.dart';
import 'package:flutter/material.dart';

/// Dialog fullscreen/semi-fullscreen para o market.
class MarketDialog extends StatefulWidget {
  final DDBasePlayerModel player;
  final VoidCallback? onClose;

  const MarketDialog({super.key, required this.player, this.onClose});

  @override
  State<MarketDialog> createState() => _MarketDialogState();
}

class _MarketDialogState extends State<MarketDialog> {
  static int _instanceCounter = 0;
  late final int _id;

  final _catalog = MarketManager.instance.getMarketCatalog();
  late final InventoryManager _inventory;
  late final ItemFactoryService _itemFactory;
  late final Map<HandItemId, HandItem> _itemCache;
  late final List<MarketItem> _visibleCatalog;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _id = ++_MarketDialogState._instanceCounter;
    debugPrint('[MarketDialog#$_id] initState');
    MarketState.instance.open();
    _inventory = getIt<InventoryManager>();
    _itemFactory = getIt<ItemFactoryService>();
    _itemCache = {};
    for (final entry in _catalog) {
      final item = _itemFactory.createItem(entry.itemId);
      if (item != null) {
        _itemCache[entry.itemId] = item;
      } else {
        debugPrint('[MarketDialog#$_id] ItemFactoryService returned null for ${entry.itemId}');
      }
    }
    _visibleCatalog = _catalog
        .where((entry) => _itemCache.containsKey(entry.itemId))
        .toList();
    debugPrint('[MarketDialog#$_id] visibleCatalog size=${_visibleCatalog.length}');
  }

  @override
  void dispose() {
    debugPrint('[MarketDialog#$_id] dispose');
    MarketState.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 900;
    final crossAxisCount = isWide ? 4 : (media.size.width >= 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1024, maxHeight: 720),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
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
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: _visibleCatalog.length,
                    itemBuilder: (context, index) {
                      final entry = _visibleCatalog[index];
                      final item = _itemCache[entry.itemId]!;
                      return _buildCard(entry, item);
                    },
                  ),
                ),
              ],
            ),
          ),
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
            debugPrint('[MarketDialog#$_id] close button tapped');
            widget.onClose?.call();
            Navigator.of(context).maybePop();
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _buildCard(MarketItem entry, HandItem item) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.player.coinsNotifier,
      builder: (context, coins, _) {
        final canBuy = coins >= entry.buyPrice;
        return Card(
          color: Colors.white.withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: canBuy ? Colors.greenAccent.withOpacity(0.6) : Colors.white24,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: canBuy ? () => _handleBuy(entry, item) : null,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ItemSpriteWidget(
                      iconData: item.iconData,
                      size: 48,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Normal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: canBuy ? Colors.greenAccent : Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.buyPrice.toString(),
                        style: TextStyle(
                          color: canBuy ? Colors.greenAccent : Colors.white70,
                          fontSize: 13,
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
}
