import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class KnightPlayerDef {
  KnightPlayerDef._();

  static const double kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;

  static const double kLife = CharacterConstants.kLifeExtraLarge;

  static double kSpeed = CharacterConstants.kSpeedFast;

  static const double kMaxStamina = 100.0;

  static const int kStaminaIncrement = 1;

  // static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const int kMaxEnergy = 100;

  static const double kPrimaryAttackDamage = 25.0;

  static const int kPrimaryAttackStaminaCost = 15;

  static const double kFireballAttackDamage = 10.0;

  static const int kFireballAttackStaminaCost = 10;

  static const int kShovelStaminaCost = 5;

  static const int kWateringCanStaminaCost = 5;

  static const int kSeedStaminaCost = 5;

  static const int kHarvestStaminaCost = 5;

  static final Vector2 textureSize = TileConstants.tileSizeStandard;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox hitbox = HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 8.0,
  );

  static final Future<SpriteAnimation> loadAnimationIdleRight =
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: KnightPlayerDef.textureSize,
        ),
      );

  static final SimpleDirectionAnimation animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_idle_left_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        idleRight: loadAnimationIdleRight,
        runLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_walking_left_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_walking_right_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionStandard,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');

  static GameDecoration createCryptComponent(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}
