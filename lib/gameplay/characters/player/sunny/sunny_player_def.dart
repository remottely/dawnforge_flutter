import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class SunnyPlayerDef {
  SunnyPlayerDef._();

  static const double kLife = CharacterConstants.kLifeExtraLarge;

  static double kSpeed = CharacterConstants.kSpeedFast;

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double _kRunSpeedMultiplier = 1.4;

  static const int _kPrimaryAttackStaminaCost = 15;
  static const int _kFireballAttackStaminaCost = 10;
  static const double _kPrimaryAttackDamage = 25.0;
  static const double _kFireballAttackDamage = 10.0;

  static const int _kShovelStaminaCost = 5;
  static const int _kWateringCanStaminaCost = 5;
  static const int _kSeedStaminaCost = 5;
  static const int _kHarvestStaminaCost = 5;

  static const modelConfig = DDFarmPlayerModelConfig(
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
    shovelStaminaCost: _kShovelStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
  );

  static final Vector2 textureSize = TileConstants.tileSizeSunny;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 44.0,
    top: 28.0,
    right: 44.0,
    bottom: 25.0,
  );

  static Future<SpriteAnimation>
  _loadAnimationIdleLeft() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_left_strip9.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerDef.textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationAttackRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_strip10.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationAttackLeft = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_left_strip10.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static final _animationAttackDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttackRight,
        loadLeft: _loadAnimationAttackLeft,
        loadUp: null,
        loadDown: null,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final Future<SpriteAnimation>
  _loadAnimationShovelRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_strip13.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationShovelLeft = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_left_strip13.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static final _animationShovelFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationShovelRight,
    loadLeft: _loadAnimationShovelLeft,
    loadUp: null,
    loadDown: null,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  _loadAnimationWateringCanRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_strip5.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationWateringCanLeft = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_left_strip5.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static final _animationWateringCanFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationWateringCanRight,
    loadLeft: _loadAnimationWateringCanLeft,
    loadUp: null,
    loadDown: null,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedLeft = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final _animationPlaceSeedFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationPlaceSeedRight,
    loadLeft: _loadAnimationPlaceSeedLeft,
    loadUp: null,
    loadDown: null,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestLeft = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final _animationHarvestFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationHarvestRight,
    loadLeft: _loadAnimationHarvestLeft,
    loadUp: null,
    loadDown: null,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation>
  loadAnimationIdleRight = SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_strip9.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerDef.textureSize,
    ),
  );

  static final SimpleDirectionAnimation
  _animationWalkDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft(),
    idleRight: loadAnimationIdleRight,
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_left_strip8.png',
      SpriteAnimationConfigHelper.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_strip8.png',
      SpriteAnimationConfigHelper.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
  );

  static final SimpleDirectionAnimation
  _animationRunDirectional = SimpleDirectionAnimation(
    idleLeft: _loadAnimationIdleLeft(),
    idleRight: loadAnimationIdleRight,
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_left_strip8.png',
      SpriteAnimationConfigHelper.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_strip8.png',
      SpriteAnimationConfigHelper.createStandardData(
        amount: 8,
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

  static Future<Sprite> _loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');

  static GameDecoration _createDeathMarker(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: _loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  static final viewConfig = DDFarmPlayerViewConfig(
    hitbox: SunnyPlayerDef._hitbox,
    lighting: SunnyPlayerDef._lighting,
    getDeathMarker: (position) => SunnyPlayerDef._createDeathMarker(position),
    animationWalkDirectional: SunnyPlayerDef._animationWalkDirectional,
    animationRunDirectional: SunnyPlayerDef._animationRunDirectional,
    animationAttackDirectionalFactory:
        SunnyPlayerDef._animationAttackDirectionalFactory,
    animationShovelFactory: SunnyPlayerDef._animationShovelFactory,
    animationWateringCanFactory: SunnyPlayerDef._animationWateringCanFactory,
    animationPlaceSeedFactory: SunnyPlayerDef._animationPlaceSeedFactory,
    animationHarvestFactory: SunnyPlayerDef._animationHarvestFactory,
  );
}
