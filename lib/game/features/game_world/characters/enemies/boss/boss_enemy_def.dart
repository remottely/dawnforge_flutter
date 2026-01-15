import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/systems/ui/conversation_def.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class BossEnemyDef {
  BossEnemyDef._();

  static final double fixedLifeBarWidth =
      CharacterConstants.fixedLifeBarWidthLarge;
  static final Vector2 fixedLifeBarOffset =
      CharacterConstants.fixedLifeBarOffsetNone;

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const double kPrimaryAttackDamage =
      CharacterConstants.kDamageExtraLarge;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalExtraLarge;

  static const double kLife = CharacterConstants.kLifeBoss;
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
