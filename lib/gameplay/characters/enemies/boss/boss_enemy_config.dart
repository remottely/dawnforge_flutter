import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/conversation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class BossEnemyConfig {
  BossEnemyConfig._();

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const double kPrimaryAttackDamage =
      CharacterConstants.kDamageExtraLarge;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalExtraLarge;

  static const double kLife = CharacterConstants.kLifeExtraLarge;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static final Vector2 textureSize = Vector2(32, 36);
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: UISpriteAnimationsConfig.loadBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimationsConfig.loadBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/boss/boss_enemy_run_left_4.png',
      SpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/boss/boss_enemy_run_right_4.png',
      SpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 6.0,
    hitboxStartPositionY: 6.0,
  );

  static List<Say> createConversationSequence() {
    return [
      ConversationConfig.createKidRight('talk_kid_1'),
      ConversationConfig.createBossLeft('talk_boss_1'),
      ConversationConfig.createKnightLeft('talk_player_3'),
      ConversationConfig.createBossRight('talk_boss_2'),
    ];
  }
}
