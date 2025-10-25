import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// GoblinEnemyController
/// ---------------------------------------------------------------------------
/// Orchestrates logic, AI, and communication between Model (data) and View (Bonfire component) for the Goblin enemy.
class GoblinEnemyController {
  late GoblinEnemyView _view;

  /// Attach the View to the Controller
  void attachView(GoblinEnemyView view) {
    _view = view;
  }

  /// Called every game tick by the View
  void onUpdate(double dt) {
    _view.seeAndMoveToPlayer(
      closePlayer: (player) {
        playAttackAnimation();
      },
      radiusVision: GameplayConstants.kVisionRadiusLarge,
    );
  }

  /// Triggers the attack animation and logic
  void playAttackAnimation() {
    _view.simpleAttackMelee(
      size: Vector2.all(GoblinEnemyConfig.attackEffectSize),
      damage: GoblinEnemyConfig.attackDamage,
      interval: GoblinEnemyConfig.attackInterval,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.instance.playAttackEnemyMelee();
      },
    );
  }

  /// Handles logic when the Goblin receives damage
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamage(
      damage,
      config: CharacterParticlesAnimations.enemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  /// Handles logic when the Goblin dies
  void onDie() {
    _view.gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: _view.position,
        size: GameplayConstants.kTileSizeStandard,
        loop: false,
      ),
    );
    _view.removeFromParent();
  }
}
