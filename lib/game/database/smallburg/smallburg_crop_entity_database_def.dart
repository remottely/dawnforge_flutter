import 'package:dawnforge/game/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';

import '../../features/world/entities/objects/farm/crop_entity.dart';
import '../../features/world/entities/objects/farm/crop_regrow_data.dart';
import '../../features/world/entities/objects/farm/crop_stage_type.dart';

const radishSpriteRowIndex = 2;
const strawberrySpriteRowIndex = 22;
const tomatoSpriteRowIndex = 24;
const appleSpriteRowIndex = 27;

final class SmallBurgCropEntityDatabaseDef {
  SmallBurgCropEntityDatabaseDef._();

  static const Map<HandItemId, CropEntity> cropEntityList = {
    HandItemId.radish: CropEntity(
      isTree: false,
      id: HandItemId.radish,
      name: 'Radish',
      description: 'A nutritious root vegetable',
      stage: CropStageType.planted,
      daysPlanted: 0,
      daysToMature: 5,
      yieldAmount: 5,
      harvestItemId: HandItemId.radish_loot_item,
      requiredSeason: SeasonType.any,
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 32,
      spriteRowIndex: radishSpriteRowIndex,
      framesCount: 5,
      skipFirstFrames: 0,
      ySortingFromStage: CropStageType.budding,
      ySortingOffset: -4.0,
    ),
    HandItemId.strawberry: CropEntity(
      isTree: false,
      regrowData: CropRegrowData(
        isRegrow: true,
        regrowStageRollback: 2,
        regrowStepDays: 2,
        isRegrowing: false,
        daysInStage: 0,
      ),
      id: HandItemId.strawberry,
      name: 'Strawberry',
      description: 'A nutritious root vegetable',
      stage: CropStageType.planted,
      daysPlanted: 0,
      daysToMature: 5,
      yieldAmount: 5,
      harvestItemId: HandItemId.strawberry_loot_item,
      requiredSeason: SeasonType.any,
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 32,
      spriteRowIndex: strawberrySpriteRowIndex,
      framesCount: 5,
      skipFirstFrames: 0,
      ySortingFromStage: CropStageType.budding,
      ySortingOffset: -4.0,
    ),
    HandItemId.tomato: CropEntity(
      isTree: false,
      id: HandItemId.tomato,
      name: 'Tomato',
      description: 'Juicy red fruit, perfect for salads',
      stage: CropStageType.seedling,
      daysPlanted: 0,
      daysToMature: 5,
      yieldAmount: 5,
      harvestItemId: HandItemId.tomato_loot_item,
      requiredSeason: SeasonType.summer,
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 32,
      spriteRowIndex: tomatoSpriteRowIndex,
      framesCount: 5,
      skipFirstFrames: 0,
      ySortingFromStage: CropStageType.seedling,
      ySortingOffset: -4.0,
    ),
    HandItemId.apple: CropEntity(
      isTree: true,
      regrowData: CropRegrowData(
        isRegrow: true,
        regrowStageRollback: 2,
        regrowStepDays: 2,
        isRegrowing: false,
        daysInStage: 0,
      ),
      id: HandItemId.apple,
      name: 'Apple',
      description: 'Crisp red apple',
      stage: CropStageType.seedling,
      daysPlanted: 0,
      daysToMature: 7,
      yieldAmount: 4,
      harvestItemId: HandItemId.apple_loot_item,
      requiredSeason: SeasonType.any,
      spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
      spriteWidth: 16,
      spriteHeight: 32,
      spriteRowIndex: appleSpriteRowIndex,
      framesCount: 7,
      skipFirstFrames: 0,
      ySortingFromStage: CropStageType.planted,
      ySortingOffset: -4.0,
    ),
  };
}
