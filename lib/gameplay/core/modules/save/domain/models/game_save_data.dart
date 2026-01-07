import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/farm_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/inventory_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/player_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/world_save_data.dart';
import 'package:equatable/equatable.dart';

final class GameSaveData extends Equatable {
  static const int kCurrentVersion = 2;

  final int version;

  final DateTime timestamp;

  final PlayerSaveData player;

  final WorldSaveData world;

  final InventorySaveData inventory;

  final FarmSaveData farm;

  final Map<String, dynamic> progress;

  const GameSaveData({
    required this.version,
    required this.timestamp,
    required this.player,
    required this.world,
    required this.inventory,
    required this.farm,
    required this.progress,
  });

  factory GameSaveData.newGame({
    required String playerType,
    String? playerName,
    String farmLayout = 'standard',
  }) {
    return GameSaveData(
      version: kCurrentVersion,
      timestamp: DateTime.now(),
      player: PlayerSaveData.initial(
        playerType: playerType,
        playerName: playerName,
      ),
      world: WorldSaveData.initial(),
      inventory: InventorySaveData.initial(),
      farm: FarmSaveData.initial(layout: farmLayout),
      progress: {},
    );
  }

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    try {
      var version = json['version'] as int? ?? 1;
      var data = json;

      if (version < kCurrentVersion) {
        data = _migrateFromVersion(version, json);
        version = kCurrentVersion;
      }

      final timestampStr = data['timestamp'] as String?;
      if (timestampStr == null) {
        throw ArgumentError('Missing required field: timestamp');
      }

      final playerData =
          (data['player'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
          (data['playerData'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          <String, dynamic>{};

      final worldData =
          (data['world'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
          (data['worldData'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          <String, dynamic>{};

      final inventoryData =
          (data['inventory'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          (data['inventoryData'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          <String, dynamic>{};

      final farmData =
          (data['farm'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
          ((worldData['farmData'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          )) ??
          <String, dynamic>{};

      final progressData =
          (data['progress'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          <String, dynamic>{};

      return GameSaveData(
        version: version,
        timestamp: DateTime.parse(timestampStr),
        player: PlayerSaveData.fromJson(playerData),
        world: WorldSaveData.fromJson(worldData),
        inventory: InventorySaveData.fromJson(inventoryData),
        farm: FarmSaveData.fromJson(farmData),
        progress: progressData,
      );
    } catch (e) {
      return GameSaveData.newGame(playerType: 'knight');
    }
  }

  static Map<String, dynamic> _migrateFromVersion(
    int oldVersion,
    Map<String, dynamic> json,
  ) {
    var data = Map<String, dynamic>.from(json);

    dynamic _deepConvertMap(dynamic value) {
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), _deepConvertMap(v)));
      } else if (value is List) {
        return value.map((e) => _deepConvertMap(e)).toList();
      }
      return value;
    }

    data = _deepConvertMap(data) as Map<String, dynamic>;

    if (oldVersion < 2) {
      if (data.containsKey('playerData') && !data.containsKey('player')) {
        data['player'] = data.remove('playerData');
      }
      if (data.containsKey('worldData') && !data.containsKey('world')) {
        data['world'] = data.remove('worldData');
      }
      if (data.containsKey('inventoryData') && !data.containsKey('inventory')) {
        data['inventory'] = data.remove('inventoryData');
      }

      if (data['world'] is Map<String, dynamic>) {
        final worldData = data['world'] as Map<String, dynamic>;
        if (worldData.containsKey('farmData') && !data.containsKey('farm')) {
          data['farm'] = worldData.remove('farmData');
        }
      }

      data['progress'] ??= {};
    }

    data['version'] = kCurrentVersion;
    return data;
  }

  bool isValid() {
    return player.isValid() &&
        world.isValid() &&
        inventory.isValid() &&
        farm.isValid() &&
        version > 0 &&
        version <= kCurrentVersion &&
        !timestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'player': player.toJson(),
      'world': world.toJson(),
      'inventory': inventory.toJson(),
      'farm': farm.toJson(),
      'progress': progress,
    };
  }

  GameSaveData copyWith({
    int? version,
    DateTime? timestamp,
    PlayerSaveData? player,
    WorldSaveData? world,
    InventorySaveData? inventory,
    FarmSaveData? farm,
    Map<String, dynamic>? progress,
  }) {
    return GameSaveData(
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      player: player ?? this.player,
      world: world ?? this.world,
      inventory: inventory ?? this.inventory,
      farm: farm ?? this.farm,
      progress: progress ?? this.progress,
    );
  }

  String getSummary() {
    return '''
Save Summary (v$version):
- Saved: ${timestamp.toLocal()}
- Player: ${player.playerName ?? player.playerType} (Level ${player.level})
- Day: ${world.currentDay} of ${world.seasonDisplayName}, Year ${world.currentYear}
- Time: ${world.getFormattedTime()}
- Coins: \$${player.coins}
- Inventory: ${inventory.usedSlots}/${inventory.maxInventorySlots} slots
- Equipment: ${inventory.equippedItems.length} items
- Farm: ${farm.totalCrops} crops, ${farm.totalAnimals} animals, ${farm.totalBuildings} buildings
    '''
        .trim();
  }

  @override
  String toString() {
    return 'GameSaveData('
        'v$version, '
        '${player.playerType} Lv${player.level}, '
        'Day ${world.currentDay}, '
        '\$${player.coins}, '
        '${inventory.usedSlots} items, '
        '${farm.totalCrops} crops'
        ')';
  }

  @override
  List<Object?> get props => [
    version,
    timestamp,
    player,
    world,
    inventory,
    farm,
  ];
}
