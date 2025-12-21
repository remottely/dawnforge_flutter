import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/conversation_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class BossEnemyDef {
  BossEnemyDef._();

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

  static Future<SpriteAnimation> loadAnimationIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: BossEnemyDef.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: BossEnemyDef.textureSize,
        ),
      );

  static SimpleDirectionAnimation createAnimationWalkDirectional() {
    return SimpleDirectionAnimation(
      idleLeft: loadAnimationIdleLeft(),
      idleRight: loadAnimationIdleRight(),
      runLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_run_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      runRight: SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_run_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
    );
  }

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 6.0,
    hitboxStartPositionY: 6.0,
  );

  static List<Say> createConversationSequence() {
    return [
      ConversationDef.createKidRight('talk_kid_1'),
      ConversationDef.createBossLeft('talk_boss_1'),
      ConversationDef.createPlayerLeft('talk_player_3'),
      ConversationDef.createBossRight('talk_boss_2'),
    ];
  }
}
