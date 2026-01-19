import 'package:dawnforge/game/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';

final class SmallBurgSoilStateSpriteDatabaseDef {
  SmallBurgSoilStateSpriteDatabaseDef._();

  static const Map<String, ItemIconData> soilStateSpriteList = {
    'untilled': ItemIconData(
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 109,
      spriteColumnIndex: 7,
    ),
    'tilled': ItemIconData(
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 104,
      spriteColumnIndex: 14,
    ),
    'watered': ItemIconData(
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 104,
      spriteColumnIndex: 15,
    ),
    'fertilized': ItemIconData(
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 16,
      spriteRowIndex: 2,
      spriteColumnIndex: 3,
    ),
  };
}
