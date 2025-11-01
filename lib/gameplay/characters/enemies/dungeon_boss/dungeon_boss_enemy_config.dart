import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_factory.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonBossEnemyConfig {
  static const double kPrimaryAttackDamage = 40.0;
  static const double kPrimaryAttackEffectSize = 10.0;
  static const double kLife = 200.0;
  static const double kSpeed = CharacterConfig.kCharacterSpeedSlow;
  static const double kVisionRadiusLarge = CharacterConfig.kVisionRadiusLarge;
  static const double kVisionRadiusUltraLarge =
      CharacterConfig.kVisionRadiusUltraLarge;

  static final Vector2 fTextureSize = Vector2(32, 36);
  static final Vector2 fComponentSize = fTextureSize;

  static final SimpleDirectionAnimation
  fDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(5, 11), size: Vector2(14, 16));

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationFactory.kidRightDialog('talk_kid_1'),
      GameplayConversationFactory.bossLeftDialog('talk_boss_1'),
      GameplayConversationFactory.knightLeftDialog('talk_player_3'),
      GameplayConversationFactory.bossRightDialog('talk_boss_2'),
    ];
  }
}
