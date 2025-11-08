import 'dart:async' as async;
import 'dart:math' as math;

import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec.dart';

class SynchronizedAttackController {
  SynchronizedAttackController({required SynchronizedAttackSpec spec})
    : _spec = spec,
      _model = SynchronizedAttackModel(
        baseAttackSpeedMs: spec.baseAttackSpeedMs,
        attackTypeMultipliers: spec.attackTypeMultipliers,
        speedBonusPerLevel: spec.speedBonusPerLevel,
      );

  final SynchronizedAttackSpec _spec;
  final SynchronizedAttackModel _model;

  async.Timer? _cooldownTimer;
  final Map<String, async.Timer> _modifierTimers = {};

  void Function(AttackExecutionInfo info)? _onAttackExecuted;
  void Function(AttackExecutionInfo info)? _onAttackDestroyed;
  void Function(AttackType type, Duration remaining)? _onAttackBlocked;
  void Function(AttackExecutionInfo info)? _onAnimationSync;
  void Function(Duration duration)? _onAnimationDurationChanged;

  bool get canPerformAttack => _model.canAttack;

  AttackExecutionInfo? execute(
    AttackType attackType,
    void Function() attackAction, {
    void Function()? visualEffectCallback,
  }) {
    if (!_model.canAttack) {
      final remaining = getRemainingCooldown();
      _onAttackBlocked?.call(attackType, remaining);
      return null;
    }

    _model.purgeExpiredModifiers();
    final durations = _calculateDurations(attackType);

    final info = AttackExecutionInfo(
      type: attackType,
      executionTime: DateTime.now(),
      cooldownDuration: durations.cooldown,
      animationDuration: durations.animation,
      playerLevel: _model.playerLevel,
      activeModifiers: Map.of(_model.temporaryModifiers),
    );

    _model.canAttack = false;
    _model.lastAttackInfo = info;
    _model.startCooldown(durations.cooldown);

    _cooldownTimer?.cancel();
    _cooldownTimer = async.Timer(durations.cooldown, () {
      _model.canAttack = true;
      _cooldownTimer = null;
    });

    attackAction();
    visualEffectCallback?.call();

    _onAnimationDurationChanged?.call(durations.animation);
    _onAnimationSync?.call(info);
    _onAttackExecuted?.call(info);
    Future.delayed(info.animationDuration, () {
      _onAttackDestroyed?.call(info);
    });

    return info;
  }

  void setOnAttackExecutedCallback(
    void Function(AttackExecutionInfo info)? callback,
  ) {
    _onAttackExecuted = callback;
  }

  void setOnAttackDestroyedCallback(
    void Function(AttackExecutionInfo info)? callback,
  ) {
    _onAttackDestroyed = callback;
  }

  void setOnAttackBlockedCallback(
    void Function(AttackType type, Duration remaining)? callback,
  ) {
    _onAttackBlocked = callback;
  }

  void setOnAnimationSyncCallback(
    void Function(AttackExecutionInfo info)? callback,
  ) {
    _onAnimationSync = callback;
  }

  void setOnAnimationDurationChangedCallback(
    void Function(Duration duration)? callback,
  ) {
    _onAnimationDurationChanged = callback;
  }

  void updateBaseAttackSpeed(int baseAttackSpeedMs) {
    _model.updateBaseAttackSpeed(baseAttackSpeedMs);
  }

  void updateAttackTypeMultipliers(
    Map<AttackType, double> attackTypeMultipliers,
  ) {
    _model.updateAttackTypeMultipliers(attackTypeMultipliers);
  }

  void updateSpeedBonusPerLevel(double speedBonusPerLevel) {
    _model.updateSpeedBonusPerLevel(speedBonusPerLevel);
  }

  void levelUp(int newLevel) {
    if (newLevel <= 0) return;
    _model.playerLevel = newLevel;
  }

  void addAttackSpeedModifier(AttackSpeedModifier modifier) {
    _model.addModifier(modifier);
    final duration = modifier.duration;
    if (duration != null) {
      _modifierTimers[modifier.name]?.cancel();
      _modifierTimers[modifier.name] = async.Timer(duration, () {
        removeAttackSpeedModifier(modifier.name);
      });
    }
  }

  void removeAttackSpeedModifier(String name) {
    _modifierTimers.remove(name)?.cancel();
    _model.removeModifier(name);
  }

  void clearAttackSpeedModifiers() {
    for (final timer in _modifierTimers.values) {
      timer.cancel();
    }
    _modifierTimers.clear();
    _model.clearModifiers();
  }

  Duration getRemainingCooldown() => _model.getRemainingCooldown();

  double getCooldownProgress() => _model.getCooldownProgress();

  AttackExecutionInfo? get lastAttackInfo => _model.lastAttackInfo;

  double getCurrentAttackSpeed(AttackType type) {
    final cooldown = _calculateDurations(type).cooldown.inMilliseconds;
    if (cooldown == 0) return 0;
    return 1000.0 / cooldown;
  }

  Duration getCalculatedCooldown(AttackType type) =>
      _calculateDurations(type).cooldown;

  Duration getCalculatedAnimationDuration(AttackType type) =>
      _calculateDurations(type).animation;

  Map<String, dynamic> getStatus() {
    return {
      'spec': _spec.toMap(),
      'canAttack': _model.canAttack,
      'playerLevel': _model.playerLevel,
      'baseAttackSpeedMs': _model.baseAttackSpeedMs,
      'speedBonusPerLevel': _model.speedBonusPerLevel,
      'lastAttack': _model.lastAttackInfo?.toMap(),
      'remainingCooldownMs': getRemainingCooldown().inMilliseconds,
      'cooldownProgress': getCooldownProgress(),
      'activeModifiers': {
        for (final entry in _model.temporaryModifiers.entries)
          entry.key: entry.value.toMap(),
      },
      'attackTypeMultipliers': {
        for (final entry in _model.attackTypeMultipliers.entries)
          entry.key.name: entry.value,
      },
      'isTimerActive': _cooldownTimer?.isActive ?? false,
    };
  }

  void dispose() {
    _cooldownTimer?.cancel();
    clearAttackSpeedModifiers();
  }

  AttackDurations _calculateDurations(AttackType attackType) {
    final typeMultiplier = _model.attackTypeMultipliers[attackType] ?? 1.0;
    final levelBonus = math.max(
      0.1,
      1.0 - (_model.speedBonusPerLevel * (_model.playerLevel - 1)),
    );

    double modifierMultiplier = 1.0;
    for (final modifier in _model.activeModifiers) {
      modifierMultiplier *= modifier.speedMultiplier;
    }

    final cooldownMs =
        (_model.baseAttackSpeedMs *
                typeMultiplier *
                levelBonus *
                modifierMultiplier)
            .round();

    final cooldownDuration = Duration(milliseconds: cooldownMs);
    final animationDuration = Duration(
      milliseconds: (cooldownMs * 0.8).round(),
    );

    return AttackDurations(
      cooldown: cooldownDuration,
      animation: animationDuration,
    );
  }
}
