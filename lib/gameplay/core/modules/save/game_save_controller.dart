import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';

/// Controller que coordena save/load do estado completo do jogo
///
/// Responsável por:
/// - Coletar dados de todos os managers (player, inventory, farm, world)
/// - Salvar no disco via SaveManager
/// - Carregar do disco e restaurar estado de todos os managers
final class GameSaveController {
  GameSaveController._();

  static final instance = GameSaveController._();

  /// Salva o estado completo do jogo
  ///
  /// Coleta dados de:
  /// - PlayerStateManager (vida, stamina, energy, etc)
  /// - InventoryManager (items, slots)
  /// - FarmManager (tiles, crops)
  /// - WorldStateManager (dia, season, tempo)
  Future<bool> saveGame() async {
    try {
      developer.log('[GameSaveController] Starting game save...');

      // Coletar dados de todos os managers
      final playerData = _collectPlayerData();
      final worldData = _collectWorldData();
      final inventoryData = _collectInventoryData();
      final farmData = _collectFarmData();

      // Combinar farm data no worldData
      worldData['farmData'] = farmData;

      // Criar SaveData
      final saveData = SaveData(
        version: SaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: playerData,
        worldData: worldData,
        inventoryData: inventoryData,
      );

      // Salvar via SaveManager
      final success = await SaveManager.instance.save(saveData);

      if (success) {
        developer.log('[GameSaveController] ✅ Game saved successfully!');
      } else {
        developer.log('[GameSaveController] ❌ Failed to save game');
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error saving game',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Carrega o estado completo do jogo
  ///
  /// Restaura:
  /// - PlayerStateManager
  /// - InventoryManager
  /// - FarmManager
  /// - WorldStateManager
  Future<bool> loadGame() async {
    try {
      developer.log('[GameSaveController] Starting game load...');

      // Carregar via SaveManager
      final saveData = await SaveManager.instance.load();

      if (saveData == null) {
        developer.log('[GameSaveController] No save file found');
        return false;
      }

      // Restaurar dados em cada manager
      _restorePlayerData(saveData.playerData);
      _restoreWorldData(saveData.worldData);
      _restoreInventoryData(saveData.inventoryData);
      _restoreFarmData(saveData.worldData['farmData'] as Map<String, dynamic>?);

      developer.log('[GameSaveController] ✅ Game loaded successfully!');
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error loading game',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Verifica se existe um save
  Future<bool> hasSave() async {
    return await SaveManager.instance.hasSave();
  }

  /// Deleta o save
  Future<bool> deleteSave() async {
    return await SaveManager.instance.deleteSave();
  }

  /// Limpa completamente o jogo: reseta todos os managers e deleta o save
  ///
  /// Esta ação:
  /// - Reseta PlayerStateManager (vida, stamina, energy)
  /// - Limpa InventoryManager (remove todos os items)
  /// - Reseta FarmManager (remove todas as plantas)
  /// - Reseta WorldStateManager (volta para dia 1)
  /// - Deleta o arquivo de save do disco
  Future<bool> clearGameAndSave() async {
    try {
      developer.log('[GameSaveController] 🗑️ Clearing game and save...');

      // Resetar todos os managers
      PlayerStateManager.instance.reset();
      InventoryManager.instance.clear();
      FarmManager.instance.reset();
      WorldStateManager.instance.reset();

      developer.log('[GameSaveController] ✅ All managers reset');

      // Deletar arquivo de save
      final deleted = await SaveManager.instance.deleteSave();

      if (deleted) {
        developer.log('[GameSaveController] ✅ Save file deleted');
      } else {
        developer.log('[GameSaveController] ⚠️ No save file to delete');
      }

      developer.log(
        '[GameSaveController] ✅ Game and save cleared successfully!',
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error clearing game and save',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ==========================================================================
  // Coleta de dados (serialização)
  // ==========================================================================

  Map<String, dynamic> _collectPlayerData() {
    final playerState = PlayerStateManager.instance;
    return playerState.toJson();
  }

  Map<String, dynamic> _collectWorldData() {
    final worldState = WorldStateManager.instance;
    return worldState.toJson();
  }

  Map<String, dynamic> _collectInventoryData() {
    final inventory = InventoryManager.instance;
    return inventory.toJson();
  }

  Map<String, dynamic> _collectFarmData() {
    final farm = FarmManager.instance;
    return farm.toJson();
  }

  // ==========================================================================
  // Restauração de dados (deserialização)
  // ==========================================================================

  void _restorePlayerData(Map<String, dynamic> data) {
    try {
      final playerState = PlayerStateManager.instance;
      playerState.fromJson(data);
      developer.log('[GameSaveController] Player state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring player data: $e');
    }
  }

  void _restoreWorldData(Map<String, dynamic> data) {
    try {
      final worldState = WorldStateManager.instance;
      worldState.fromJson(data);
      developer.log('[GameSaveController] World state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring world data: $e');
    }
  }

  void _restoreInventoryData(Map<String, dynamic> data) {
    try {
      final inventory = InventoryManager.instance;
      inventory.fromJson(data);
      developer.log('[GameSaveController] Inventory restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring inventory data: $e');
    }
  }

  void _restoreFarmData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        developer.log('[GameSaveController] No farm data to restore');
        return;
      }

      final farm = FarmManager.instance;
      farm.fromJson(data);
      developer.log('[GameSaveController] Farm state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring farm data: $e');
    }
  }
}
