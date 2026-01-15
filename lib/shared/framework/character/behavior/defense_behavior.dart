// lib/shared/framework/character/behavior/defense_behavior.dart (CORRIGIDO FINAL)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class DefenseConfig {
  final double blockDamageReduction;
  final double blockStaminaCostPerHit;
  final double parryWindowMs;
  final double parryDamageReflection;

  const DefenseConfig({
    this.blockDamageReduction = 0.5,
    this.blockStaminaCostPerHit = 5.0,
    this.parryWindowMs = 200.0,
    this.parryDamageReflection = 0.3,
  });
}

class DefenseBehavior extends CharacterBehavior {
  final DefenseConfig config;

  bool _isBlocking = false;
  int _blockStartTime = 0;

  DefenseBehavior(this.config);

  @override
  bool onInput(JoystickActionEvent event) {
    final equipment = character.data.equippedItemId;

    // Shield block
    if (InputDef.isDefenseAction(event.id) &&
        equipment == HandItemId.shield) {
      if (event.event == ActionEvent.DOWN) {
        _startBlocking();
        return true;
      } else if (event.event == ActionEvent.UP) {
        _stopBlocking();
        return true;
      }
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isBlocking) {
      character.speed = character.config.baseSpeed * 0.3;
    }
  }

  @override
  void onReceiveDamage(double damage) {
    super.onReceiveDamage(damage);

    if (!_isBlocking) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceBlockStart = now - _blockStartTime;

    if (timeSinceBlockStart <= config.parryWindowMs) {
      _executeParry(damage);
    } else {
      _executeBlock(damage);
    }
  }

  void _startBlocking() {
    if (_isBlocking) return;

    _isBlocking = true;
    _blockStartTime = DateTime.now().millisecondsSinceEpoch;

    character.lockAction();

    _displayBlockStartEffect();

    GameLogger.info('[DefenseBehavior] ✓ Blocking started');
  }

  void _stopBlocking() {
    if (!_isBlocking) return;

    _isBlocking = false;

    character.unlockAction();
    character.speed = character.config.baseSpeed;

    _displayBlockEndEffect();

    GameLogger.info('[DefenseBehavior] ✓ Blocking stopped');
  }

  void _executeBlock(double incomingDamage) {
    final reducedDamage = incomingDamage * (1.0 - config.blockDamageReduction);
    final blockedDamage = incomingDamage - reducedDamage;

    if (!character.data.tryConsumeStamina(config.blockStaminaCostPerHit)) {
      _stopBlocking();
      GameLogger.warning('[DefenseBehavior] Block broken (no stamina)');
      return;
    }

    final newLife = (character.life - reducedDamage)
        .clamp(0, character.config.maxLife)
        .toDouble();
    character.updateLife(newLife);
    character.data.updateLife(newLife);

    _displayBlockEffect(blockedDamage);

    GameLogger.info(
      '[DefenseBehavior] ✓ Blocked! Incoming: $incomingDamage, '
      'Reduced: $reducedDamage, Blocked: $blockedDamage',
    );
  }

  void _executeParry(double incomingDamage) {
    GameLogger.info('[DefenseBehavior] ⚡ PARRY! Perfect timing!');

    final reflectedDamage = incomingDamage * config.parryDamageReflection;

    _reflectDamageToAttacker(reflectedDamage);

    _displayParryEffect();
  }

  void _reflectDamageToAttacker(double damage) {
    character.seeEnemy(
      radiusVision: 64,
      observed: (List<Enemy> enemies) {
        if (enemies.isNotEmpty) {
          final nearestEnemy = enemies.first;

          // ✅ CORREÇÃO: Usa handleAttack (método público do Attackable mixin)
          if (nearestEnemy is Attackable) {
            (nearestEnemy as Attackable).handleAttack(
              AttackOriginEnum.PLAYER_OR_ALLY,
              damage,
              'parry_reflection',
            );

            GameLogger.info(
              '[DefenseBehavior] ⚡ Reflected $damage damage to enemy!',
            );
          }
        }
      },
      notObserved: () {},
    );
  }

  void _displayBlockStartEffect() {
    // TODO: Adiciona sprite de shield na frente do player
    // Exemplo:
    // final shieldSprite = GameDecoration.withSprite(
    //   sprite: Sprite.load('shield.png'),
    //   position: character.position + Vector2(0, -16),
    //   size: Vector2(32, 32),
    // );
    // character.gameRef.add(shieldSprite);
  }

  void _displayBlockEndEffect() {
    // TODO: Remove sprite de shield
  }

  void _displayBlockEffect(double blockedDamage) {
    // TODO: Partículas de shield impact
    // Exemplo:
    // character.gameRef.add(
    //   AnimatedGameObject(
    //     animation: ShieldImpactAnimation(),
    //     position: character.position,
    //   )
    // );
  }

  void _displayParryEffect() {
    // TODO: VFX especial de parry perfeito
    // - Flash dourado no player
    // - Slow motion (character.gameRef.timeScale = 0.3)
    // - Partículas de estrela
    // - Som especial de parry

    GameLogger.info('[DefenseBehavior] 🌟 Parry VFX triggered');
  }

  @override
  void dispose() {
    if (_isBlocking) {
      _stopBlocking();
    }
    super.dispose();
  }
}
