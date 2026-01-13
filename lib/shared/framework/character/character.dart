// lib/shared/framework/character/character.dart (CORREÇÃO FINAL)
import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/ui/emote_manager.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/character/character_config.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:flutter/foundation.dart';

abstract class Character extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final String id;
  final CharacterData data;
  final CharacterConfig config;

  final List<CharacterBehavior> _behaviors = [];

  CharacterBehavior? _cachedMovementBehavior;
  CharacterBehavior? _cachedCombatBehavior;
  CharacterBehavior? _cachedFarmingBehavior;

  async.Timer? _staminaRegenTimer;
  bool _isStaminaRegenPaused = false;
  int _activeStaminaActions = 0;

  int _activeActionLockCount = 0;
  JoystickDirectionalEvent? _bufferedDirectionalInput;
  async.Timer? _actionLockTimeout; // ✅ NOVO: Timeout de segurança

  Character({
    required this.id,
    required this.data,
    required this.config,
    required Vector2 position,
    SimpleDirectionAnimation? animation,
  }) : super(
         position: position,
         size: config.size,
         life: config.maxLife,
         speed: config.baseSpeed,
         animation: animation,
       ) {
    // ✅ CRÍTICO: Seta anchor NO CONSTRUTOR!
    anchor = Anchor.center;
  }

  bool get isActionLocked => _activeActionLockCount > 0;

  // --- Lifecycle ---

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ❌ REMOVIDO: anchor = Anchor.center; (já setado no construtor)

    _setupVisuals();
    _restoreLifeFromData();
    _startStaminaRegeneration();

    for (final behavior in _behaviors) {
      behavior.attach(this);
    }

    _cacheFrequentlyUsedBehaviors();
    add(config.hitbox);
  }

  @override
  void update(double dt) {
    if (MarketState.instance.isOpen.value) {
      stopMove();
      velocity = Vector2.zero();
      return;
    }

    if (isDead) return;

    _syncDataToEntity();

    _cachedMovementBehavior?.update(dt);
    _cachedCombatBehavior?.update(dt);
    _cachedFarmingBehavior?.update(dt);

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
    _actionLockTimeout?.cancel(); // ✅ NOVO

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

    if (isActionLocked) {
      GameLogger.info('[Character] ⚠️ Movement blocked: action locked');
      return;
    }

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

    // ✅ PARAR MOVIMENTO QUANDO TRAVAR AÇÃO
    if (_activeActionLockCount == 1) {
      stopMove(); // ← ADICIONE AQUI!
      GameLogger.info('[Character] 🛑 Movement STOPPED (action locked)');
    }

    GameLogger.info(
      '[Character] 🔒 Action LOCKED (count: $_activeActionLockCount)',
    );

    // Timeout de segurança
    _actionLockTimeout?.cancel();
    _actionLockTimeout = async.Timer(const Duration(seconds: 3), () {
      if (_activeActionLockCount > 0) {
        GameLogger.warning(
          '[Character] ⚠️ Action lock TIMEOUT! Force unlocking... '
          '(count was: $_activeActionLockCount)',
        );
        _activeActionLockCount = 0;
        _restoreBufferedMovementInput();
      }
    });
  }

  void unlockAction() {
    if (_activeActionLockCount > 0) {
      _activeActionLockCount--;
      GameLogger.info(
        '[Character] 🔓 Action UNLOCKED (count: $_activeActionLockCount)',
      );

      if (_activeActionLockCount == 0) {
        _actionLockTimeout?.cancel();
        GameLogger.info('[Character] ✅ Action FULLY UNLOCKED');
        _restoreBufferedMovementInput();
      }
    } else {
      GameLogger.warning(
        '[Character] ⚠️ unlockAction() called but count already 0!',
      );
    }
  }

  void _restoreBufferedMovementInput() {
    final bufferedEvent = _bufferedDirectionalInput;
    if (bufferedEvent != null &&
        bufferedEvent.directional != JoystickMoveDirectional.IDLE) {
      GameLogger.info('[Character] 🔄 Restoring buffered movement input');
      super.onJoystickChangeDirectional(bufferedEvent);
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
      if (hasGameRef) {
        gameRef.add(config.getDeathMarker!(position));
      }
    }
  }
}
