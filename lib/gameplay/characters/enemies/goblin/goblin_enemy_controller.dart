import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class GoblinEnemyController {
  late GoblinEnemyView _view;

  void attachView(GoblinEnemyView view) => _view = view;

  void onUpdate(double dt) {
    _view.seeAndMoveToPlayer(
      closePlayer: (player) {
        playPrimaryAttackAnimation();
      },
      radiusVision: CharacterConfig.kVisionRadiusLarge,
    );
  }

  void playPrimaryAttackAnimation() {
    _view.simpleAttackMelee(
      size: Vector2.all(GoblinEnemyConfig.kAttackEffectSize),
      damage: GoblinEnemyConfig.kAttackDamage,
      interval: GoblinEnemyConfig.kAttackInterval,
      animationRight:
          CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
      execute: () {
        GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
      },
    );
  }

  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamage(
      damage,
      config:
          CharacterEffectsParticlesAnimationsConfig.kEnemyShowDamageTextStyle,
      gravity: CharacterEffectsParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical: CharacterEffectsParticlesAnimationsConfig
          .kShowDamageInitVelocityVertical,
    );
  }

  void onDie() {
    _view.gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectsSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: _view.position,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
    _view.removeFromParent();
  }
}
