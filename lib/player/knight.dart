import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Knight extends SimplePlayer with Lighting, BlockMovementCollision {
  double attackDamage = 25;
  double currentStamina = 100;
  async.Timer? _staminaRegenerationTimer;
  bool hasKey = false;
  bool isObservingEnemy = false;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize),
          position: position,
          life: 200,
          speed: tileSize * 2.5,
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
    setupMovementByJoystick(intensityEnabled: true);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(valueByTileSize(8), valueByTileSize(8)),
        position: Vector2(
          valueByTileSize(4),
          valueByTileSize(8),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      executeBasicAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      executeBasicAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ &&
        event.event == ActionEvent.DOWN) {
      executeRangedAttack();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      executeRangedAttack();
    }
    super.onJoystickAction(event);
  }

  @override
  void onDie() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(
          position.x,
          position.y,
        ),
        size: Vector2.all(30),
      ),
    );
    super.onDie();
  }

  void executeBasicAttack() {
    if (currentStamina < 15) {
      return;
    }

    Sounds.attackPlayerMelee();
    decrementStamina(15);
    simpleAttackMelee(
      damage: attackDamage,
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      size: Vector2.all(tileSize),
    );
  }

  void executeRangedAttack() {
    if (currentStamina < 10) {
      return;
    }

    Sounds.attackRange();

    decrementStamina(10);
    simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2(tileSize * 0.65, tileSize * 0.65),
      damage: 10,
      speed: speed * 2.5,
      onDestroy: () {
        Sounds.explosion();
      },
      collision: RectangleHitbox(
        size: Vector2(tileSize / 3, tileSize / 3),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: tileSize * 0.9,
        blurBorder: tileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _regenerateStamina();
    seeEnemy(
      radiusVision: tileSize * 6,
      notObserved: () {
        isObservingEnemy = false;
      },
      observed: (enemies) {
        if (isObservingEnemy) return;
        isObservingEnemy = true;
        _displayEmoteAbovePlayer();
      },
    );
    super.update(dt);
  }

  void _regenerateStamina() {
    if (_staminaRegenerationTimer == null) {
      _staminaRegenerationTimer = async.Timer(
        Duration(milliseconds: 150),
        () {
          _staminaRegenerationTimer = null;
        },
      );
    } else {
      return;
    }

    currentStamina += 2;
    if (currentStamina > 100) {
      currentStamina = 100;
    }
  }

  void decrementStamina(int amount) {
    currentStamina -= amount;
    if (currentStamina < 0) {
      currentStamina = 0;
    }
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void _displayEmoteAbovePlayer(
      {String emotePath = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          emotePath,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        loop: false,
        size: Vector2.all(tileSize / 2),
        offset: Vector2(18, -6),
      ),
    );
  }
}
