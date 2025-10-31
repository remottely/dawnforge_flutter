import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_basic_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

class ImpEnemyController {
  late ImpEnemyView _view;

  void attachView(ImpEnemyView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _view.seeAndMoveToPlayer(
      radiusVision: CharacterConfig.kVisionRadiusExtraLarge,
      closePlayer: (player) {
        playPrimaryAttackAnimation();
      },
    );
  }

  void playPrimaryAttackAnimation() {
    _view.simpleAttackMelee(
      size: Vector2.all(ImpEnemyConfig.kAttackEffectSize),
      damage: ImpEnemyConfig.kAttackDamage,
      interval: ImpEnemyConfig.kAttackInterval,
      animationRight:
          CharacterPrimaryAttackConfig.loadEnemyExecutionAnimation(),
      execute: () {
        GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
      },
    );
  }

  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamage(
      damage,
      config: CharacterParticlesAnimations.kEnemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  void onDie() {
    _view.gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: _view.position,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
    _view.removeFromParent();
  }
}
