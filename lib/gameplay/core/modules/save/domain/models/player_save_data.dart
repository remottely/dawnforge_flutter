import 'package:equatable/equatable.dart';

final class PlayerSaveData extends Equatable {
  static const int kInitialCoins = 520;
  final double positionX;
  final double positionY;

  final String currentMapId;

  final String direction;

  final double health;
  final double maxHealth;
  final double stamina;
  final double maxStamina;
  final double energy;
  final double maxEnergy;

  final int level;
  final int experience;
  final int experienceToNextLevel;

  final int farmingLevel;
  final int miningLevel;
  final int foragingLevel;
  final int fishingLevel;
  final int combatLevel;

  final int coins;

  final String playerType;

  final String? playerName;

  const PlayerSaveData({
    required this.positionX,
    required this.positionY,
    required this.currentMapId,
    required this.direction,
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.energy,
    required this.maxEnergy,
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.farmingLevel,
    required this.miningLevel,
    required this.foragingLevel,
    required this.fishingLevel,
    required this.combatLevel,
    required this.coins,
    required this.playerType,
    this.playerName,
  })  : assert(health > 0, 'health must be > 0'),
        assert(stamina > 0, 'stamina must be > 0'),
        assert(energy > 0, 'energy must be > 0'),
        assert(coins >= 0, 'coins must be >= 0'),
        assert(maxHealth > 0, 'maxHealth must be > 0'),
        assert(maxStamina > 0, 'maxStamina must be > 0'),
        assert(maxEnergy > 0, 'maxEnergy must be > 0');

  factory PlayerSaveData.initial({
    required String playerType,
    String? playerName,
  }) {
    return PlayerSaveData(
      positionX: 0.0,
      positionY: 0.0,
      currentMapId: 'farm',
      direction: 'down',
      health: 100.0,
      maxHealth: 100.0,
      stamina: 100.0,
      maxStamina: 100.0,
      energy: 100.0,
      maxEnergy: 100.0,
      level: 1,
      experience: 0,
      experienceToNextLevel: 100,
      farmingLevel: 1,
      miningLevel: 1,
      foragingLevel: 1,
      fishingLevel: 1,
      combatLevel: 1,
      coins: kInitialCoins,
      playerType: playerType,
      playerName: playerName,
    );
  }

  factory PlayerSaveData.fromJson(Map<String, dynamic> json) {
    final data = PlayerSaveData(
      positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
      currentMapId: json['currentMapId'] as String? ?? 'farm',
      direction: json['direction'] as String? ?? 'down',
      health: (json['health'] as num?)?.toDouble() ?? 100.0,
      maxHealth: (json['maxHealth'] as num?)?.toDouble() ?? 100.0,
      stamina: (json['stamina'] as num?)?.toDouble() ?? 100.0,
      maxStamina: (json['maxStamina'] as num?)?.toDouble() ?? 100.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 100.0,
      maxEnergy: (json['maxEnergy'] as num?)?.toDouble() ?? 100.0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      experienceToNextLevel: json['experienceToNextLevel'] as int? ?? 100,
      farmingLevel: json['farmingLevel'] as int? ?? 1,
      miningLevel: json['miningLevel'] as int? ?? 1,
      foragingLevel: json['foragingLevel'] as int? ?? 1,
      fishingLevel: json['fishingLevel'] as int? ?? 1,
      combatLevel: json['combatLevel'] as int? ?? 1,
      coins: _readCoins(json),
      playerType: json['playerType'] as String? ?? 'knight',
      playerName: json['playerName'] as String?,
    );

    data._throwIfPersistenceRuleBreak();
    return data;
  }

  static int _readCoins(Map<String, dynamic> json) {
    final coinsValue = json['coins'];
    if (coinsValue is num) return coinsValue.toInt();
    throw ArgumentError('PlayerSaveData.fromJson: missing coins in payload');
  }

