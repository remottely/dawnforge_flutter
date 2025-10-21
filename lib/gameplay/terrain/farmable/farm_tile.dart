import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

import 'crop_types.dart';

enum TileState { grass, soil, watered, planted, grown }

abstract class _FarmTileData {
  static const String grassSprite = 'gameplay/terrain/farmable/tile_grass.png';
  static const String spriteSoil = 'gameplay/terrain/farmable/tile_soil.png';
  static const String spriteWatered =
      'gameplay/terrain/farmable/tile_watered.png';
  static const String spritePlanted =
      'gameplay/terrain/farmable/tile_planted.png';
  static const String spriteGrown =
      'gameplay/terrain/farmable/parsnip_stage4.png';
  static Vector2 get _spriteSize => GameplayConstants.kTileVector2Standard;
  static Future<Sprite> _loadSprite(String path) => Sprite.load(path);
}

class FarmTile extends DFGameDecoration {
  TileState state = TileState.grass;
  CropType? plantedCrop;
  int daysGrowing = 0;
  bool isWatered = false;
  String currentSprite = _FarmTileData.grassSprite;

  FarmTile(Vector2 position)
    : super.withSprite(
        sprite: _FarmTileData._loadSprite(_FarmTileData.grassSprite),
        position: position,
        size: _FarmTileData._spriteSize,
      );

  @override
  int get priority => 100;

  void interact(FarmTool tool) {
    switch (tool) {
      case FarmTool.hoe:
        if (state == TileState.grass) {
          state = TileState.soil;
          currentSprite = _FarmTileData.spriteSoil;
          _updateSprite();
        }
        break;
      case FarmTool.wateringCan:
        if (state == TileState.soil) {
          state = TileState.watered;
          isWatered = true;
          currentSprite = _FarmTileData.spriteWatered;
          _updateSprite();
        }
        break;
      case FarmTool.hand:
        if (state == TileState.grown) {
          state = TileState.soil;
          plantedCrop = null;
          daysGrowing = 0;
          isWatered = false;
          currentSprite = _FarmTileData.spriteSoil;
          _updateSprite();
        }
        break;
    }
    // TODO: Trigger visual feedback/animation
  }

  Future<void> _updateSprite() async {
    sprite = await _FarmTileData._loadSprite(currentSprite);
  }

  bool plantSeed(CropType crop) {
    if (state == TileState.soil && plantedCrop == null) {
      state = TileState.planted;
      plantedCrop = crop;
      daysGrowing = 0;
      currentSprite = _FarmTileData.spritePlanted;
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
        currentSprite = _FarmTileData.spriteGrown;
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
    currentSprite = _FarmTileData.grassSprite;
    _updateSprite();
  }
}
