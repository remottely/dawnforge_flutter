import 'package:dawnforge/game/systems/combat/synchronized_attack/synchronized_attack_entities.dart';

class SynchronizedAttackModel {
  SynchronizedAttackModel({
    required this._baseAttackSpeedMs,
    required Map<AttackType, double> attackTypeMultipliers,
    required this._speedBonusPerLevel,
  }) : _attackTypeMultipliers = Map.of(attackTypeMultipliers);

  int _baseAttackSpeedMs;
  Map<AttackType, double> _attackTypeMultipliers;
  double _speedBonusPerLevel;
  int _playerLevel = 1;
  bool _canAttack = true;

  final Map<String, AttackSpeedModifier> _temporaryModifiers = {};

  AttackExecutionInfo? _lastAttackInfo;
  DateTime? _cooldownStart;
  Duration _currentCooldown = Duration.zero;

  int get baseAttackSpeedMs => _baseAttackSpeedMs;
  Map<AttackType, double> get attackTypeMultipliers => _attackTypeMultipliers;
  double get speedBonusPerLevel => _speedBonusPerLevel;
  int get playerLevel => _playerLevel;
  bool get canAttack => _canAttack;
  Map<String, AttackSpeedModifier> get temporaryModifiers =>
      _temporaryModifiers;
  AttackExecutionInfo? get lastAttackInfo => _lastAttackInfo;
  DateTime? get cooldownStart => _cooldownStart;
  Duration get currentCooldown => _currentCooldown;

  set playerLevel(int value) => _playerLevel = value;
  set canAttack(bool value) => _canAttack = value;
  set lastAttackInfo(AttackExecutionInfo? value) => _lastAttackInfo = value;

  void updateBaseAttackSpeed(int value) => _baseAttackSpeedMs = value;

  void updateAttackTypeMultipliers(Map<AttackType, double> multipliers) {
    _attackTypeMultipliers = Map.of(multipliers);
  }

  void updateSpeedBonusPerLevel(double value) => _speedBonusPerLevel = value;

  void addModifier(AttackSpeedModifier modifier) {
    _temporaryModifiers[modifier.name] = modifier;
  }

  AttackSpeedModifier? removeModifier(String name) =>
      _temporaryModifiers.remove(name);

  void clearModifiers() => _temporaryModifiers.clear();

  Iterable<AttackSpeedModifier> get activeModifiers sync* {
    for (final modifier in _temporaryModifiers.values) {
      if (!modifier.isExpired) {
        yield modifier;
      }
    }
  }

  void purgeExpiredModifiers() {
    final expired = _temporaryModifiers.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    for (final key in expired) {
      _temporaryModifiers.remove(key);
    }
  }

  void startCooldown(Duration cooldown) {
    _currentCooldown = cooldown;
    _cooldownStart = DateTime.now();
  }

  Duration getRemainingCooldown() {
    if (_cooldownStart == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_cooldownStart!);
    final remaining = _currentCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double getCooldownProgress() {
    if (_currentCooldown == Duration.zero) return 1.0;
    final remaining = getRemainingCooldown();
    final progress =
        (_currentCooldown.inMilliseconds - remaining.inMilliseconds) /
        _currentCooldown.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }
}
