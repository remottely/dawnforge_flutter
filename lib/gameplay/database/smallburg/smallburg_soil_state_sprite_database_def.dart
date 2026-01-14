import 'package:dawnforge/gameplay/inventory/entities/data/item_icon_data.dart';

final class SmallBurgSoilStateSpriteDatabaseDef {
  SmallBurgSoilStateSpriteDatabaseDef._();

  static const Map<String, ItemIconData> soilStateSpriteList = {
    'untilled': ItemIconData(
      spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 109,
      spriteColumnIndex: 7,
    ),
    'tilled': ItemIconData(
      spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 104,
      spriteColumnIndex: 14,
    ),
    'watered': ItemIconData(
      spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 104,
      spriteColumnIndex: 15,
    ),
    'fertilized': ItemIconData(
      spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 2,
      spriteColumnIndex: 3,
    ),
  };
}
