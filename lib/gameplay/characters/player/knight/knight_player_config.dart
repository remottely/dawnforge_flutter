import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class KnightPlayerConfig {
  KnightPlayerConfig._();

  static const double kVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;

  static const double kLife = CharacterConstants.kLifeExtraLarge;
  static double kSpeed = CharacterConstants.kSpeedFast;

  static const double kMaxStamina = 100.0;
  static const int kMaxEnergy = 100;

  static const int kToolActionEnergyCost = 2;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double kPrimaryAttackDamage = 25.0;
  static const int kPrimaryAttackStaminaCost = 15;

  static const double kFireballAttackDamage = 10.0;
  static const int kFireballAttackStaminaCost = 10;

  static final RectangleHitbox hitbox = HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 8.0,
  );

  static final Vector2 textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_idle_left_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_left_6.png',
      SpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_right_6.png',
      SpriteAnimationConfig.createStandardData(
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
