import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class SunnyPlayerConfig {
  SunnyPlayerConfig._();

  static const double kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;

  static const double kLife = CharacterConstants.kLifeExtraLarge;

  static double kSpeed = CharacterConstants.kSpeedFast;

  static const double kRunSpeedMultiplier = 1.4;

  static const double kMaxStamina = 100.0;

  static const int kStaminaIncrement = 1;

  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const int kMaxEnergy = 100;

  static const int kToolActionEnergyCost = 2;

  static const double kPrimaryAttackDamage = 25.0;

  static const int kPrimaryAttackStaminaCost = 15;

  static const double kFireballAttackDamage = 10.0;

  static const int kFireballAttackStaminaCost = 10;

  static const int kShovelStaminaCost = 5;

  static const int kWateringCanStaminaCost = 5;

  static const int kSeedStaminaCost = 5;

  static const int kHarvestBasketStaminaCost = 5;

  static final Vector2 textureSize = TileConstants.tileSizeSunny;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 44.0,
    top: 28.0,
    right: 44.0,
    bottom: 25.0,
  );

  static Future<SpriteAnimation>
  _loadAnimationIdleLeft() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_left_strip9.png',
    SpriteAnimationConfig.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationAttackRight() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_strip10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationAttackLeft() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_left_strip10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationShovelRight() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_strip13.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationShovelLeft() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_left_strip13.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationWateringCanRight() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_strip5.png',
    SpriteAnimationConfig.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadAnimationWateringCanLeft() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_left_strip5.png',
    SpriteAnimationConfig.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightSeedAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftSeedAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightHarvestBasketAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftHarvestBasketAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final SimpleDirectionAnimation
  animationWalkDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft(),
    idleRight: UISpriteAnimationsConfig.loadAnimationSunnyPlayerIdleRight(),
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_left_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
  );

  static final SimpleDirectionAnimation
  animationRunDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft(),
    idleRight: UISpriteAnimationsConfig.loadAnimationSunnyPlayerIdleRight(),
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_left_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');

  static DDDecoration createDeathMarker(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}
