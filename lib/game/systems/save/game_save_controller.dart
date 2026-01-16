import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/systems/game/player_state_manager.dart';
import 'package:dawnforge/game/systems/save/save_data_model.dart';
import 'package:dawnforge/game/systems/save/save_manager.dart';
import 'package:dawnforge/game/systems/world/world_state_manager.dart';
import 'package:dawnforge/game/features/farm/farm_service_locator.dart' as farm_di;
import 'package:dawnforge/game/features/farm/managers/farm_manager.dart';
import 'package:dawnforge/game/features/farm/usecases/load_farm_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/save_farm_use_case.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/features/time/time_manager.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';

/// Helper para conversão de coordenadas pixel → tile
/// Segue o padrão de jogos 2D grid-based
class PositionHelper {
  PositionHelper._();

  /// Tamanho padrão do tile em pixels (16x16)
  static const double kTileSize = 16.0;

  /// Converte posição em pixels para coordenadas de tile
  ///
  /// Por padrão usa arredondamento para baixo (floor) seguindo o padrão
  /// de grid-based games onde a posição representa o tile onde o centro
  /// da entidade está localizado.
  ///
  /// Exemplos:
  /// - (15.9, 15.9) pixels → (0, 0) tile
  /// - (16.0, 16.0) pixels → (1, 1) tile
  /// - (24.0, 24.0) pixels → (1, 1) tile
  static Vector2 pixelsToTile(
    Vector2 pixelPosition, {
    double tileSize = kTileSize,
  }) {
    return Vector2(
      (pixelPosition.x / tileSize).floor().toDouble(),
      (pixelPosition.y / tileSize).floor().toDouble(),
    );
  }

  /// Converte coordenadas de tile para pixels (centro do tile)
  ///
  /// Usado no restore para spawnar o player no centro do tile,
  /// evitando que apareça "grudado" no canto superior esquerdo.
  static Vector2 tileToPixelsCenter(
    Vector2 tilePosition, {
    double tileSize = kTileSize,
  }) {
    return Vector2(
      (tilePosition.x * tileSize) + (tileSize / 2),
      (tilePosition.y * tileSize) + (tileSize / 2),
    );
  }

  /// Converte coordenadas de tile para pixels (centro do tile)
  ///
  /// Usado no restore para spawnar o player no centro do tile,
  /// evitando que apareça "grudado" no canto superior esquerdo.
  static Vector2 toSavePos(Vector2 tilePosition) {
    return Vector2(tilePosition.x + 1, tilePosition.y + 1);
  }

  static Vector2 toMVPPosition() {
    return Vector2(5, 5);
  }
}

final class GameSaveController {
  GameSaveController._();

  static final instance = GameSaveController._();

  Future<bool> saveGame() async {
    try {
      GameLogger.info('[GameSaveController] Starting game save...');

      final playerData = _collectPlayerData();
      final life = (playerData['playerModel'] as Map?)?['life'];
      if (life == null || (life is num && life <= 0)) {
        GameLogger.warning(
          '[GameSaveController] ❌ Aborting save: player life is null/<=0 (life=$life). Avoid overwriting good saves after death.',
        );
        return false;
      }
      final worldData = _collectWorldData();
      final inventoryData = _collectInventoryData();
      final farmData = _collectFarmData();

      worldData['time'] = TimeManager.instance.toJson();

      worldData['farmData'] = farmData;

      final saveData = SaveData(
        version: SaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: playerData,
        worldData: worldData,
        inventoryData: inventoryData,
      );

      final success = await SaveManager.instance.save(saveData);

      if (success) {
        GameLogger.info('[GameSaveController] ✅ Game saved successfully!');
      } else {
        GameLogger.error('[GameSaveController] ❌ Failed to save game');
      }

      return success;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error saving game: $e');
      return false;
    }
  }

