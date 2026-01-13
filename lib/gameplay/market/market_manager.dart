import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';
import 'package:dawnforge/gameplay/inventory/usecases/add_item_use_case.dart';
import 'package:dawnforge/gameplay/inventory/usecases/remove_item_use_case.dart';
import 'package:dawnforge/gameplay/market/market_models.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';

class MarketTransactionResult {
  final bool success;
  final String message;
  final MarketTransactionError? error;

  const MarketTransactionResult._({
    required this.success,
    required this.message,
    this.error,
  });

  factory MarketTransactionResult.success(String message) =>
      MarketTransactionResult._(success: true, message: message);

  factory MarketTransactionResult.failure(
    MarketTransactionError error,
    String message,
  ) =>
      MarketTransactionResult._(success: false, message: message, error: error);
}

/// Gerencia a lógica de compra/venda do market.
class MarketManager {
  MarketManager._(
    this._addItemUseCase,
    this._removeItemUseCase,
    this._itemFactory,
  );

  static final MarketManager instance = MarketManager._(
    getIt<AddItemUseCase>(),
    getIt<RemoveItemUseCase>(),
    getIt<ItemFactoryService>(),
  );

  final AddItemUseCase _addItemUseCase;
  final RemoveItemUseCase _removeItemUseCase;
  final ItemFactoryService _itemFactory;

  List<MarketItem> getMarketCatalog() => MarketCatalog.seeds;

  bool canBuyItem(HandItemId itemId, DDBasePlayerModel player) {
    final entry = MarketCatalog.byId[itemId];
    if (entry == null || !entry.isAvailable) return false;
    return player.canAfford(entry.buyPrice);
  }

  bool canSellItem(HandItemId itemId, InventoryManager inventory) {
    final sellPrice = _getSellPrice(itemId);
    if (sellPrice == null) return false;
    return inventory.getItemQuantity(itemId.name) > 0;
  }

  MarketTransactionResult buyItem(
    HandItemId itemId,
    DDBasePlayerModel player,
    InventoryManager inventory,
  ) {
    final entry = MarketCatalog.byId[itemId];
    if (entry == null || !entry.isAvailable) {
      return MarketTransactionResult.failure(
        MarketTransactionError.itemUnavailable,
        'Item não disponível no market.',
      );
    }

    final item = _itemFactory.createItem(itemId);
    if (item == null) {
      return MarketTransactionResult.failure(
        MarketTransactionError.invalidItem,
        'Item inválido.',
      );
    }

    if (!player.canAfford(entry.buyPrice)) {
      return MarketTransactionResult.failure(
        MarketTransactionError.insufficientFunds,
        'Moedas insuficientes.',
      );
    }

    if (!_canFit(inventory, item)) {
      return MarketTransactionResult.failure(
        MarketTransactionError.inventoryFull,
        'Inventário cheio.',
      );
    }

    final added = _addItemUseCase.addItemEntity(item, 1);
    if (!added) {
      return MarketTransactionResult.failure(
        MarketTransactionError.inventoryFull,
        'Não foi possível adicionar ao inventário.',
      );
    }

    final removed = player.removeCoins(entry.buyPrice);
    if (!removed) {
      // rollback simples: remover o item recém-adicionado
      _removeItemUseCase(itemId, 1);
      return MarketTransactionResult.failure(
        MarketTransactionError.insufficientFunds,
        'Moedas insuficientes.',
      );
    }

    return MarketTransactionResult.success(
      'Comprou 1x ${item.name} por ${entry.buyPrice} moedas.',
    );
  }

  MarketTransactionResult sellItem(
    HandItemId itemId,
    int quantity,
    DDBasePlayerModel player,
    InventoryManager inventory,
  ) {
    if (quantity <= 0) {
      return MarketTransactionResult.failure(
        MarketTransactionError.invalidItem,
        'Quantidade inválida.',
      );
    }

    final sellPrice = _getSellPrice(itemId);
    if (sellPrice == null) {
      return MarketTransactionResult.failure(
        MarketTransactionError.notTradeable,
        'Item não vendável.',
      );
    }

    final totalQuantity = inventory.getItemQuantity(itemId.name);
    if (totalQuantity < quantity) {
      return MarketTransactionResult.failure(
        MarketTransactionError.invalidItem,
        'Você não possui quantidade suficiente.',
      );
    }

    final removed = _removeItemUseCase(itemId, quantity);
    if (!removed) {
      return MarketTransactionResult.failure(
        MarketTransactionError.unknown,
        'Falha ao remover item do inventário.',
      );
    }

    final gain = sellPrice * quantity;
    player.addCoins(gain);

    return MarketTransactionResult.success(
      'Vendeu $quantity x ${itemId.name} por $gain moedas.',
    );
  }

  bool _canFit(InventoryManager inventory, dynamic item) {
    // Tenta encaixar em slots existentes ou espaço livre.
    for (var i = 0; i < inventory.maxSlots; i++) {
      final slot = inventory.getSlotByIndex(i);
      if (slot == null) continue;
      if (slot.isEmpty) return true;
      if (slot.item?.id == item.id && slot.canAddItem(item, 1)) {
        return true;
      }
    }
    return false;
  }

  int? _getSellPrice(HandItemId itemId) {
    final entry = MarketCatalog.byId[itemId];
    if (entry?.sellPrice != null) return entry!.sellPrice;
    return MarketCatalog.harvestLootSellPrice[itemId];
  }
}
