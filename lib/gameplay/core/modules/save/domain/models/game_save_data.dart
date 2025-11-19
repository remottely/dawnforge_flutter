import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/farm_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/inventory_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/player_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/world_save_data.dart';

/// Main save data model with strongly-typed domain models.
///
/// This is the root save data object that encapsulates all game state
/// using typed domain models instead of generic maps.
///
/// **Benefits:**
/// - Type-safe access to all save data
/// - Easy to test and validate
/// - IDE auto-completion support
/// - Compile-time error detection
/// - Scalable for future features
///
/// **Example:**
/// ```dart
/// final saveData = GameSaveData(
///   version: GameSaveData.kCurrentVersion,
///   timestamp: DateTime.now(),
///   player: PlayerSaveData.initial(playerType: 'knight'),
///   world: WorldSaveData.initial(),
///   inventory: InventorySaveData.initial(),
///   farm: FarmSaveData.initial(),
/// );
///
/// // Type-safe access
/// print('Player level: ${saveData.player.level}');
/// print('Current day: ${saveData.world.currentDay}');
/// ```
final class GameSaveData {
  /// Current version of the save data format.
  /// Increment when making breaking changes.
  static const int kCurrentVersion = 2;

  /// Version of this save data.
  final int version;

  /// Timestamp when this save was created.
  final DateTime timestamp;

  /// Player-specific data (strongly-typed).
  final PlayerSaveData player;

  /// World state data (strongly-typed).
  final WorldSaveData world;

  /// Inventory data (strongly-typed).
  final InventorySaveData inventory;

  /// Farm data (strongly-typed).
  final FarmSaveData farm;

  /// Player progress flags and achievements.
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

  /// Creates initial game state for a new game.
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

  /// Creates from JSON map with migration support.
  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    try {
      // Get version (default to 1 for old saves)
      var version = json['version'] as int? ?? 1;
      var data = json;

      // Migrate if necessary
      if (version < kCurrentVersion) {
        data = _migrateFromVersion(version, json);
        version = kCurrentVersion;
      }

      // Parse timestamp
      final timestampStr = data['timestamp'] as String?;
      if (timestampStr == null) {
        throw ArgumentError('Missing required field: timestamp');
      }

      // Parse strongly-typed models (tolerant to Map<dynamic, dynamic> from JSON literals)
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
      // Return default state on error (better than crashing)
      return GameSaveData.newGame(
        playerType: 'knight',
      ); // TODO(kevin): this is the best behavior?
    }
  }

  /// Migrates save data from old version to current version.
  static Map<String, dynamic> _migrateFromVersion(
    int oldVersion,
    Map<String, dynamic> json,
  ) {
    var data = Map<String, dynamic>.from(json);

    // Helper to recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
    dynamic _deepConvertMap(dynamic value) {
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), _deepConvertMap(v)));
      } else if (value is List) {
        return value.map((e) => _deepConvertMap(e)).toList();
      }
      return value;
    }

    // Deep convert to ensure all nested maps are Map<String, dynamic>
    data = _deepConvertMap(data) as Map<String, dynamic>;

    // Migration from version 1 to 2 (typed models)
    if (oldVersion < 2) {
      // Rename old keys to new structure
      if (data.containsKey('playerData') && !data.containsKey('player')) {
        data['player'] = data.remove('playerData');
      }
      if (data.containsKey('worldData') && !data.containsKey('world')) {
        data['world'] = data.remove('worldData');
      }
      if (data.containsKey('inventoryData') && !data.containsKey('inventory')) {
        data['inventory'] = data.remove('inventoryData');
      }

      // Extract farm data from world data if present
      if (data['world'] is Map<String, dynamic>) {
        final worldData = data['world'] as Map<String, dynamic>;
        if (worldData.containsKey('farmData') && !data.containsKey('farm')) {
          data['farm'] = worldData.remove('farmData');
        }
      }

      // Add progress if missing
      data['progress'] ??= {};
    }

    // Future migrations will be added here
    // if (oldVersion < 3) { ... }

    data['version'] = kCurrentVersion;
    return data;
  }

  /// Validates that this save data is not corrupted.
  bool isValid() {
    return player.isValid() &&
        world.isValid() &&
        inventory.isValid() &&
        farm.isValid() &&
        version > 0 &&
        version <= kCurrentVersion &&
        !timestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  /// Converts to JSON map.
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

  /// Creates a copy with optional field updates.
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

  /// Gets a human-readable summary of this save.
  String getSummary() {
    return '''
Save Summary (v$version):
- Saved: ${timestamp.toLocal()}
- Player: ${player.playerName ?? player.playerType} (Level ${player.level})
- Day: ${world.currentDay} of ${world.seasonDisplayName}, Year ${world.currentYear}
- Time: ${world.getFormattedTime()}
- Money: \$${player.money}
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
        '\$${player.money}, '
        '${inventory.usedSlots} items, '
        '${farm.totalCrops} crops'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSaveData &&
        other.version == version &&
        other.timestamp == timestamp &&
        other.player == player &&
        other.world == world &&
        other.inventory == inventory &&
        other.farm == farm;
  }

  @override
  int get hashCode {
    return Object.hash(version, timestamp, player, world, inventory, farm);
  }
}
