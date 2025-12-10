import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class CutePlayerConfig {
  CutePlayerConfig._();

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

  static final Vector2 textureSize = TileConstants.tileSizeCute;
  static final Vector2 textureSizeActions = TileConstants.tileSizeCuteActions;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 44.0,
    top: 28.0,
    right: 44.0,
    bottom: 25.0,
  );

  static Future<SpriteAnimation> _loadCutePlayerIdleLeft6() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_west_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> _loadCutePlayerIdleUp6() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_north_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> _loadCutePlayerIdleDown6() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_south_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadRightAttackAnimation() =>
      SpriteAnimation.load(
        'new/Player/attack/player_attack_east_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadLeftAttackAnimation() =>
      SpriteAnimation.load(
        'new/Player/attack/player_attack_west_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadUpAttackAnimation() =>
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_north_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadDownAttackAnimation() =>
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_south_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadRightShovelAnimation() =>
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_east_2.dart',
        SpriteAnimationConfig.createStandardData(
          amount: 2,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadLeftShovelAnimation() =>
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_west_2.dart',
        SpriteAnimationConfig.createStandardData(
          amount: 2,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadRightWateringCanAnimation() =>
      SpriteAnimation.load(
        'new/Player/water/player_water_east_2.dart',
        SpriteAnimationConfig.createStandardData(
          amount: 5,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation> loadLeftWateringCanAnimation() =>
      SpriteAnimation.load(
        'new/Player/water/player_water_west_2.dart',
        SpriteAnimationConfig.createStandardData(
          amount: 5,
          textureSize: textureSize,
        ),
      );

  static Future<SpriteAnimation>
  loadRightSeedAnimation() => SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftSeedAnimation() => SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightHarvestBasketAnimation() => SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftHarvestBasketAnimation() => SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final SimpleDirectionAnimation walkAnimation =
      SimpleDirectionAnimation(
        idleLeft: _loadCutePlayerIdleLeft6(),
        idleRight: UISpriteAnimationsConfig.loadCutePlayerIdleRight6(),
        idleUp: _loadCutePlayerIdleUp6(),
        idleDown: _loadCutePlayerIdleDown6(),
        runLeft: SpriteAnimation.load(
          'new/Player/walk/player_walk_west_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'new/Player/walk/player_walk_east_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runUp: SpriteAnimation.load(
          'new/Player/walk/player_walk_north_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runDown: SpriteAnimation.load(
          'new/Player/walk/player_walk_south_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );

  static final SimpleDirectionAnimation runAnimation = SimpleDirectionAnimation(
    idleLeft: _loadCutePlayerIdleLeft6(),
    idleRight: UISpriteAnimationsConfig.loadCutePlayerIdleRight6(),
    idleUp: _loadCutePlayerIdleUp6(),
    idleDown: _loadCutePlayerIdleDown6(),
    // TODO(Kevin): NOW - create run animations
    runLeft: SpriteAnimation.load(
      'new/Player/walk/player_walk_west_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'new/Player/walk/player_walk_east_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runUp: SpriteAnimation.load(
      'new/Player/walk/player_walk_north_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runDown: SpriteAnimation.load(
      'new/Player/walk/player_walk_south_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
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

    // -
    // - new/Player/axe/
    // - new/Player/death/
    // - new/Player/idle/
    // - new/Player/pickaxe/
    // - new/Player/shovel/
    // - new/Player/walk/
    // - new/Player/water/
