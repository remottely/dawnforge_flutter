import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/farm/entities/crop_stage.dart';
import 'package:darkness_dungeon/gameplay/farm/entities/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/farm/entities/soil_state.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_service_locator.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_sprite_config.dart';
import 'package:darkness_dungeon/gameplay/farm/usecases/till_soil_use_case.dart';
import 'package:darkness_dungeon/shared/framework/interaction/dd_tool_interactable_mixin.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

class FarmTileView extends GameDecoration with DDToolInteractableMixin {
  static SoilSpriteConfig? _soilConfig;

  final int tileX;
  final int tileY;

  late FarmTile farmTile;

  SpriteComponent? _soilSprite;
  GameDecoration? _cropDecoration;
  SpriteComponent? _cropSpriteGround;
  bool _isHighlighted = false;

  SoilState? _lastRenderedSoilState;
  String? _lastRenderedCropKey;

  FarmTileView({required Vector2 position})
    : tileX = (position.x / 16).floor(),
      tileY = (position.y / 16).floor(),
      super(position: position, size: TileConstants.tileSizeStandard) {
    // Garante que o tile existe no manager
    final existingTile = FarmManager.instance.getTile(tileX, tileY);
    if (existingTile == null) {
      // Cria um novo tile vazio
      final newTile = FarmTile(x: tileX, y: tileY);
      FarmManager.instance.setTile(newTile);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    developer.log('[FarmTileView] Loading tile at ($tileX, $tileY)');

    // Carrega a configuração de sprites de solo apenas uma vez
    _soilConfig ??= await SoilSpriteConfig.load();

    farmTile = getIt<FarmManager>().getTile(tileX, tileY)!;

    final soilSprite = await _loadSoilSpriteFromSheet();
    _soilSprite = SpriteComponent(
      sprite: soilSprite,
      size: size,
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: 0,
    );
    add(_soilSprite!);

    developer.log(
      '[FarmTileView] 🟤 Soil sprite loaded from texture atlas: ${farmTile.soilState.name}',
    );

    if (farmTile.crop != null) {
      await _createCropDecoration();
      developer.log(
        '[FarmTileView] 🌱 Crop decoration loaded: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name}) with Y-sorting',
      );
    }

    _lastRenderedSoilState = farmTile.soilState;
    _lastRenderedCropKey = _getCropKey();
  }

  Future<void> _createCropDecoration() async {
    if (farmTile.crop == null) return;

    final cropSprite = await _loadCropSpriteFromSheet();
    final crop = farmTile.crop!;

    // Tamanho real do sprite do crop
    final cropSize = Vector2(
      crop.spriteWidth.toDouble(),
      crop.spriteHeight.toDouble(),
    );

    if (crop.shouldUseYSorting) {
      // Estágio avançado: usa Y-sorting (renderiza com profundidade 3D)
      final cropPosition = Vector2(
        position.x,
        position.y + size.y - cropSize.y,
      );

      _cropDecoration = GameDecoration.withSprite(
        sprite: cropSprite,
        position: cropPosition,
        size: cropSize,
      );

      if (crop.stage == CropStage.withered) {
        _cropDecoration!.opacity = 0.5;
      }

      gameRef.add(_cropDecoration!);

      developer.log(
        '[FarmTileView] 🌱 Crop with Y-sorting: ${crop.cropId} at ($cropPosition) with size ($cropSize)',
      );
    } else {
      // Estágio inicial: renderiza no chão (sempre abaixo do player)
      _cropSpriteGround = SpriteComponent(
        sprite: cropSprite,
        size: cropSize,
        anchor: Anchor.bottomLeft,
        position: Vector2(0, size.y),
        priority: 1,
      );

      if (crop.stage == CropStage.withered) {
        _cropSpriteGround!.opacity = 0.5;
      }

      add(_cropSpriteGround!);

      developer.log(
        '[FarmTileView] 🌱 Crop on ground: ${crop.cropId} with size ($cropSize), always below player',
      );
    }
  }

  bool isPlayerOnTile(Player player) {
    final bottomCenter = Offset(
      player.rectCollision.center.dx,
      player.rectCollision.bottom,
    );
    return rectCollision.contains(bottomCenter);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final currentTile = getIt<FarmManager>().getTile(tileX, tileY);
    if (currentTile != null) {
      if (currentTile.soilState != _lastRenderedSoilState ||
          currentTile.crop?.cropId != _lastRenderedCropKey) {}
      updateTile(currentTile);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isHighlighted) {
      _renderHighlight(canvas);
    }
  }

  Future<void> _updateSoilSprite() async {
    final sprite = await _loadSoilSpriteFromSheet();
    _soilSprite!.sprite = sprite;

    developer.log(
      '[FarmTileView] 🟤 Soil sprite updated: ${farmTile.soilState.name}',
    );
  }

  Future<void> _updateCropDecoration() async {
    // Remove decorações existentes
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }

    if (_cropSpriteGround != null) {
      _cropSpriteGround!.removeFromParent();
      _cropSpriteGround = null;
    }

    if (farmTile.crop == null) {
      developer.log('[FarmTileView] 🌱 Crop removed');
      return;
    }

    await _createCropDecoration();

    developer.log(
      '[FarmTileView] 🌱 Crop decoration updated: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name})',
    );
  }

