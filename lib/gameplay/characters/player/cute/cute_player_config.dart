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

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 20.0,
    top: 22.0,
    right: 20.0,
    bottom: 18.0,
  );

  static Future<SpriteAnimation> _loadAnimationIdleLeft() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_left_48x48_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> _loadAnimationIdleUp() => SpriteAnimation.load(
    'new/Player/idle/player_idle_up_48x48_6.png',
    SpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: CutePlayerConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> _loadAnimationIdleDown() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_down_48x48_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationAttackRight =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_right_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationAttackLeft =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_left_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationAttackUp =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_up_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationAttackDown =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_down_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationShovelRight =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_right_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationShovelLeft =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_left_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationShovelUp =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_up_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationShovelDown =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_down_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationWateringCanRight =
      SpriteAnimation.load(
        'new/Player/water/player_water_right_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationWateringCanLeft =
      SpriteAnimation.load(
        'new/Player/water/player_water_left_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationWateringCanUp =
      SpriteAnimation.load(
        'new/Player/water/player_water_up_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> loadAnimationWateringCanDown =
      SpriteAnimation.load(
        'new/Player/water/player_water_down_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation>
  loadAnimationPlaceSeedRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  loadAnimationPlaceSeedLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> loadAnimationPlaceSeedUp =
      // TODO(Kevin): create dedicated up animation
      loadAnimationPlaceSeedRight;

  static final Future<SpriteAnimation> loadAnimationPlaceSeedDown =
      // TODO(Kevin): create dedicated down animation
      loadAnimationPlaceSeedLeft;

  static final Future<SpriteAnimation>
  loadAnimationHarvestBasketRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  loadAnimationHarvestBasketLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> loadAnimationHarvestBasketUp =
      // TODO(Kevin): create dedicated up animation
      loadAnimationHarvestBasketRight;

  static final Future<SpriteAnimation> loadAnimationHarvestBasketDown =
      // TODO(Kevin): create dedicated down animation
      loadAnimationHarvestBasketLeft;

  static final SimpleDirectionAnimation animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft(),
        idleRight: UISpriteAnimationsConfig.loadAnimationCutePlayerIdleRight(),
        idleUp: _loadAnimationIdleUp(),
        idleDown: _loadAnimationIdleDown(),
        runLeft: SpriteAnimation.load(
          'new/Player/walk/player_walk_left_48x48_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'new/Player/walk/player_walk_right_48x48_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runUp: SpriteAnimation.load(
          'new/Player/walk/player_walk_up_48x48_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runDown: SpriteAnimation.load(
          'new/Player/walk/player_walk_down_48x48_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );

  static final SimpleDirectionAnimation
  animationRunDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft(),
    idleRight: UISpriteAnimationsConfig.loadAnimationCutePlayerIdleRight(),
    idleUp: _loadAnimationIdleUp(),
    idleDown: _loadAnimationIdleDown(),
    // TODO(Kevin): NOW - create run animations
    runLeft: SpriteAnimation.load(
      'new/Player/walk/player_walk_left_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'new/Player/walk/player_walk_right_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runUp: SpriteAnimation.load(
      'new/Player/walk/player_walk_up_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runDown: SpriteAnimation.load(
      'new/Player/walk/player_walk_down_48x48_6.png', // TODO(Kevin): change to run animation
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

  static Future<Sprite> loadSpriteCrypt() => Sprite.load(
    'gameplay/characters/player/player_crypt_1.png',
  ); // TODO(Kevin): add cute death animation playonce // - new/Player/death/

  static DDDecoration createDeathMarker(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}

    // - new/Player/axe/
    // - new/Player/pickaxe/
