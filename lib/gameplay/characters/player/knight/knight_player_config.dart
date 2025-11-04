import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class KnightPlayerConfig {
  KnightPlayerConfig._();

  static const double kVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;

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

  static final Vector2 textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_idle_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_right_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: GameplayTileConstants.kTileDimensionStandard,
    blurBorder: GameplayTileConstants.kTileDimensionStandard,
    color: CharacterFxParticlesAnimationsConfig.lightingConfigColor,
  );

  static final Vector2 cryptComponentSize =
      GameplayTileConstants.tileSizeStandard;
  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');
  static DDDecoration createCryptComponent(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}
