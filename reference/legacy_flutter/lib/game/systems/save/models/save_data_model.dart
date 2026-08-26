final class SaveData {
  static const int kCurrentVersion = 1;

  final int version;

  final DateTime timestamp;

  final Map<String, dynamic> playerData;

  final Map<String, dynamic> worldData;

  final Map<String, dynamic> inventoryData;

  const SaveData({
    required this.version,
    required this.timestamp,
    required this.playerData,
    required this.worldData,
    required this.inventoryData,
  });

  factory SaveData.fromJson(Map<String, dynamic> json) {
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
      return SaveData(
        version: kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: {},
        worldData: {},
        inventoryData: {},
      );
    }
  }

  static Map<String, dynamic> _migrateFromVersion(
    int oldVersion,
    Map<String, dynamic> json,
  ) {
    var data = Map<String, dynamic>.from(json);

    if (oldVersion < 1) {
      data['worldData'] ??= {};
      data['inventoryData'] ??= {};
    }

    data['version'] = kCurrentVersion;

    return data;
  }

  bool isValid() {
    if (playerData.isEmpty) {
      return false;
    }

    if (timestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return false;
    }

    if (version < 1 || version > kCurrentVersion) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'playerData': playerData,
      'worldData': worldData,
      'inventoryData': inventoryData,
    };
  }

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

  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }

    return true;
  }
}
