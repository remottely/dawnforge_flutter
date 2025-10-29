import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/gameplay_character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonBossEnemyConfig {
  static const kAttackDamage = 40.0;
  static const kLife = 200.0;
  static const kSpeed = GameplayCharacterConfig.kCharacterSpeedSlow;
  static const kAttackEffectSize = 10.0;
  static const kVisionRadiusLarge = GameplayCharacterConfig.kVisionRadiusLarge;
  static const kVisionRadiusUltraLarge =
      GameplayCharacterConfig.kVisionRadiusUltraLarge;

  static final fTextureSize = Vector2(32, 36);
  static final fComponentSize = fTextureSize;

  static final fDirectionalSpriteAnimation = SimpleDirectionAnimation(
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
      GameplayConversationConfig.kidRightDialog('talk_kid_1'),
      GameplayConversationConfig.bossLeftDialog('talk_boss_1'),
      GameplayConversationConfig.knightLeftDialog('talk_player_3'),
      GameplayConversationConfig.bossRightDialog('talk_boss_2'),
    ];
  }
}
