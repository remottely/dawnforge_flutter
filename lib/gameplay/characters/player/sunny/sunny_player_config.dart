import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class SunnyPlayerConfig {
  SunnyPlayerConfig._();

  static const double kVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;

  static const double kLife = CharacterConstants.kLifeExtraLarge;
  static double kSpeed = CharacterConstants.kSpeedFast;
  static const double kRunSpeedMultiplier = 1.6;

  static const double kMaxStamina = 100.0;
  static const int kMaxEnergy = 100;

  static const int kToolActionEnergyCost = 2;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double kPrimaryAttackDamage = 25.0;
  static const int kPrimaryAttackStaminaCost = 15;

  static const double kFireballAttackDamage = 10.0;
  static const int kFireballAttackStaminaCost = 10;

  static final Vector2 textureSize = TileConstants.tileSizeSunnyWorld;
  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox hitbox = HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 44.0,
    hitboxStartPositionY: 28.0,
  );

  static Future<SpriteAnimation>
  get _rightWalkAnimation => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation> get rightRunAnimation => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  get rightAttackAnimation => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_strip10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static SimpleDirectionAnimation get animation => SimpleDirectionAnimation(
    idleLeft: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
    idleRight: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
    runLeft: _rightWalkAnimation,
    runRight: _rightWalkAnimation,
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionStandard,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 cryptComponentSize = TileConstants.tileSizeStandard;
  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');
  static DDDecoration createCryptComponent(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );

  static const String defaultPickaxeSpritePath =
      'gameplay/characters/weapons/SolarPoweredHammer.png';

  static const String staffSpritePath = 'JellySquish Weapons Pack/staff.png';

  static const String archedSwordSpritePath =
      'JellySquish Weapons Pack/arched_sword.png';

  static const String swordSpritePath = 'JellySquish Weapons Pack/sword.png';

  static const String steelShield1SpritePath =
      'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/7_Shield/WoodShield4.png';
  // 'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/7_Shield/SteelShield1.png';

  static const String sword3SpritePath =
      'SPUM/Resources/Addons/Legacy/0_Unit/0_Sprite/6_Weapons/0_Sword/Sword_3.png';

  static const String axeNormal1SpritePath =
      'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/2_Axe/AxeNormal1.png';
  static const String newWeapon07SpritePath =
      'SPUM/Resources/Addons/Ver300/0_Unit/0_Sprite/8_Weapons/8_Mace/New_Weapon_07.png';
}