  Map<String, dynamic> toJson() {
    return {
      'positionX': positionX,
      'positionY': positionY,
      'currentMapId': currentMapId,
      'direction': direction,
      'health': health,
      'maxHealth': maxHealth,
      'stamina': stamina,
      'maxStamina': maxStamina,
      'energy': energy,
      'maxEnergy': maxEnergy,
      'level': level,
      'experience': experience,
      'experienceToNextLevel': experienceToNextLevel,
      'farmingLevel': farmingLevel,
      'miningLevel': miningLevel,
      'foragingLevel': foragingLevel,
      'fishingLevel': fishingLevel,
      'combatLevel': combatLevel,
      'coins': coins,
      'playerType': playerType,
      if (playerName != null) 'playerName': playerName,
    };
  }

  bool isValid() {
    return health > 0 &&
        health <= maxHealth &&
        maxHealth > 0 &&
        stamina > 0 &&
        stamina <= maxStamina &&
        maxStamina > 0 &&
        energy > 0 &&
        energy <= maxEnergy &&
        maxEnergy > 0 &&
        level > 0 &&
        experience >= 0 &&
        coins >= 0 &&
        currentMapId.isNotEmpty &&
        playerType.isNotEmpty;
  }

  PlayerSaveData copyWith({
    double? positionX,
    double? positionY,
    String? currentMapId,
    String? direction,
    double? health,
    double? maxHealth,
    double? stamina,
    double? maxStamina,
    double? energy,
    double? maxEnergy,
    int? level,
    int? experience,
    int? experienceToNextLevel,
    int? farmingLevel,
    int? miningLevel,
    int? foragingLevel,
    int? fishingLevel,
    int? combatLevel,
    int? coins,
    String? playerType,
    String? playerName,
  }) {
    final data = PlayerSaveData(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      currentMapId: currentMapId ?? this.currentMapId,
      direction: direction ?? this.direction,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      stamina: stamina ?? this.stamina,
      maxStamina: maxStamina ?? this.maxStamina,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      experienceToNextLevel:
          experienceToNextLevel ?? this.experienceToNextLevel,
      farmingLevel: farmingLevel ?? this.farmingLevel,
      miningLevel: miningLevel ?? this.miningLevel,
      foragingLevel: foragingLevel ?? this.foragingLevel,
      fishingLevel: fishingLevel ?? this.fishingLevel,
      combatLevel: combatLevel ?? this.combatLevel,
      coins: coins ?? this.coins,
      playerType: playerType ?? this.playerType,
      playerName: playerName ?? this.playerName,
    );

    data._throwIfPersistenceRuleBreak();
    return data;
  }

  // Guard against persisting impossible player states.
  void _throwIfPersistenceRuleBreak() {
    if (coins < 0) {
      throw StateError('PlayerSaveData persistence: coins cannot be negative');
    }
    if (health <= 0) {
      throw StateError('PlayerSaveData persistence: health must be > 0');
    }
    if (stamina <= 0) {
      throw StateError('PlayerSaveData persistence: stamina must be > 0');
    }
    if (energy <= 0) {
      throw StateError('PlayerSaveData persistence: energy must be > 0');
    }
  }

  @override
  String toString() {
    return 'PlayerSaveData('
        'type: $playerType, '
        'name: ${playerName ?? "Unknown"}, '
        'level: $level, '
        'health: $health/$maxHealth, '
        'coins: $coins, '
        'position: ($positionX, $positionY), '
        'map: $currentMapId'
        ')';
  }

  @override
  List<Object?> get props => [
    positionX,
    positionY,
    currentMapId,
    direction,
    health,
    maxHealth,
    stamina,
    maxStamina,
    energy,
    maxEnergy,
    level,
    experience,
    experienceToNextLevel,
    farmingLevel,
    miningLevel,
    foragingLevel,
    fishingLevel,
    combatLevel,
    coins,
    playerType,
    playerName,
  ];
}
