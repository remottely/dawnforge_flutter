import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_stage_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart'
    as model;
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_state_model.dart';
import 'package:darkness_dungeon/shared/framework/interaction/dd_tool_interactable_mixin.dart';

class FarmTileView extends GameDecoration with DDToolInteractableMixin {
  final int tileX;
  final int tileY;

  late FarmTileModel farmTile;

  SpriteComponent? _soilSprite;
  GameDecoration? _cropDecoration;
  bool _isHighlighted = false;

  SoilStateModel? _lastRenderedSoilState;
  String? _lastRenderedCropKey;

  FarmTileView({required Vector2 position})
    : tileX = (position.x / 16).floor(),
      tileY = (position.y / 16).floor(),
      super(position: position, size: TileConstants.tileSizeStandard) {
    final existingTile = FarmManager.instance.getTile(tileX, tileY);
    if (existingTile == null) {
      final newTile = model.FarmTileModel(x: tileX, y: tileY);
      FarmManager.instance.setTile(newTile);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    developer.log('[FarmTileView] Loading tile at ($tileX, $tileY)');

    farmTile = FarmManager.instance.getTile(tileX, tileY)!;

    final soilSprite = await Sprite.load(_getSoilSpritePath());
    _soilSprite = SpriteComponent(
      sprite: soilSprite,
      size: size,
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: 0,
    );
    add(_soilSprite!);

    developer.log(
      '[FarmTileView] 🟤 Soil sprite loaded: ${_getSoilSpritePath()}',
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

    _cropDecoration = GameDecoration.withSprite(
      sprite: cropSprite,
      position: position,
      size: size,
    );

    if (farmTile.crop!.stage == CropStageModel.withered) {
      _cropDecoration!.opacity = 0.5;
    }

    gameRef.add(_cropDecoration!);
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

    final currentTile = FarmManager.instance.getTile(tileX, tileY);
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
    final spritePath = _getSoilSpritePath();
    final sprite = await Sprite.load(spritePath);
    _soilSprite!.sprite = sprite;

    developer.log('[FarmTileView] 🟤 Soil sprite updated: $spritePath');
  }

  Future<void> _updateCropDecoration() async {
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }

    if (farmTile.crop == null) {
      developer.log('[FarmTileView] 🌱 Crop removed (no Y-sorting)');
      return;
    }

    await _createCropDecoration();

    developer.log(
      '[FarmTileView] 🌱 Crop decoration updated: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name}) with Y-sorting',
    );
  }

  String _getSoilSpritePath() {
    switch (farmTile.soilState) {
      case SoilStateModel.untilled:
        return 'gameplay/farm/soil/untilled.png';
      case SoilStateModel.tilled:
        return 'gameplay/farm/soil/tilled.png';
      case SoilStateModel.watered:
        return 'gameplay/farm/soil/watered.png';
      case SoilStateModel.fertilized:
        return 'gameplay/farm/soil/fertilized.png';
    }
  }

  Future<Sprite> _loadCropSpriteFromSheet() async {
    final crop = farmTile.crop!;
    final spritesheetPath = crop.iconPath;
    final frameIndex = _getFrameIndexForStage(crop.stage);

    final srcPosition = Vector2(
      TileConstants.kTileDimensionStandard * frameIndex,
      0,
    );

    final sprite = await Sprite.load(
      spritesheetPath,
      srcPosition: srcPosition,
      srcSize: TileConstants.tileSizeStandard,
    );

    developer.log(
      '[FarmTileView] 🌱 Crop sprite loaded from sheet: $spritesheetPath (frame: $frameIndex)',
    );

    return sprite;
  }

  int _getFrameIndexForStage(CropStageModel stage) {
    switch (stage) {
      case CropStageModel.seed:
        return 0;
      case CropStageModel.sprout:
        return 1;
      case CropStageModel.youngPlant:
        return 2;
      case CropStageModel.growing1:
        return 3;
      case CropStageModel.growing2:
        return 4;
      case CropStageModel.growing3:
        return 5;
      case CropStageModel.mature:
        return 6;
      case CropStageModel.withered:
        return 7;
    }
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

  Future<void> updateTile(FarmTileModel newTile) async {
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

    final success = FarmManager.instance.tillSoil(farmTile.x, farmTile.y);
    if (success) {
      final updated = FarmManager.instance.getTile(farmTile.x, farmTile.y);
      if (updated != null) {
        updateTile(updated);
      }
    }
  }

  @override
  void onRemove() {
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }
    super.onRemove();
  }

  @override
  int get priority => 20;
}
