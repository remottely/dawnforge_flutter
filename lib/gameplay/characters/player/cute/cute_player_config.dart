import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
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

  static const int _kShovelStaminaCost = 5;
  static const int _kWateringCanStaminaCost = 5;
  static const int _kSeedStaminaCost = 5;
  static const int _kHarvestBasketStaminaCost = 5;

  static const modelConfig = DDFarmPlayerModelConfig(
    shovelStaminaCost: _kShovelStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestBasketStaminaCost: _kHarvestBasketStaminaCost,
  );

  static final Vector2 textureSize = TileConstants.tileSizeCute;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
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

  static final Future<SpriteAnimation> _loadAnimationAttackRight =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_right_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_left_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_up_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_down_48x48_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final _animationAttackDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttackRight,
        loadLeft: _loadAnimationAttackLeft,
        loadUp: _loadAnimationAttackUp,
        loadDown: _loadAnimationAttackDown,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final Future<SpriteAnimation> _loadAnimationShovelRight =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_right_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelLeft =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_left_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelUp =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_up_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelDown =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_down_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final _animationShovelFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationShovelRight,
    loadLeft: _loadAnimationShovelLeft,
    loadUp: _loadAnimationShovelUp,
    loadDown: _loadAnimationShovelDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation> _loadAnimationWateringCanRight =
      SpriteAnimation.load(
        'new/Player/water/player_water_right_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanLeft =
      SpriteAnimation.load(
        'new/Player/water/player_water_left_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanUp =
      SpriteAnimation.load(
        'new/Player/water/player_water_up_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanDown =
      SpriteAnimation.load(
        'new/Player/water/player_water_down_48x48_2.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConfig.kStepTimeSlow,
        ),
      );

  static final _animationWateringCanFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationWateringCanRight,
    loadLeft: _loadAnimationWateringCanLeft,
    loadUp: _loadAnimationWateringCanUp,
    loadDown: _loadAnimationWateringCanDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      // TODO(Kevin): create dedicated up animation
      _loadAnimationPlaceSeedRight;

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      // TODO(Kevin): create dedicated down animation
      _loadAnimationPlaceSeedLeft;

  static final _animationPlaceSeedFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationPlaceSeedRight,
    loadLeft: _loadAnimationPlaceSeedLeft,
    loadUp: _loadAnimationPlaceSeedUp,
    loadDown: _loadAnimationPlaceSeedDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestBasketRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestBasketLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationHarvestBasketUp =
      // TODO(Kevin): create dedicated up animation
      _loadAnimationHarvestBasketRight;

  static final Future<SpriteAnimation> _loadAnimationHarvestBasketDown =
      // TODO(Kevin): create dedicated down animation
      _loadAnimationHarvestBasketLeft;

  static final _animationHarvestBasketFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationHarvestBasketRight,
    loadLeft: _loadAnimationHarvestBasketLeft,
    loadUp: _loadAnimationHarvestBasketUp,
    loadDown: _loadAnimationHarvestBasketDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final SimpleDirectionAnimation _animationWalkDirectional =
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
  _animationRunDirectional = SimpleDirectionAnimation(
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

  static final LightingConfig _lighting = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 _cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> _loadSpriteCrypt() => Sprite.load(
    'gameplay/characters/player/player_crypt_1.png',
  ); // TODO(Kevin): add cute death animation playonce // - new/Player/death/

  static DDDecoration _createDeathMarker(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: _loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  static final viewConfig = DDFarmPlayerViewConfig(
    hitbox: CutePlayerConfig._hitbox,
    lighting: CutePlayerConfig._lighting,
    getDeathMarker: (position) => CutePlayerConfig._createDeathMarker(position),
    animationWalkDirectional: CutePlayerConfig._animationWalkDirectional,
    animationRunDirectional: CutePlayerConfig._animationRunDirectional,
    animationAttackDirectionalFactory:
        CutePlayerConfig._animationAttackDirectionalFactory,
    animationShovelFactory: CutePlayerConfig._animationShovelFactory,
    animationWateringCanFactory: CutePlayerConfig._animationWateringCanFactory,
    animationPlaceSeedFactory: CutePlayerConfig._animationPlaceSeedFactory,
    animationHarvestBasketFactory:
        CutePlayerConfig._animationHarvestBasketFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
