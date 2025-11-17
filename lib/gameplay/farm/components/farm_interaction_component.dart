import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/hud_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia interação do player com farm tiles
/// Teclas: H (Arar), J (Regar), K (Plantar), R (Colher), N (Debug: avançar dia)
class FarmInteractionComponent extends GameComponent
    with KeyboardEventListener {
  final Player player;

  FarmInteractionComponent({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    // Buscar FarmTileView que está em contato com o player
    final farmTile = _getFarmTileInContact();
    if (farmTile == null) {
      developer.log('[FarmInteraction] ❌ No farm tile in contact with player');
      return false;
    }

    final x = farmTile.tileX;
    final y = farmTile.tileY;

    developer.log('[FarmInteraction] 🎯 Interacting with tile ($x, $y)');

    // H = Arar (Hoe)
    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      final success = FarmManager.instance.tillSoil(x, y);
      if (success) {
        developer.log('[FarmInteraction] ✅ Tilled soil at ($x, $y)');
        _showFloatingText('Terra Arada!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot till at ($x, $y)');
      }
      return true;
    }

    // J = Regar (Water)
    if (event.logicalKey == LogicalKeyboardKey.keyJ) {
      final success = FarmManager.instance.waterTile(x, y);
      if (success) {
        developer.log('[FarmInteraction] ✅ Watered tile at ($x, $y)');
        _showFloatingText('Regado!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot water at ($x, $y)');
      }
      return true;
    }

    // K = Plantar (Seed/Plant) - Exemplo com carrot
    if (event.logicalKey == LogicalKeyboardKey.keyK) {
      // TODO: Integrar com inventário para escolher seed
      final success = FarmManager.instance.plantSeed(x, y, 'carrot');
      if (success) {
        developer.log('[FarmInteraction] ✅ Planted seed at ($x, $y)');
        _showFloatingText('Plantado!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot plant at ($x, $y)');
      }
      return true;
    }

    // R = Colher (Reap/Harvest)
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      final crop = FarmManager.instance.harvestCrop(x, y);
      if (crop != null) {
        developer.log('[FarmInteraction] ✅ Harvested ${crop.name} at ($x, $y)');

        // Adicionar itens colhidos ao inventário
        final harvestItem = ItemFactory.createItem(crop.harvestItemId);
        if (harvestItem != null) {
          final success = InventoryManager.instance.addItem(
            harvestItem,
            crop.yieldAmount,
          );

          if (success) {
            developer.log(
              '[FarmInteraction] 🎒 Added ${crop.yieldAmount}x ${harvestItem.name} to inventory',
            );
            _showFloatingText(
              'Colhido ${crop.yieldAmount}x ${harvestItem.name}!',
            );

            // Forçar refresh do HUD do inventário
            _refreshInventoryHUD();
          } else {
            developer.log('[FarmInteraction] ⚠️ Inventory full, items lost!');
            _showFloatingText('Inventário cheio!');
          }
        } else {
          developer.log(
            '[FarmInteraction] ⚠️ Harvest item not found: ${crop.harvestItemId}',
          );
          _showFloatingText('Colhido ${crop.yieldAmount}x ${crop.name}!');
        }
      } else {
        developer.log('[FarmInteraction] ❌ Cannot harvest at ($x, $y)');
      }
      return true;
    }

    // N = Avançar 1 dia (salva automaticamente)
    if (event.logicalKey == LogicalKeyboardKey.keyN) {
      // Avançar dia no mundo
      WorldStateManager.instance.advanceDay();

      // Avançar dia nos crops
      FarmManager.instance.advanceDay();

      developer.log(
        '[FarmInteraction] 🌙 Advanced to day ${WorldStateManager.instance.currentDay}',
      );
      _showFloatingText('Dia ${WorldStateManager.instance.currentDay}!');

      // Salvar jogo automaticamente
      _saveGameAsync();

      return true;
    }

    // G = Limpar save completamente (reset total)
    if (event.logicalKey == LogicalKeyboardKey.keyG) {
      developer.log('[FarmInteraction] 🗑️ Clearing game and save...');
      _clearGameAsync();
      return true;
    }

    return false;
  }

  /// Busca o FarmTileView que está em contato direto com o player
  FarmTileView? _getFarmTileInContact() {
    // Buscar todos os FarmTileView no jogo
    final allFarmTiles = gameRef.query<FarmTileView>();

    // Verificar qual está sobrepondo o player
    for (final farmTile in allFarmTiles) {
      if (farmTile.isPlayerOnTile(player)) {
        return farmTile;
      }
    }

    return null;
  }

  void _showFloatingText(String text) {
    // TODO: Implementar floating text visual
    // Por enquanto só loga
    developer.log('[FarmInteraction] $text');
  }

  /// Força refresh do HUD de inventário
  void _refreshInventoryHUD() {
    try {
      final hud = gameRef.interface as HUDView?;
      if (hud != null) {
        // Mostrar o inventário temporariamente para feedback visual
        if (!hud.inventoryHUD.isVisible) {
          developer.log(
            '[FarmInteraction] 📦 Opening inventory to show new item',
          );
          hud.inventoryHUD.show();
        }
        hud.inventoryHUD.refresh();
      }
    } catch (e) {
      developer.log('[FarmInteraction] Could not refresh inventory HUD: $e');
    }
  }

  /// Salva o jogo de forma assíncrona (não bloqueia gameplay)
  void _saveGameAsync() {
    developer.log('[FarmInteraction] 💾 Saving game...');

    GameSaveController.instance
        .saveGame()
        .then((success) {
          if (success) {
            developer.log('[FarmInteraction] ✅ Game saved!');
            _showFloatingText('Jogo salvo!');
          } else {
            developer.log('[FarmInteraction] ❌ Failed to save game');
            _showFloatingText('Erro ao salvar!');
          }
        })
        .catchError((e) {
          developer.log('[FarmInteraction] Error saving game: $e');
        });
  }

  /// Limpa o jogo e save de forma assíncrona
  void _clearGameAsync() {
    developer.log('[FarmInteraction] 🗑️ Clearing game and save...');

    GameSaveController.instance
        .clearGameAndSave()
        .then((success) {
          if (success) {
            developer.log('[FarmInteraction] ✅ Game and save cleared!');
            _showFloatingText('Save limpo! Reinicie o jogo.');
          } else {
            developer.log('[FarmInteraction] ❌ Failed to clear game');
            _showFloatingText('Erro ao limpar save!');
          }
        })
        .catchError((e) {
          developer.log('[FarmInteraction] Error clearing game: $e');
        });
  }
}
