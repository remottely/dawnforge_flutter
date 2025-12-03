import 'dart:developer' as developer;

import '../models/farm_tile_model.dart';

/// Lightweight in-memory store responsible for keeping all farm tiles.
///
/// This class centralizes every read/write to the tile map, making it easier
/// to plug different persistence strategies later (save files, network sync,
/// etc.) without touching gameplay code.
final class FarmTileStore {
  FarmTileStore();

  final Map<String, FarmTileModel> _tiles = {};

  /// Returns the tile keyed by [x] and [y], or `null` if it does not exist.
  FarmTileModel? getTile(int x, int y) => _tiles[_key(x, y)];

  /// Inserts or updates a tile using its coordinates as key.
  void saveTile(FarmTileModel tile) {
    _tiles[_key(tile.x, tile.y)] = tile;
  }

  /// Returns a defensive copy of the stored tiles.
  List<FarmTileModel> getAllTiles() => List.unmodifiable(_tiles.values);

  /// Removes every stored tile.
  void clear() {
    _tiles.clear();
    developer.log('[FarmTileStore] Cleared all tiles');
  }

  /// Serializes all tiles into JSON.
  Map<String, dynamic> toJson() {
    return {'tiles': _tiles.values.map((tile) => tile.toJson()).toList()};
  }

  /// Restores tiles from JSON, replacing the previous state.
  void fromJson(Map<String, dynamic> json) {
    clear();
    final tilesData = json['tiles'] as List<dynamic>?;
    if (tilesData == null) return;

    for (final rawTile in tilesData) {
      final tile = FarmTileModel.fromJson(rawTile as Map<String, dynamic>);
      saveTile(tile);
    }

    developer.log('[FarmTileStore] Loaded ${_tiles.length} tiles');
  }

  String _key(int x, int y) => '${x}_$y';
}
