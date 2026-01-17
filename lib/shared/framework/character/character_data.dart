// lib/shared/framework/character/character_data.dart (ADICIONAR MÉTODOS)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:flutter/foundation.dart';

/// Estado puro do personagem (serializável para network/save)
class CharacterData {
  // Stats
  double stamina;
  double maxStamina;
  int energy;
  int maxEnergy;
  double? life;
  double maxLife;
  int coins;

  // Posição e movimento
  Vector2 position;
  Vector2 velocity;
  String direction;

  // Estado
  bool isObservingEnemy;
  int lastActionTimestamp;

  // Equipamento
  HandItemId? equippedItemId;

  // Snapshot
  CharacterData? _previousSnapshot;

  // ValueNotifier para UI reativa
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);

  CharacterData({
    required this.stamina,
    required this.maxStamina,
    required this.energy,
    required this.maxEnergy,
    this.life,
    required this.maxLife,
    required this.coins,
    required this.position,
    required this.velocity,
    this.direction = 'down',
    this.isObservingEnemy = false,
    this.lastActionTimestamp = 0,
    this.equippedItemId,
  }) {
    coinsNotifier.value = coins;
  }

  // --- Validações ---

  bool get hasStamina => stamina > 0;
  bool get isAlive => life != null && life! > 0;

  bool canConsumeStamina(double amount) => stamina >= amount;
  bool canAffordCoins(int amount) => coins >= amount;

  // --- Mutações ---

  bool tryConsumeStamina(double amount) {
    if (!canConsumeStamina(amount)) return false;
    stamina = (stamina - amount).clamp(0, maxStamina);
    return true;
  }

  void consumeStamina(double amount) {
    stamina = (stamina - amount).clamp(0, maxStamina);
  }

  void restoreStamina(double amount) {
    stamina = (stamina + amount).clamp(0, maxStamina);
  }

  void restoreStaminaFully() {
    stamina = maxStamina;
  }

  bool tryConsumeEnergy(int amount) {
    if (energy < amount) return false;
    energy = (energy - amount).clamp(0, maxEnergy);
    return true;
  }

  void restoreEnergy() {
    energy = maxEnergy;
  }

  void updateLife(double value) {
    life = value.clamp(0, maxLife);
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    coins += amount;
    coinsNotifier.value = coins;
  }

  bool tryRemoveCoins(int amount) {
    if (!canAffordCoins(amount)) return false;
    coins -= amount;
    coinsNotifier.value = coins;
    return true;
  }

  // ✅ NOVO: removeCoins (retorna bool)
  bool removeCoins(int amount) {
    return tryRemoveCoins(amount);
  }

  void setEquipment(HandItemId? itemId) {
    equippedItemId = itemId;
  }

  void setPosition(Vector2 newPosition) {
    position = newPosition;
  }

  // --- Snapshot ---

  void saveSnapshot() {
    _previousSnapshot = CharacterData(
      stamina: stamina,
      maxStamina: maxStamina,
      energy: energy,
      maxEnergy: maxEnergy,
      life: life,
      maxLife: maxLife,
      coins: coins,
      position: position.clone(),
      velocity: velocity.clone(),
      direction: direction,
      isObservingEnemy: isObservingEnemy,
      lastActionTimestamp: lastActionTimestamp,
      equippedItemId: equippedItemId,
    );
  }

  void restoreSnapshot() {
    if (_previousSnapshot == null) return;

    stamina = _previousSnapshot!.stamina;
    energy = _previousSnapshot!.energy;
    life = _previousSnapshot!.life;
    coins = _previousSnapshot!.coins;
    coinsNotifier.value = coins;
    position = _previousSnapshot!.position.clone();
    velocity = _previousSnapshot!.velocity.clone();
    direction = _previousSnapshot!.direction;
    isObservingEnemy = _previousSnapshot!.isObservingEnemy;
    lastActionTimestamp = _previousSnapshot!.lastActionTimestamp;
    equippedItemId = _previousSnapshot!.equippedItemId;
  }

  // --- Serialização ---

  Map<String, dynamic> toJson() => {
    'stamina': stamina,
    'maxStamina': maxStamina,
    'energy': energy,
    'maxEnergy': maxEnergy,
    'life': life,
    'maxLife': maxLife,
    'coins': coins,
    'position': {'x': position.x, 'y': position.y},
    'velocity': {'x': velocity.x, 'y': velocity.y},
    'direction': direction,
    'isObservingEnemy': isObservingEnemy,
    'lastActionTimestamp': lastActionTimestamp,
    'equippedItemId': equippedItemId?.name,
  };

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
      stamina: (json['stamina'] as num?)?.toDouble() ?? 100.0,
      maxStamina: (json['maxStamina'] as num?)?.toDouble() ?? 100.0,
      energy: (json['energy'] as num?)?.toInt() ?? 100,
      maxEnergy: (json['maxEnergy'] as num?)?.toInt() ?? 100,
      life: (json['life'] as num?)?.toDouble(),
      maxLife: (json['maxLife'] as num?)?.toDouble() ?? 100.0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      position: json['position'] != null
          ? Vector2(
              (json['position']['x'] as num).toDouble(),
              (json['position']['y'] as num).toDouble(),
            )
          : Vector2.zero(),
      velocity: json['velocity'] != null
          ? Vector2(
              (json['velocity']['x'] as num).toDouble(),
              (json['velocity']['y'] as num).toDouble(),
            )
          : Vector2.zero(),
      direction: json['direction'] as String? ?? 'down',
      isObservingEnemy: json['isObservingEnemy'] as bool? ?? false,
      lastActionTimestamp: json['lastActionTimestamp'] as int? ?? 0,
      equippedItemId: json['equippedItemId'] != null
          ? HandItemId.fromString(json['equippedItemId'] as String)
          : null,
    );
  }

  factory CharacterData.defaultPlayer({
    double maxStamina = 100.0,
    int maxEnergy = 100,
    double maxLife = 100.0,
    int coins = 530,
    Vector2? position,
  }) {
    return CharacterData(
      stamina: maxStamina,
      maxStamina: maxStamina,
      energy: maxEnergy,
      maxEnergy: maxEnergy,
      life: maxLife,
      maxLife: maxLife,
      coins: coins,
      velocity: Vector2.zero(),
      position: position ?? Vector2.zero(),
    );
  }

  CharacterData clone() {
    return CharacterData(
      stamina: stamina,
      maxStamina: maxStamina,
      energy: energy,
      maxEnergy: maxEnergy,
      life: life,
      maxLife: maxLife,
      coins: coins,
      position: position.clone(),
      velocity: velocity.clone(),
      direction: direction,
      isObservingEnemy: isObservingEnemy,
      lastActionTimestamp: lastActionTimestamp,
      equippedItemId: equippedItemId,
    );
  }

  void dispose() {
    coinsNotifier.dispose();
  }
}
