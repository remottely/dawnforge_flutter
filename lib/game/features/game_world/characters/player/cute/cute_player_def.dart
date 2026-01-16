import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/lightning_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';

final class CutePlayerDef {
  CutePlayerDef._();

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double _kRunSpeedMultiplier = 1.4;

  static const int _kPrimaryAttackStaminaCost = 1;
  static const int _kFireballAttackStaminaCost = 2;
  static const double _kPrimaryAttackDamage = 25.0;
  static const double _kFireballAttackDamage = 10.0;

  static const int _kDigStaminaCost = 5;
  static const int _kWateringCanStaminaCost = 5;
  static const int _kSeedStaminaCost = 5;
  static const int _kHarvestStaminaCost = 5;

  static const DDFarmPlayerModelConfig modelConfig = DDFarmPlayerModelConfig(
    maxStamina: _kMaxStamina,
    maxEnergy: _kMaxEnergy,
    staminaRegenIncrement: _kStaminaIncrement,
    longVisionRadius: _kLongVisionRadius,
    staminaRegenDebounce: _kStaminaRegenDebounce,
    runSpeedMultiplier: _kRunSpeedMultiplier,
    primaryAttackStaminaCost: _kPrimaryAttackStaminaCost,
    rangedAttackStaminaCost: _kFireballAttackStaminaCost,
    primaryAttackDamage: _kPrimaryAttackDamage,
    rangedAttackDamage: _kFireballAttackDamage,
    digStaminaCost: _kDigStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
  );

  static const double _kLife = CharacterConstants.kLifeExtraLarge;
  static double _kBaseSpeed = CharacterConstants.kSpeedFast;

  static final Vector2 textureSize = TileConstants.tileSizeCute;
  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 20,
    top: 22,
    right: 20,
    bottom: 16,
  );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimation.load(
        'new/Player/idle/player_idle_left_48x48_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp = SpriteAnimation.load(
    'new/Player/idle/player_idle_up_48x48_6.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 6,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationIdleDown =
      SpriteAnimation.load(
        'new/Player/idle/player_idle_down_48x48_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackRight =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_right_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_left_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_up_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_down_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final DDAnimationDirectionalFactory
  _animationAttackDirectionalFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationAttackRight,
    loadLeft: _loadAnimationAttackLeft,
    loadUp: _loadAnimationAttackUp,
    loadDown: _loadAnimationAttackDown,
  );

  static final Future<SpriteAnimation> _loadAnimationDigRight =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_right_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_left_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_up_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_down_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final DDAnimationDirectionalFactory _animationDigDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationDigRight,
        loadLeft: _loadAnimationDigLeft,
        loadUp: _loadAnimationDigUp,
        loadDown: _loadAnimationDigDown,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanRight =
      SpriteAnimation.load(
        'new/Player/water/player_water_right_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanLeft =
      SpriteAnimation.load(
        'new/Player/water/player_water_left_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanUp =
      SpriteAnimation.load(
        'new/Player/water/player_water_up_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanDown =
      SpriteAnimation.load(
        'new/Player/water/player_water_down_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final DDAnimationDirectionalFactory _animationWateringCanFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationWateringCanRight,
        loadLeft: _loadAnimationWateringCanLeft,
        loadUp: _loadAnimationWateringCanUp,
        loadDown: _loadAnimationWateringCanDown,
      );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
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

  static final DDAnimationDirectionalFactory _animationPlaceSeedFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationPlaceSeedRight,
        loadLeft: _loadAnimationPlaceSeedLeft,
        loadUp: _loadAnimationPlaceSeedUp,
        loadDown: _loadAnimationPlaceSeedDown,
      );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      // TODO(Kevin): create dedicated up animation
      _loadAnimationHarvestRight;

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      // TODO(Kevin): create dedicated down animation
      _loadAnimationHarvestLeft;

  static final DDAnimationDirectionalFactory _animationHarvestFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestRight,
        loadLeft: _loadAnimationHarvestLeft,
        loadUp: _loadAnimationHarvestUp,
        loadDown: _loadAnimationHarvestDown,
      );

  static final Future<SpriteAnimation> loadAnimationIdleRight =
      SpriteAnimation.load(
        'new/Player/idle/player_idle_right_48x48_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: textureSize,
        ),
      );

  static final SimpleDirectionAnimation _animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: _loadAnimationIdleDown,
        runLeft: SpriteAnimation.load(
          'new/Player/walk/player_walk_left_48x48_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'new/Player/walk/player_walk_right_48x48_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runUp: SpriteAnimation.load(
          'new/Player/walk/player_walk_up_48x48_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runDown: SpriteAnimation.load(
          'new/Player/walk/player_walk_down_48x48_6.png',
          SpriteAnimationConfigHelper.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );

  static final SimpleDirectionAnimation
  _animationRunDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft,
    idleRight: loadAnimationIdleRight,
    idleUp: _loadAnimationIdleUp,
    idleDown: _loadAnimationIdleDown,
    // TODO(Kevin): NOW - create run animations
    runLeft: SpriteAnimation.load(
      'new/Player/walk/player_walk_left_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfigHelper.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'new/Player/walk/player_walk_right_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfigHelper.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runUp: SpriteAnimation.load(
      'new/Player/walk/player_walk_up_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfigHelper.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runDown: SpriteAnimation.load(
      'new/Player/walk/player_walk_down_48x48_6.png', // TODO(Kevin): change to run animation
      SpriteAnimationConfigHelper.createStandardData(
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

  static GameDecoration _createDeathMarker(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: _loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  static final DDFarmPlayerViewConfig viewConfig = DDFarmPlayerViewConfig(
    size: componentSize,
    life: _kLife,
    baseSpeed: _kBaseSpeed,
    hitbox: _hitbox,
    lighting: _lighting,
    getDeathMarker: _createDeathMarker,
    animationWalkDirectional: _animationWalkDirectional,
    animationRunDirectional: _animationRunDirectional,
    animationAttackDirectionalFactory: _animationAttackDirectionalFactory,
    animationDigFactory: _animationDigDirectionalFactory,
    animationWateringCanFactory: _animationWateringCanFactory,
    animationPlaceSeedFactory: _animationPlaceSeedFactory,
    animationHarvestFactory: _animationHarvestFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
