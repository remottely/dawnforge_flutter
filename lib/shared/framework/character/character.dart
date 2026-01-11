// lib/shared/framework/character/character.dart
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

  // Regeneração de stamina
  async.Timer? _staminaRegenTimer;
  bool _isStaminaRegenPaused = false;
  int _activeStaminaActions = 0;

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
         animation: null,
       ) {
    anchor = Anchor.center;
  }

  // --- Lifecycle ---

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _setupVisuals();
    _restoreLifeFromData();
    _startStaminaRegeneration();

    // Anexa todos os behaviors
    for (final behavior in _behaviors) {
      behavior.attach(this);
    }

    add(config.hitbox);
  }

  @override
  void update(double dt) {
    // Bloqueia movimento se market aberto
    if (MarketState.instance.isOpen.value) {
      stopMove();
      velocity = Vector2.zero();
      return;
    }

    if (isDead) return;

    _syncDataToEntity();

    // Atualiza behaviors
    for (final behavior in _behaviors) {
      behavior.update(dt);
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

    // Se já está loaded, anexa imediatamente
    if (isMounted) {
      behavior.attach(this);
    }
  }

  void removeBehavior(CharacterBehavior behavior) {
    behavior.dispose();
    _behaviors.remove(behavior);
  }

  T? getBehavior<T extends CharacterBehavior>() {
    return _behaviors.whereType<T>().firstOrNull;
  }

  // --- Input ---

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

    // Propaga para behaviors (primeiro que consumir ganha)
    for (final behavior in _behaviors) {
      if (behavior.onInput(event)) {
        return; // Behavior consumiu o input
      }
    }

    // Se nenhum behavior consumiu, passa para o Bonfire padrão
    super.onJoystickAction(event);
  }

  // --- Damage & Death ---

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;

    _displayDamageEffects(damage);

    // Notifica behaviors
    for (final behavior in _behaviors) {
      behavior.onReceiveDamage(damage);
    }

    super.onReceiveDamage(attacker, damage, id);
    _syncDataToEntity();
  }

  @override
  void onDie() {
    _displayDeathEffects();

    // Notifica behaviors
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
    // Life
    if (data.life != life) {
      data.updateLife(life);
    }

    // Position
    data.position = position;

    // Velocity
    data.velocity = velocity;

    // Direction
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
    // Pode ser sobrescrito por subclasses
    // showDamage(damage, config: ...);
  }

  void _displayDeathEffects() {
    if (config.getDeathMarker != null) {
      gameRef.add(config.getDeathMarker!(position));
    }
  }
}
