import 'package:equatable/equatable.dart';

/// Domain model for player-specific save data.
///
/// Strongly-typed model that represents all persistent player state
/// for a Stardew Valley-style farming/RPG game.
///
/// **Design Principles:**
/// - Immutable with copyWith for updates
/// - Type-safe with explicit fields
/// - Easy to test and validate
/// - Scalable for future features
final class PlayerSaveData extends Equatable {
  /// Player's current position in the world
  final double positionX;
  final double positionY;

  /// Player's current map/area identifier
  final String currentMapId;

  /// Player's facing direction (left, right, up, down)
  final String direction;

  /// Player stats
  final double health;
  final double maxHealth;
  final double stamina;
  final double maxStamina;
  final double energy;
  final double maxEnergy;

  /// Player's current level and experience
  final int level;
  final int experience;
  final int experienceToNextLevel;

  /// Player skills (Stardew Valley style)
  final int farmingLevel;
  final int miningLevel;
  final int foragingLevel;
  final int fishingLevel;
  final int combatLevel;

  /// Player's wallet
  final int money;

  /// Player type identifier (knight, sunny, etc.)
  final String playerType;

  /// Player name (optional customization)
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
    required this.money,
    required this.playerType,
    this.playerName,
  });

  /// Creates default initial state for a new game.
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
      money: 500,
      playerType: playerType,
      playerName: playerName,
    );
  }

  /// Creates from JSON map (deserialization).
  factory PlayerSaveData.fromJson(Map<String, dynamic> json) {
    return PlayerSaveData(
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
      money: json['money'] as int? ?? 500,
      playerType: json['playerType'] as String? ?? 'knight',
      playerName: json['playerName'] as String?,
    );
  }

  /// Converts to JSON map (serialization).
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
      'money': money,
      'playerType': playerType,
      if (playerName != null) 'playerName': playerName,
    };
  }

  /// Validates that the data is in a valid state.
  bool isValid() {
    return health >= 0 &&
        health <= maxHealth &&
        maxHealth > 0 &&
        stamina >= 0 &&
        stamina <= maxStamina &&
        maxStamina > 0 &&
        energy >= 0 &&
        energy <= maxEnergy &&
        maxEnergy > 0 &&
        level > 0 &&
        experience >= 0 &&
        money >= 0 &&
        currentMapId.isNotEmpty &&
        playerType.isNotEmpty;
  }

  /// Creates a copy with updated fields.
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
    int? money,
    String? playerType,
    String? playerName,
  }) {
    return PlayerSaveData(
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
      money: money ?? this.money,
      playerType: playerType ?? this.playerType,
      playerName: playerName ?? this.playerName,
    );
  }

  @override
  String toString() {
    return 'PlayerSaveData('
        'type: $playerType, '
        'name: ${playerName ?? "Unknown"}, '
        'level: $level, '
        'health: $health/$maxHealth, '
        'money: $money, '
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
    money,
    playerType,
    playerName,
  ];
}
