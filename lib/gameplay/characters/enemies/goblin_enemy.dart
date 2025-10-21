import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

/// Enemy character Goblin for the Darkness Dungeon game
/// Following Flutter naming conventions for enemy entity systems
///
/// This class handles:
/// - Basic melee combat with player detection
/// - Movement and collision detection
/// - Death effects and visual feedback
/// - Audio integration for attacks and damage
///
/// Usage patterns:
/// ```dart
/// final goblin = GoblinEnemy(position);
/// goblin.onLoad();
/// ```

abstract class _GoblinEnemyData {
  static const double attackDamage = 25.0;
  static const double life = 120.0;
  static const double speed = GameplayConstants.kCharacterSpeedSlow;
  static const int attackInterval = 800;
  static Vector2 get hitboxSize => Vector2.all(7.0);
  static Vector2 get hitboxPosition => Vector2(3.0, 4.0);
  static Vector2 get _spriteSize =>
      Vector2.all(GameplayConstants.kTileSizeDefault * 0.8);
  static double get attackEffectSize =>
      GameplayConstants.kTileSizeDefault * 0.62;
  static void loadHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
}

class GoblinEnemy extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  double _attackDamage = _GoblinEnemyData.attackDamage;

  GoblinEnemy(Vector2 position)
    : super(
        animation: EnemySpriteAnimations.goblinEnemyAnimation(),
        position: position,
        size: _GoblinEnemyData._spriteSize,
        speed: _GoblinEnemyData.speed,
        life: _GoblinEnemyData.life,
      );

  @override
  Future<void> onLoad() {
    _GoblinEnemyData.loadHitBox(this);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    seeAndMoveToPlayer(
      closePlayer: (player) {
        _executeAttack();
      },
      radiusVision: GameplayConstants.kVisionRadiusLarge,
    );
  }

  @override
  void onDie() {
    _handleDeathEffects();
    removeFromParent();
    super.onDie();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    showDamage(
      damage,
      config: TextStyle(fontSize: 5, color: Colors.white, fontFamily: 'Normal'),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void _executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(_GoblinEnemyData.attackEffectSize),
      damage: _attackDamage,
      interval: _GoblinEnemyData.attackInterval,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  void _handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: position,
        size: GameplayConstants.kTileVector2Default,
        loop: false,
      ),
    );
  }
}
