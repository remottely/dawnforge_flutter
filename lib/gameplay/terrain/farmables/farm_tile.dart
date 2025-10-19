import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

import '../../characters/player/knight_character.dart';
import 'crop_types.dart';

enum TileState { grass, soil, watered, planted, grown }

class FarmTile extends DFGameDecoration {
  TileState state = TileState.grass;
  CropType? plantedCrop;
  int daysGrowing = 0;
  bool isWatered = false;

  String currentSprite = 'farm/tile_grass.png';

  FarmTile(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('farm/tile_watered.png'),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize,
          GameplayConstants.kCurrentTileSize,
        ),
      );

  @override
  int get priority => 100;

  void interact(FarmTool tool) {
    switch (tool) {
      case FarmTool.hoe:
        if (state == TileState.grass) {
          state = TileState.soil;
          currentSprite = 'farm/tile_soil.png';
          _updateSprite();
        }
        break;
      case FarmTool.wateringCan:
        if (state == TileState.soil) {
          state = TileState.watered;
          isWatered = true;
          currentSprite = 'farm/tile_watered.png';
          _updateSprite();
        }
        break;
      case FarmTool.hand:
        if (state == TileState.grown) {
          // Harvest crop
          state = TileState.soil;
          plantedCrop = null;
          daysGrowing = 0;
          isWatered = false;
          currentSprite = 'farm/tile_soil.png';
          _updateSprite();
        }
        break;
    }
    // TODO: Trigger visual feedback/animation
  }

  Future<void> _updateSprite() async {
    sprite = await Sprite.load(currentSprite);
  }

  // Plantar uma seed (ex: parsnip)
  bool plantSeed(CropType crop) {
    if (state == TileState.soil && plantedCrop == null) {
      state = TileState.planted;
      plantedCrop = crop;
      daysGrowing = 0;
      currentSprite = 'farm/tile_planted.png';
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
        currentSprite = 'farm/parsnip_stage4.png';
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
    currentSprite = 'farm/tile_grass.png';
    _updateSprite();
  }
}
