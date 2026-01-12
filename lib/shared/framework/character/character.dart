// lib/shared/framework/character/character.dart (CORRIGIDO PARA BONFIRE 3.16.1)
import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/ui/emote_manager.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/character/character_config.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:flutter/foundation.dart';

/// Entidade base para todos os personagens (Player, NPC, Enemy)
abstract class Character extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final String id;
  final CharacterData data;
  final CharacterConfig config;

  final List<CharacterBehavior> _behaviors = [];

  // 🚀 OTIMIZAÇÃO 1: Cache de behaviors críticos
  CharacterBehavior? _cachedMovementBehavior;
  CharacterBehavior? _cachedCombatBehavior;
  CharacterBehavior? _cachedFarmingBehavior;

  // Regeneração de stamina
  async.Timer? _staminaRegenTimer;
  bool _isStaminaRegenPaused = false;
  int _activeStaminaActions = 0;

  // Action locking (para animações)
  int _activeActionLockCount = 0;
  JoystickDirectionalEvent? _bufferedDirectionalInput;

  Character({
    required this.id,
    required this.data,
    required this.config,
    required Vector2 position,
  }) : super(
         position: position,
         size: config.size,
         life: config.maxLife,
         speed: config.baseSpeed,
       );

  bool get isActionLocked => _activeActionLockCount > 0;

  // --- Lifecycle ---

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    anchor = Anchor.center;

    _setupVisuals();
    _restoreLifeFromData();
    _startStaminaRegeneration();

    // Anexa todos os behaviors
    for (final behavior in _behaviors) {
      behavior.attach(this);
    }

    // 🚀 OTIMIZAÇÃO 1: Cache behaviors críticos após attach
    _cacheFrequentlyUsedBehaviors();

    add(config.hitbox);
  }

  @override
  void update(double dt) {
    // Bloqueia movimento se market aberto
    if (MarketState.instance.isOpen.value) {
      stopMove();
      // ✅ CORREÇÃO: velocity é nullable no Bonfire 3.16.1
      velocity = Vector2.zero();
      return;
    }

    if (isDead) return;

    _syncDataToEntity();

    // 🚀 OTIMIZAÇÃO 1: Chama behaviors cached primeiro (mais críticos)
    _cachedMovementBehavior?.update(dt);
    _cachedCombatBehavior?.update(dt);
    _cachedFarmingBehavior?.update(dt);

    // 🚀 OTIMIZAÇÃO 2: Behaviors com update condicional
    for (final behavior in _behaviors) {
      if (behavior == _cachedMovementBehavior ||
          behavior == _cachedCombatBehavior ||
          behavior == _cachedFarmingBehavior) {
        continue;
      }

      if (behavior.needsUpdate) {
        behavior.update(dt);
      }
    }

    super.update(dt);
  }

  @override
  void onRemove() {
    _staminaRegenTimer?.cancel();

    for (final behavior in _behaviors) {
      behavior.dispose();
    }

    super.onRemove();
  }

  // --- Behaviors ---

  void addBehavior(CharacterBehavior behavior) {
    _behaviors.add(behavior);

    if (isMounted) {
      behavior.attach(this);
      _cacheFrequentlyUsedBehaviors();
    }
  }

  void removeBehavior(CharacterBehavior behavior) {
    behavior.dispose();
    _behaviors.remove(behavior);
    _cacheFrequentlyUsedBehaviors();
  }

  T? getBehavior<T extends CharacterBehavior>() {
    return _behaviors.whereType<T>().firstOrNull;
  }

  // 🚀 OTIMIZAÇÃO 1: Cache behaviors críticos
  void _cacheFrequentlyUsedBehaviors() {
    _cachedMovementBehavior = _behaviors
        .where((b) => b.runtimeType.toString().contains('Movement'))
        .firstOrNull;

    _cachedCombatBehavior = _behaviors
        .where((b) => b.runtimeType.toString().contains('Combat'))
        .firstOrNull;

    _cachedFarmingBehavior = _behaviors
        .where((b) => b.runtimeType.toString().contains('Farming'))
        .firstOrNull;
  }

  // --- Input ---

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (MarketState.instance.isOpen.value) {
      stopMove();
      return;
    }

    _bufferedDirectionalInput = event;
    _updateFacingDirection(event);

    if (isActionLocked) return;

    super.onJoystickChangeDirectional(event);
  }

  void _updateFacingDirection(JoystickDirectionalEvent event) {
    final dir = switch (event.directional) {
      JoystickMoveDirectional.MOVE_LEFT => Direction.left,
      JoystickMoveDirectional.MOVE_RIGHT => Direction.right,
      JoystickMoveDirectional.MOVE_UP => Direction.up,
      JoystickMoveDirectional.MOVE_DOWN => Direction.down,
      JoystickMoveDirectional.MOVE_UP_LEFT => Direction.upLeft,
      JoystickMoveDirectional.MOVE_UP_RIGHT => Direction.upRight,
      JoystickMoveDirectional.MOVE_DOWN_LEFT => Direction.downLeft,
      JoystickMoveDirectional.MOVE_DOWN_RIGHT => Direction.downRight,
      _ => null,
    };

    if (dir != null) {
      lastDirection = dir;
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (MarketState.instance.isOpen.value) {
      GameLogger.info('[Character] Input ignored: market open');
      return;
    }

    if (isDead) {
      GameLogger.info('[Character] Input ignored: character dead');
      return;
    }

    GameLogger.info(
      '[Character] 🎮 Input: ${event.id} | event: ${event.event} | equipped: ${data.equippedItemId}',
    );

    // 🚀 OTIMIZAÇÃO 1: Chama cached behaviors primeiro
    if (_cachedCombatBehavior?.onInput(event) ?? false) return;
    if (_cachedFarmingBehavior?.onInput(event) ?? false) return;
    if (_cachedMovementBehavior?.onInput(event) ?? false) return;

    for (final behavior in _behaviors) {
      if (behavior == _cachedCombatBehavior ||
          behavior == _cachedFarmingBehavior ||
          behavior == _cachedMovementBehavior) {
        continue;
      }

      if (behavior.onInput(event)) {
        return;
      }
    }

    super.onJoystickAction(event);
  }

  // --- Action Locking ---

  void lockAction() {
    _activeActionLockCount++;
    GameLogger.info(
      '[Character] 🔒 Action LOCKED (count: $_activeActionLockCount)',
    );
  }

  void unlockAction() {
    if (_activeActionLockCount > 0) {
      _activeActionLockCount--;
      GameLogger.info(
        '[Character] 🔓 Action UNLOCKED (count: $_activeActionLockCount)',
      );

      if (_activeActionLockCount == 0) {
        GameLogger.info('[Character] ✅ Action FULLY UNLOCKED');
        _restoreBufferedMovementInput();
      }
    }
  }

  void _restoreBufferedMovementInput() {
    final buffered = _bufferedDirectionalInput;
    if (buffered != null &&
        buffered.directional != JoystickMoveDirectional.IDLE) {
      super.onJoystickChangeDirectional(buffered);
    }
  }

  // --- Damage & Death ---

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;

    _displayDamageEffects(damage);

    for (final behavior in _behaviors) {
      behavior.onReceiveDamage(damage);
    }

    super.onReceiveDamage(attacker, damage, id);
    _syncDataToEntity();
  }

  @override
  void onDie() {
    _displayDeathEffects();

    for (final behavior in _behaviors) {
      behavior.onDie();
    }

    removeFromParent();
    super.onDie();
  }

  // --- Stamina System ---

  void _startStaminaRegeneration() {
    _staminaRegenTimer = async.Timer.periodic(
      config.staminaRegenDebounce,
      (_) => _processStaminaRegen(),
    );
  }

  void _processStaminaRegen() {
    if (_isStaminaRegenPaused || data.stamina >= data.maxStamina) {
      return;
    }

    data.restoreStamina(config.staminaRegenRate);
  }

  void beginStaminaConsumingAction() {
    _activeStaminaActions++;
    if (_activeStaminaActions == 1) {
      _isStaminaRegenPaused = true;
    }
  }

  void endStaminaConsumingAction() {
    _activeStaminaActions--;
    if (_activeStaminaActions <= 0) {
      _activeStaminaActions = 0;
      _isStaminaRegenPaused = false;
    }
  }

  // --- Emotes ---

  void displayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        animation: EmoteManager.loadExclamationEmote(),
        target: this,
      ),
    );
  }

  // --- Enemy Detection ---

  void detectEnemies({
    required double radius,
    required VoidCallback notObserved,
    required void Function(List<Enemy> enemies) observed,
  }) {
    seeEnemy(
      radiusVision: radius,
      notObserved: () {
        data.isObservingEnemy = false;
        notObserved();
      },
      observed: (List<Enemy> enemies) {
        if (!data.isObservingEnemy) {
          data.isObservingEnemy = true;
          displayExclamationEmote();
        }
        observed(enemies);
      },
    );
  }

  // --- Private Helpers ---

  void _setupVisuals() {
    setupLighting(config.lighting);
    setupMovementByJoystick(intensityEnabled: true);
  }

  void _restoreLifeFromData() {
    final savedLife = data.life;
    if (savedLife != null && savedLife < life) {
      final damageToApply = life - savedLife;
      handleAttack(AttackOriginEnum.WORLD, damageToApply, 'restore_from_save');
    }
  }

  void _syncDataToEntity() {
    if (data.life != life) {
      data.updateLife(life);
    }

    data.position = position;

    // ✅ CORREÇÃO: velocity pode ser null no Bonfire 3.16.1
    data.velocity = velocity ?? Vector2.zero();

    data.direction = _directionToString(lastDirection);
  }

  String _directionToString(Direction dir) {
    switch (dir) {
      case Direction.up:
        return 'up';
      case Direction.down:
        return 'down';
      case Direction.left:
        return 'left';
      case Direction.right:
        return 'right';
      default:
        return 'down';
    }
  }

  void _displayDamageEffects(double damage) {
    // Pode ser sobrescrito
  }

  void _displayDeathEffects() {
    if (config.getDeathMarker != null) {
      // ✅ CORREÇÃO: Usa hasGameRef antes de acessar
      if (hasGameRef) {
        gameRef.add(config.getDeathMarker!(position));
      }
    }
  }
}
