import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// ImpEnemyController
/// ---------------------------------------------------------------------------
/// Orchestrates logic, AI, and communication between Model (data) and View (Bonfire component) for the Imp enemy.
class ImpEnemyController {
  late ImpEnemyView _view;

  /// Attach the View to the Controller
  void attachView(ImpEnemyView view) {
    _view = view;
  }

  /// Called every game tick by the View
  void onUpdate(double dt) {
    _view.seeAndMoveToPlayer(
      radiusVision: GameplayConstants.kVisionRadiusExtraLarge,
      closePlayer: (player) {
        playAttackAnimation();
      },
    );
  }

  /// Triggers the attack animation and logic
  void playAttackAnimation() {
    _view.simpleAttackMelee(
      size: Vector2.all(ImpEnemyConfig.attackEffectSize),
      damage: ImpEnemyConfig.attackDamage,
      interval: ImpEnemyConfig.attackInterval,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.instance.playAttackEnemyMelee();
      },
    );
  }

  /// Handles logic when the Imp receives damage
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamage(
      damage,
      config: CharacterParticlesAnimations.enemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  /// Handles logic when the Imp dies
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
