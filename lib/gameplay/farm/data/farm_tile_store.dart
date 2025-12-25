import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart';

final class FarmTileStore {
  FarmTileStore();

  final Map<String, FarmTileModel> _tiles = {};

  FarmTileModel? getTile(int x, int y) => _tiles[_key(x, y)];

  void saveTile(FarmTileModel tile) {
    _tiles[_key(tile.x, tile.y)] = tile;
  }

  List<FarmTileModel> getAllTiles() => List.unmodifiable(_tiles.values);

  void clear() {
    _tiles.clear();
    developer.log('[FarmTileStore] Cleared all tiles');
  }

  Map<String, dynamic> toJson() {
    return {'tiles': _tiles.values.map((tile) => tile.toJson()).toList()};
  }

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
