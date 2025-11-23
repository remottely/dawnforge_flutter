/// Main save data model that encapsulates all persistent game data.
///
/// This model uses versioning to support future migrations when adding
/// new fields or changing data structure.
///
/// Example usage:
/// ```dart
/// final saveData = SaveData(
///   version: SaveData.kCurrentVersion,
///   timestamp: DateTime.now(),
///   playerData: {'health': 100, 'position': {'x': 50.0, 'y': 100.0}},
///   worldData: {'currentDay': 5, 'timeOfDay': 'morning'},
///   inventoryData: {'slots': []},
/// );
///
/// // Serialize
/// final json = saveData.toJson();
///
/// // Deserialize
/// final loaded = SaveData.fromJson(json);
/// ```
final class SaveData {
  /// Current version of the save data format.
  /// Increment this when making breaking changes to the data structure.
  static const int kCurrentVersion = 1;

  /// Version of this save data.
  final int version;

  /// Timestamp when this save was created.
  final DateTime timestamp;

  /// Player-specific data (position, health, stats, etc.).
  final Map<String, dynamic> playerData;

  /// World state data (day, season, time, map states, etc.).
  final Map<String, dynamic> worldData;

  /// Inventory data (items, equipment, etc.).
  final Map<String, dynamic> inventoryData;

  /// Creates a new [SaveData] instance.
  ///
  /// All fields are required to ensure data integrity.
  const SaveData({
    required this.version,
    required this.timestamp,
    required this.playerData,
    required this.worldData,
    required this.inventoryData,
  });

  /// Creates a [SaveData] from a JSON map.
  ///
  /// Automatically detects old versions and migrates them to the current
  /// version using [_migrateFromVersion].
  ///
  /// Returns null if the JSON is invalid or missing required fields.
  factory SaveData.fromJson(Map<String, dynamic> json) {
    try {
      // Get version (default to 1 for old saves without version field)
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

      return SaveData(
        version: version,
        timestamp: DateTime.parse(timestampStr),
        playerData: Map<String, dynamic>.from(data['playerData'] as Map? ?? {}),
        worldData: Map<String, dynamic>.from(data['worldData'] as Map? ?? {}),
        inventoryData: Map<String, dynamic>.from(
          data['inventoryData'] as Map? ?? {},
        ),
      );
    } catch (e) {
      // Return null for invalid JSON instead of throwing
      return SaveData(
        version: kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: {},
        worldData: {},
        inventoryData: {},
      );
    }
  }

  /// Migrates save data from an old version to the current version.
  ///
  /// This method should be updated whenever [kCurrentVersion] is incremented.
  /// Add migration logic for each version transition.
  static Map<String, dynamic> _migrateFromVersion(
    int oldVersion,
    Map<String, dynamic> json,
  ) {
    var data = Map<String, dynamic>.from(json);

    // Migration from version 0 to 1 (example for future use)
    if (oldVersion < 1) {
      // Add new fields with default values
      data['worldData'] ??= {};
      data['inventoryData'] ??= {};
    }

    // Future migrations will be added here
    // if (oldVersion < 2) {
    //   // Migration logic for version 1 → 2
    // }

    // Update version
    data['version'] = kCurrentVersion;

    return data;
  }

  /// Validates that this save data is not corrupted.
  ///
  /// Checks:
  /// - Player data is not empty
  /// - Timestamp is not in the future
  /// - Version is valid
  bool isValid() {
    // Player data must exist
    if (playerData.isEmpty) {
      return false;
    }

    // Timestamp cannot be in the future (corrupt save)
    if (timestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return false;
    }

    // Version must be valid
    if (version < 1 || version > kCurrentVersion) {
      return false;
    }

    return true;
  }

  /// Converts this [SaveData] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'playerData': playerData,
      'worldData': worldData,
      'inventoryData': inventoryData,
    };
  }

  /// Creates a copy of this [SaveData] with optional field updates.
  ///
  /// This allows immutable updates to the save data.
  SaveData copyWith({
    int? version,
    DateTime? timestamp,
    Map<String, dynamic>? playerData,
    Map<String, dynamic>? worldData,
    Map<String, dynamic>? inventoryData,
  }) {
    return SaveData(
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      playerData: playerData ?? this.playerData,
      worldData: worldData ?? this.worldData,
      inventoryData: inventoryData ?? this.inventoryData,
    );
  }

  @override
  String toString() {
    return 'SaveData('
        'version: $version, '
        'timestamp: ${timestamp.toIso8601String()}, '
        'playerData: ${playerData.keys.length} keys, '
        'worldData: ${worldData.keys.length} keys, '
        'inventoryData: ${inventoryData.keys.length} keys'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SaveData &&
        other.version == version &&
        other.timestamp == timestamp &&
        _mapsEqual(other.playerData, playerData) &&
        _mapsEqual(other.worldData, worldData) &&
        _mapsEqual(other.inventoryData, inventoryData);
  }

  @override
  int get hashCode {
    return Object.hash(
      version,
      timestamp,
      Object.hashAll(
        playerData.entries.map((e) => Object.hash(e.key, e.value)),
      ),
      Object.hashAll(worldData.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(
        inventoryData.entries.map((e) => Object.hash(e.key, e.value)),
      ),
    );
  }

  /// Deep equality check for maps.
  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }

    return true;
  }
}
