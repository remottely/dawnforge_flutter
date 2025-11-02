import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';

/// Classe base abstrata para todos os inimigos do jogo.
///
/// Esta classe agrupa a lógica e os mixins comuns a todos os inimigos:
/// - `SimpleEnemy`: A base de inimigo do Bonfire.
/// - `BlockMovementCollision`: Garante que o inimigo colida com "collision".
/// - `UseLifeBar`: Exibe automaticamente uma barra de vida.
///
/// Segue o padrão MVC, onde a View conhece apenas callbacks do Controller.
abstract class DDBaseEnemy<
  C extends DDBaseEnemyController,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  late final C controller;

  DDBaseEnemy({
    required Vector2 position,
    required Vector2 size,
    required SimpleDirectionAnimation animation,
    required double speed,
    required double life,
  }) : super(
         animation: animation,
         position: position,
         size: size,
         speed: speed,
         life: life,
       );

  /// Método abstrato que deve ser implementado pelas subclasses
  /// para criar e inicializar o controller específico.
  C createController(M model);

  /// Método abstrato que deve ser implementado pelas subclasses
  /// para criar o model específico.
  M createModel();

  /// Método abstrato para criar hitbox específica.
  RectangleHitbox createHitbox();

  @override
  Future<void> onLoad() {
    final model = createModel();
    controller = createController(model);
    add(createHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    controller.update(dt);
    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamageFx(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    handleDeathFx();
    removeFromParent();
    super.onDie();
  }

  @override
  void onRemove() {
    controller.dispose();
    super.onRemove();
  }

  /// Efeito de partícula de dano (comum a todos os inimigos).
  void showDamageFx(double damage) {
    showDamage(
      damage,
      config: CharacterFxParticlesAnimationsConfig.kEnemyShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
    );
  }

  /// Efeito de morte base (comum a todos os inimigos).
  /// Subclasses podem dar @override, chamar super.handleDeathFx() e adicionar mais lógica.
  void handleDeathFx() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterFxSpriteAnimationsConfig.createExplosionRight7(),
        position: position,
        size: size,
        loop: false,
      ),
    );
  }

  /// Callback padrão para seeAndMoveToPlayer que executa ataque corpo-a-corpo.
  /// Centraliza a lógica repetida em todos os inimigos.
  ///
  /// Uso:
  /// ```dart
  /// onSeeAndMoveToMeleeAttack: seeAndMoveToAttackMelee,
  /// ```
  void seeAndMoveToPrimaryAttack({
    required double closeVisionRadius,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        closePlayer.call(player);
        simpleAttackMelee(
          size: CharacterPrimaryAttackConfig.kEnemyPrimaryAttackFxSize,
          damage: controller.model.primaryAttackDamage,
          interval: controller.model.primaryAttackInterval,
          animationRight:
              CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
          execute: CharacterPrimaryAttackConfig.playEnemyExecutionSfx,
        );
      },
    );
  }

  /// Callback padrão para seeAndMoveToAttackRange que executa ataque à distância.
  /// Centraliza a lógica de ataque ranged (fireball) comum aos inimigos.
  ///
  /// Uso:
  /// ```dart
  /// onSeeAndMoveToAttackRange: seeAndMoveToAttackFireball,
  /// ```
  void seeAndMoveToFireballAttack({
    required double longVisionRadius,
    required void Function(Player) positioned,
  }) {
    seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (player) {
        simpleAttackRange(
          animation: CharacterFireballAttackConfig.createExecutionAnimation(),
          animationDestroy:
              CharacterFireballAttackConfig.createDestroyAnimation(),
          size: CharacterFireballAttackConfig.fComponentSize,
          damage: controller.model.primaryAttackDamage,
          speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
          execute: CharacterFireballAttackConfig.playExecutionAudio,
          onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
          collision: CharacterFireballAttackConfig.createHitbox(),
          lightingConfig: CharacterFireballAttackConfig.fLightingConfig,
        );
      },
    );
  }
}
