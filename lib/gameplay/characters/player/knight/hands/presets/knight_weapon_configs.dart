import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

/// Configuração visual centralizada de equipamentos
///
/// Este arquivo é a ÚNICA fonte de verdade para configurações visuais
/// de equipamentos do Knight Player.
class KnightWeaponVisualConfig {
  final bool useAnimation;

  // Campos para modo SPRITE (legado)
  final String? spritePath;

  // Campos para modo ANIMATION
  final String? idlePath;
  final int? idleFrameCount;
  final Duration? idleFrameDuration;
  final String? attackPath;
  final int? attackFrameCount;
  final int? attackFrameIndex;
  final Duration? attackDuration;

  // Campos comuns
  final Vector2 textureSize;
  final Vector2 size;
  final Vector2 attachmentOffset;
  final Vector2 directionalOffset;
  final Vector2 mirroredDirectionalOffset;

  const KnightWeaponVisualConfig({
    required this.useAnimation,
    this.spritePath,
    this.idlePath,
    this.idleFrameCount,
    this.idleFrameDuration,
    this.attackPath,
    this.attackFrameCount,
    this.attackFrameIndex,
    this.attackDuration,
    required this.textureSize,
    required this.size,
    required this.attachmentOffset,
    required this.directionalOffset,
    required this.mirroredDirectionalOffset,
  }) : assert(
         useAnimation == false && spritePath != null ||
             useAnimation == true && idlePath != null && attackPath != null,
         'Must provide spritePath for sprite mode or idlePath/attackPath for animation mode',
       );

  /// Configuração para SPRITE mode
  const KnightWeaponVisualConfig.sprite({
    required this.spritePath,
    required this.textureSize,
    required this.size,
    required this.attachmentOffset,
    required this.directionalOffset,
    required this.mirroredDirectionalOffset,
  }) : useAnimation = false,
       idlePath = null,
       idleFrameCount = null,
       idleFrameDuration = null,
       attackPath = null,
       attackFrameCount = null,
       attackFrameIndex = null,
       attackDuration = null;

  /// Configuração para ANIMATION mode
  const KnightWeaponVisualConfig.animation({
    required this.idlePath,
    required this.idleFrameCount,
    this.idleFrameDuration = const Duration(milliseconds: 1000),
    required this.attackPath,
    required this.attackFrameCount,
    required this.attackFrameIndex,
    required this.attackDuration,
    required this.textureSize,
    required this.size,
    required this.attachmentOffset,
    required this.directionalOffset,
    required this.mirroredDirectionalOffset,
  }) : useAnimation = true,
       spritePath = null;
}

/// Configurações centralizadas de armas (Right Hand)
final class KnightWeaponConfigs {
  KnightWeaponConfigs._();

  /// Sword configuration (ANIMATION mode)
  static final sword = KnightWeaponVisualConfig.animation(
    idlePath:
        'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/ATTACK/tools_attack_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/AXE/tools_axe_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/CAUGHT/tools_caught_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/DIG/tools_dig_strip13.png',
    idleFrameCount: 1,
    idleFrameDuration: Duration(milliseconds: 1000),
    attackPath:
        'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/ATTACK/tools_attack_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/AXE/tools_axe_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/CAUGHT/tools_caught_strip10.png',
    // 'SunnysideWorld/Sprites/SUNNYSIDE_WORLD_CHARACTERS_PARTS_V0.3.1/DIG/tools_dig_strip13.png',
    attackFrameCount: 10,
    attackFrameIndex: 6,
    attackDuration: Duration(milliseconds: 400),
    textureSize: Vector2(96, 64),
    size: Vector2(96, 64),
    attachmentOffset: Vector2(0, 0),
    directionalOffset: Vector2(0, 0),
    mirroredDirectionalOffset: Vector2(0, 0),
  );

  /// Axe configuration (SPRITE mode)
  static final axe = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.axeNormal1SpritePath,
    textureSize: Vector2(16, 22) * 0.4,
    size: Vector2(16, 22) * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(-5, 0),
    mirroredDirectionalOffset: Vector2(-1, 0),
  );

  /// Mace configuration (SPRITE mode)
  static final mace = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.sword3SpritePath,
    textureSize: TileConstants.tileSizeStandard,
    size: TileConstants.tileSizeStandard,
    attachmentOffset: Vector2(8, 16),
    directionalOffset: Vector2(-5, 0),
    mirroredDirectionalOffset: Vector2(-1, 0),
  );

  /// Default weapon fallback (SPRITE mode)
  static final defaultWeapon = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.sword3SpritePath,
    textureSize: Vector2(7, 22) * 0.4,
    size: Vector2(7, 22) * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(-5, 0),
    mirroredDirectionalOffset: Vector2(-1, 0),
  );
}

/// Configurações centralizadas de offhand (Left Hand)
final class KnightOffhandConfigs {
  KnightOffhandConfigs._();

  /// Staff configuration
  static final staff = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.staffSpritePath,
    textureSize: TileConstants.tileSizeStandard / 2,
    size: TileConstants.tileSizeStandard / 2,
    attachmentOffset: Vector2(0, 6),
    directionalOffset: Vector2(5, 0),
    mirroredDirectionalOffset: Vector2(0, 0),
  );

  /// Wand configuration
  static final wand = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.staffSpritePath,
    textureSize: TileConstants.tileSizeStandard / 2,
    size: TileConstants.tileSizeStandard / 2,
    attachmentOffset: Vector2(0, 6),
    directionalOffset: Vector2(5, 0),
    mirroredDirectionalOffset: Vector2(0, 0),
  );

  /// Shield configuration
  static final shield = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.woodShield4SpritePath,
    textureSize: TileConstants.tileSizeStandard * 0.4,
    size: TileConstants.tileSizeStandard * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(3, 1),
    mirroredDirectionalOffset: Vector2(2, 1),
  );

  /// Default offhand fallback
  static final defaultOffhand = KnightWeaponVisualConfig.sprite(
    spritePath: KnightPlayerConfig.woodShield4SpritePath,
    textureSize: TileConstants.tileSizeStandard * 0.4,
    size: TileConstants.tileSizeStandard * 0.4,
    attachmentOffset: Vector2(0, 5),
    directionalOffset: Vector2(3, 1),
    mirroredDirectionalOffset: Vector2(2, 1),
  );
}