  Future<bool> loadGame() async {
    try {
      GameLogger.info('[GameSaveController] Starting game load...');

      final saveData = await SaveManager.instance.load();

      if (saveData == null) {
        GameLogger.warning('[GameSaveController] No save file found');
        return false;
      }

      GameLogger.info(
        '[GameSaveController] Save data loaded, restoring components...',
      );

      _restorePlayerData(saveData.playerData);
      _restoreWorldData(saveData.worldData);
      _restoreTimeData(saveData.worldData['time'] as Map<String, dynamic>?);
      _restoreInventoryData(saveData.inventoryData);
      _restoreFarmData(saveData.worldData['farmData'] as Map<String, dynamic>?);

      GameLogger.info('[GameSaveController] ✅ Game loaded successfully!');
      return true;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error loading game: $e');
      return false;
    }
  }

  Future<bool> hasSave() async {
    return await SaveManager.instance.hasSave();
  }

  Future<bool> deleteSave() async {
    return await SaveManager.instance.deleteSave();
  }

  Future<bool> clearGameAndSave() async {
    try {
      GameLogger.info('[GameSaveController] 🗑️ Clearing game and save...');

      PlayerStateManager.instance.reset();
      InventoryManager.instance.clear();
      FarmManager.instance.reset();
      WorldStateManager.instance.reset();

      GameLogger.info('[GameSaveController] ✅ All managers reset');

      final deleted = await SaveManager.instance.deleteSave();

      if (deleted) {
        GameLogger.info('[GameSaveController] ✅ Save file deleted');
      } else {
        GameLogger.warning('[GameSaveController] ⚠️ No save file to delete');
      }

      return true;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error clearing game and save: $e');
      return false;
    }
  }

  Map<String, dynamic> _collectPlayerData() {
    final playerState = PlayerStateManager.instance;

    // Save current player position before serializing
    if (playerState.lastPlayerView != null &&
        playerState.lastPlayerModel != null) {
      // final pixelPos = playerState.lastPlayerView!.position; // TODO(Kevin): put it back

      // // Converte pixels → tile usando floor (padrão de mercado)
      // final tilePosConfig = _PositionHelper.pixelsToTile(
      //   Vector2(pixelPos.x, pixelPos.y),
      // ); // TODO(Kevin): put it back

      // final tilePosConfig2 = _PositionHelper.toSavePos(tilePosConfig); // TODO(Kevin): put it back

      // GameLogger.info(
      //   '[GameSaveController] 💾 Converting position: pixels(${pixelPos.x.toStringAsFixed(2)}, ${pixelPos.y.toStringAsFixed(2)}) → tile(${tilePos.x}, ${tilePos.y})',
      // );

      final tilePos = PositionHelper.toMVPPosition(); // TODO(Kevin): remove it

      // Salva em tiles na propriedade do modelo
      if (playerState.lastPlayerModel is DDBasePlayerModel) {
        (playerState.lastPlayerModel as DDBasePlayerModel).setPosition(tilePos);
      } else {
        // fallback para modelos customizados
        try {
          (playerState.lastPlayerModel as dynamic).position = [
            tilePos.x,
            tilePos.y,
          ];
        } catch (_) {}
      }
    }

    final playerData = playerState.toJson();
    final playerModelJson = (playerData['playerModel'] as Map?) ?? const {};
    final coins = playerModelJson['coins'];
    final life = playerModelJson['life'];
    final stamina = playerModelJson['stamina'];
    final position = playerModelJson['position'];

    GameLogger.info(
      '[GameSaveController] Collecting player data: model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, stamina=$stamina, life=$life, coins=$coins, position=$position',
    );

    if (life == null || (life is num && life <= 0)) {
      GameLogger.warning(
        '[GameSaveController] ⚠️ Player life is null/<=0 during save, skipping validation? raw=$playerModelJson',
      );
    }

    if (coins is num && coins < 0) {
      GameLogger.warning(
        '[GameSaveController] ⚠️ Player coins negative during save, raw=$playerModelJson',
      );
    }

    return playerData;
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
    final saveFarmUseCase = farm_di.getIt<SaveFarmUseCase>();
    return saveFarmUseCase.call();
  }

