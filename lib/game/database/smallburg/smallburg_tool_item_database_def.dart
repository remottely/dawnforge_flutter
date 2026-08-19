import 'package:dawnforge/game/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/tool_type.dart';
import 'package:dawnforge/game/features/inventory/items/tool_item.dart';

final class SmallBurgToolItemDatabaseDef {
  SmallBurgToolItemDatabaseDef._();
  static const Map<HandItemId, ToolItem> toolItemList = {
    HandItemId.harvestBasket: ToolItem(
      id: HandItemId.harvestBasket,
      name: 'Harvest Basket',
      description: 'Increase carrying efficiency when harvesting',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: ToolType.harvest,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 154,
        spriteColumnIndex: 6,
      ),
    ),
    HandItemId.shovel: ToolItem(
      id: HandItemId.shovel,
      name: 'Shovel',
      description: 'Used to dig and move soil',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: ToolType.shovel,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 154,
        spriteColumnIndex: 3,
      ),
    ),
    HandItemId.wateringCan: ToolItem(
      id: HandItemId.wateringCan,
      name: 'Watering Can',
      description: 'Waters soil to help crops grow',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: ToolType.watering_can,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 154,
        spriteColumnIndex: 10,
      ),
    ),
  };
}
