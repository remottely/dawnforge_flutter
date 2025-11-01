import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/i_dd_game_decoration.dart';

import 'crop_types.dart';

enum TileState { grass, soil, watered, planted, grown }

final class _FarmTileConfig {
  _FarmTileConfig._();

  static const String _kGrassSpriteAsset =
      'gameplay/terrain/farmable/tile_grass.png';
  static const String _kSoilSpriteAsset =
      'gameplay/terrain/farmable/tile_soil.png';
  static const String _kWateredSpriteAsset =
      'gameplay/terrain/farmable/tile_watered.png';
  static const String _kPlantedSpriteAsset =
      'gameplay/terrain/farmable/tile_planted.png';
  static const String _kGrownSpriteAsset =
      'gameplay/terrain/farmable/parsnip_stage4.png';

  static final Vector2 _fComponentSize = GameplayTileConfig.fTileSizeStandard;
  static Future<Sprite> _loadSprite(String path) => Sprite.load(path);
}

class FarmTileView extends DDGameDecoration {
  TileState state = TileState.grass;
  CropType? plantedCrop;
  int daysGrowing = 0;
  bool isWatered = false;
  String currentSprite = _FarmTileConfig._kGrassSpriteAsset;

  FarmTileView(Vector2 position)
    : super.withSprite(
        sprite: _FarmTileConfig._loadSprite(_FarmTileConfig._kGrassSpriteAsset),
        position: position,
        size: _FarmTileConfig._fComponentSize,
      );

  @override
  int get priority => 20;

  void interact(FarmTool tool) {
    switch (tool) {
      case FarmTool.hoe:
        if (state == TileState.grass) {
          state = TileState.soil;
          currentSprite = _FarmTileConfig._kSoilSpriteAsset;
          _updateSprite();
        }
        break;
      case FarmTool.wateringCan:
        if (state == TileState.soil) {
          state = TileState.watered;
          isWatered = true;
          currentSprite = _FarmTileConfig._kWateredSpriteAsset;
          _updateSprite();
        }
        break;
      case FarmTool.hand:
        if (state == TileState.grown) {
          state = TileState.soil;
          plantedCrop = null;
          daysGrowing = 0;
          isWatered = false;
          currentSprite = _FarmTileConfig._kSoilSpriteAsset;
          _updateSprite();
        }
        break;
    }
  }

  Future<void> _updateSprite() async {
    sprite = await _FarmTileConfig._loadSprite(currentSprite);
  }

  bool plantSeed(CropType crop) {
    if (state == TileState.soil && plantedCrop == null) {
      state = TileState.planted;
      plantedCrop = crop;
      daysGrowing = 0;
      currentSprite = _FarmTileConfig._kPlantedSpriteAsset;
      _updateSprite();
      return true;
    }
    return false;
  }

  void processDay() {
    if (state == TileState.planted && isWatered && plantedCrop != null) {
      daysGrowing++;
      if (daysGrowing >= cropDatabase[plantedCrop]!.daysToGrow) {
        state = TileState.grown;
        currentSprite = _FarmTileConfig._kGrownSpriteAsset;
        _updateSprite();
      }
      isWatered = false;
    }
  }

  void reset() {
    state = TileState.grass;
    plantedCrop = null;
    daysGrowing = 0;
    isWatered = false;
    currentSprite = _FarmTileConfig._kGrassSpriteAsset;
    _updateSprite();
  }
}