  Future<Sprite> _loadSoilSpriteFromSheet() async {
    if (_soilConfig == null) {
      throw Exception('[FarmTileView] SoilSpriteConfig not loaded!');
    }

    final stateName = farmTile.soilState.name;
    final position = _soilConfig!.getPosition(stateName);

    if (position == null) {
      throw Exception(
        '[FarmTileView] Soil state "$stateName" not found in config!',
      );
    }

    final sprite = await SpriteAnimationConfigHelper.loadSpriteFromTextureAtlas(
      assetPath: _soilConfig!.spritesheetPath,
      spriteSize: Vector2(
        _soilConfig!.spriteWidth.toDouble(),
        _soilConfig!.spriteHeight.toDouble(),
      ),
      frameIndex: position.columnIndex,
      rowIndex: position.rowIndex,
      skipFirstFrames: 0,
    );

    developer.log(
      '[FarmTileView] 🟤 Soil sprite loaded from sheet: ${_soilConfig!.spritesheetPath} '
      '(row: ${position.rowIndex}, col: ${position.columnIndex}, state: $stateName, '
      'size: ${_soilConfig!.spriteWidth}x${_soilConfig!.spriteHeight})',
    );

    return sprite;
  }

  Future<Sprite> _loadCropSpriteFromSheet() async {
    final crop = farmTile.crop!;
    final frameIndex = _getFrameIndexForStage(crop.stage, crop.framesCount);

    final sprite = await SpriteAnimationConfigHelper.loadSpriteFromTextureAtlas(
      assetPath: crop.spritesheetPath,
      spriteSize: Vector2(
        crop.spriteWidth.toDouble(),
        crop.spriteHeight.toDouble(),
      ),
      frameIndex: frameIndex,
      rowIndex: crop.spriteRowIndex,
      skipFirstFrames: crop.skipFirstFrames,
    );

    developer.log(
      '[FarmTileView] 🌱 Crop sprite loaded from sheet: ${crop.spritesheetPath} '
      '(row: ${crop.spriteRowIndex}, stage: ${crop.stage.name}, frame: $frameIndex/${crop.framesCount}, '
      'skipFirstFrames: ${crop.skipFirstFrames}, size: ${crop.spriteWidth}x${crop.spriteHeight})',
    );

    return sprite;
  }

  /// Mapeia os 8 estágios de crescimento para o número de frames disponíveis
  ///
  /// Exemplo com 4 frames:
  /// - seed(0), sprout(1) → frame 0
  /// - youngPlant(2), growing1(3) → frame 1
  /// - growing2(4), growing3(5) → frame 2
  /// - mature(6), withered(7) → frame 3
  int _getFrameIndexForStage(CropStage stage, int availableFrames) {
    const totalStages = 8; // Total de estágios possíveis em CropStage
    final stageIndex = stage.index;

    // Mapeia proporcionalmente o índice do estágio para os frames disponíveis
    final frameIndex = (stageIndex * availableFrames) ~/ totalStages;

    // Garante que não ultrapassa o número de frames disponíveis
    return frameIndex.clamp(0, availableFrames - 1);
  }

  Future<void> _updateSpritesIfNeeded() async {
    final currentSoilState = farmTile.soilState;
    final currentCropKey = _getCropKey();

    if (currentSoilState != _lastRenderedSoilState) {
      await _updateSoilSprite();
      _lastRenderedSoilState = currentSoilState;
    }

    if (currentCropKey != _lastRenderedCropKey) {
      await _updateCropDecoration();
      _lastRenderedCropKey = currentCropKey;
    }
  }

  String? _getCropKey() {
    if (farmTile.crop == null) return null;
    return '${farmTile.crop!.cropId}_${farmTile.crop!.stage.name}';
  }

  void _renderHighlight(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x4400FF00)
      ..style = PaintingStyle.fill;
    canvas.drawRect(size.toRect(), paint);
  }

  Future<void> updateTile(FarmTile newTile) async {
    farmTile = newTile;
    await _updateSpritesIfNeeded();
  }

  void setHighlighted(bool highlighted) {
    _isHighlighted = highlighted;
  }

  @override
  void onToolUsed(
    ToolType tool,
    GameComponent user, {
    required Vector2 position,
  }) {
    if (tool != ToolType.shovel) return;

    // Usa o UseCase através do GetIt (nova arquitetura)
    final tillSoilUseCase = getIt<TillSoilUseCase>();
    final success = tillSoilUseCase.call(farmTile.x, farmTile.y);

    if (success) {
      final updated = getIt<FarmManager>().getTile(farmTile.x, farmTile.y);
      if (updated != null) updateTile(updated);
    }
  }

  @override
  void onRemove() {
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }
    if (_cropSpriteGround != null) {
      _cropSpriteGround!.removeFromParent();
      _cropSpriteGround = null;
    }
    super.onRemove();
  }

  @override
  int get priority => 20;
}