  void _restorePlayerData(Map<String, dynamic> data) {
    try {
      GameLogger.info(
        '[GameSaveController] Restoring player data: ${data.keys.toList()}, coinsField=${(data['playerModel'] as Map?)?['coins']}',
      );
      final playerState = PlayerStateManager.instance;
      playerState.fromJson(data);
      GameLogger.info(
        '[GameSaveController] ✅ Player state restored: model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, stamina=${playerState.lastPlayerModel?.stamina}, life=${playerState.lastPlayerModel?.life}, coins=${playerState.lastPlayerModel?.coins}',
      );

      final restoredLife = playerState.lastPlayerModel?.life;
      if (restoredLife == null || restoredLife <= 0) {
        GameLogger.warning(
          '[GameSaveController] ⚠️ Restored player life is null/<=0. payload=${data['playerModel']}',
        );
      }

      // Restore player position if available
      final playerModelJson = data['playerModel'] as Map?;
      final positionRaw = playerModelJson?['position'];
      if (positionRaw is List && positionRaw.length == 2) {
        final tileX = (positionRaw[0] as num).toDouble();
        final tileY = (positionRaw[1] as num).toDouble();

        // Converte pixels → tile usando floor (padrão de mercado)
        final pixelPos = PositionHelper.pixelsToTile(Vector2(tileX, tileY));

        // final pixelPos = _PositionHelper.toSavePos(tilePosConfig);

        GameLogger.info(
          '[GameSaveController] 📍 Converting position: tile($tileX, $tileY) → pixels(${pixelPos.x.toStringAsFixed(2)}, ${pixelPos.y.toStringAsFixed(2)})',
        );

        if (playerState.lastPlayerView != null) {
          playerState.lastPlayerView!.position = pixelPos;
          GameLogger.info(
            '[GameSaveController] ✅ Player position restored to tile($tileX, $tileY) / pixels(${pixelPos.x}, ${pixelPos.y})',
          );
        } else {
          GameLogger.warning(
            '[GameSaveController] ⚠️ Could not restore player position: lastPlayerView is null',
          );
        }
      }
    } catch (e) {
      GameLogger.error(
        '[GameSaveController] ❌ Error restoring player data: $e',
      );
    }
  }

  void _restoreWorldData(Map<String, dynamic> data) {
    try {
      GameLogger.info(
        '[GameSaveController] Restoring world data: ${data.keys.toList()}',
      );
      final worldState = WorldStateManager.instance;
      worldState.fromJson(data);
      GameLogger.info('[GameSaveController] ✅ World state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring world data: $e');
    }
  }

  void _restoreTimeData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        GameLogger.warning('[GameSaveController] No time state data found');
        return;
      }

      TimeManager.instance.fromJson(data);
      GameLogger.info('[GameSaveController] ✅ Time state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring time state: $e');
    }
  }

  void _restoreInventoryData(Map<String, dynamic> data) {
    try {
      GameLogger.info(
        '[GameSaveController] Restoring inventory data: ${data.keys.toList()}',
      );
      final inventory = InventoryManager.instance;
      inventory.fromJson(data, ItemFactoryService.instance.createItem);
      GameLogger.info('[GameSaveController] ✅ Inventory restored');
    } catch (e) {
      GameLogger.error(
        '[GameSaveController] ❌ Error restoring inventory data: $e',
      );
    }
  }

  void _restoreFarmData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        GameLogger.warning('[GameSaveController] ⚠️ No farm data to restore');
        return;
      }

      GameLogger.info(
        '[GameSaveController] Restoring farm data: ${data.keys.toList()}',
      );
      final loadFarmUseCase = farm_di.getIt<LoadFarmUseCase>();
      loadFarmUseCase.call(data);
      GameLogger.info('[GameSaveController] ✅ Farm state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring farm data: $e');
    }
  }
}
