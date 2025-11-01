import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class ImpEnemyController {
  late ImpEnemyView _view;

  void attachView(ImpEnemyView view) => _view = view;

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
            CharacterEffectsSpriteAnimationsConfig.characterExplosionSmokeRight5(),
        position: _view.position,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
    _view.removeFromParent();
  }
}
