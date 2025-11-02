import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class DungeonBossEnemyConfig {
  DungeonBossEnemyConfig._();

  static const double kCloseVisionRadius =
      CharacterConfig.kVisionRadiusExtraLarge;
  static const double kPrimaryAttackDamage = CharacterConfig.kDamageExtraLarge;
  static const int kPrimaryAttackInterval = CharacterConfig.kAttackIntervalExtraLarge;

  static const double kLife = CharacterConfig.kLifeExtraLarge;
  static const double kSpeed = CharacterConfig.kSpeedSlow;

  static final Vector2 textureSize = Vector2(32, 36);
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: UISpriteAnimationsConfig.loadDungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimationsConfig.loadDungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(5, 11), size: Vector2(14, 16));

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationConfig.createKidRightDialog('talk_kid_1'),
      GameplayConversationConfig.createBossLeftDialog('talk_boss_1'),
      GameplayConversationConfig.createKnightLeftDialog('talk_player_3'),
      GameplayConversationConfig.createBossRightDialog('talk_boss_2'),
    ];
  }
}
