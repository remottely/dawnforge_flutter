import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_type.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/inventory/entities/hand_item.dart';
import 'package:dawnforge/game/features/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/game/features/time/day_state.dart';
import 'package:dawnforge/game/features/time/weather_type.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';

/// Builders de dados de teste.
///
/// `CropEntity` tem 19 campos obrigatórios; literais inline destroem a
/// legibilidade do teste. Cada builder aplica defaults sensatos e expõe só o
/// que o teste precisa variar.

// ---------------------------------------------------------------------------
// Farm / world
// ---------------------------------------------------------------------------

/// Ícone genérico — nenhum teste de domínio depende de sprite.
const ItemIconData kTestIcon = ItemIconData(
  spritesheetPath: 'test/atlas.png',
  spriteWidth: 16,
  spriteHeight: 16,
  spriteRowIndex: 0,
  spriteColumnIndex: 0,
);

const CropRegrowData kNoRegrow = CropRegrowData(
  isRegrow: false,
  regrowStageRollback: 0,
  regrowStepDays: 0,
  isRegrowing: false,
  daysInStage: 0,
);

/// Crop de teste.
///
/// Default `daysToMature: 6` porque o passo de estágio é
/// `ceil(daysToMature / 6)` (6 = índice de `harvestable`) — com 6 dias dá
/// exatamente **1 dia por estágio**, o que torna a progressão trivial de
/// raciocinar nos testes.
CropEntity aCrop({
  HandItemId id = HandItemId.radish,
  String name = 'Radish',
  CropStageType stage = CropStageType.planted,
  int daysPlanted = 0,
  int daysToMature = 6,
  int yieldAmount = 1,
  HandItemId? harvestItemId,
  SeasonType requiredSeason = SeasonType.any,
  CropStageType? ySortingFromStage,
  bool isTree = false,
  CropRegrowData regrowData = kNoRegrow,
}) {
  return CropEntity(
    id: id,
    name: name,
    description: 'test crop',
    stage: stage,
    daysPlanted: daysPlanted,
    daysToMature: daysToMature,
    yieldAmount: yieldAmount,
    harvestItemId: harvestItemId ?? HandItemId.radish_loot_item,
    requiredSeason: requiredSeason,
    spritesheetPath: 'test/atlas.png',
    spriteWidth: 16,
    spriteHeight: 32,
    spriteRowIndex: 0,
    framesCount: 5,
    skipFirstFrames: 0,
    ySortingFromStage: ySortingFromStage,
    ySortingOffset: 0,
    isTree: isTree,
    regrowData: regrowData,
  );
}

/// Crop que rebrota após a colheita.
CropEntity aRegrowingCrop({
  CropStageType stage = CropStageType.harvestable,
  int daysToMature = 6,
  int regrowStageRollback = 2,
  int regrowStepDays = 2,
  bool isRegrowing = false,
  int daysInStage = 0,
}) {
  return aCrop(
    id: HandItemId.strawberry,
    name: 'Strawberry',
    stage: stage,
    daysToMature: daysToMature,
    harvestItemId: HandItemId.strawberry_loot_item,
    regrowData: CropRegrowData(
      isRegrow: true,
      regrowStageRollback: regrowStageRollback,
      regrowStepDays: regrowStepDays,
      isRegrowing: isRegrowing,
      daysInStage: daysInStage,
    ),
  );
}

/// Árvore — cresce sem depender de rega e planta em solo `untilled`.
CropEntity aTree({
  CropStageType stage = CropStageType.planted,
  int daysToMature = 14,
}) {
  return aCrop(
    id: HandItemId.apple,
    name: 'Apple Tree',
    stage: stage,
    daysToMature: daysToMature,
    harvestItemId: HandItemId.apple_loot_item,
    isTree: true,
  );
}

FarmObject aFarmObject({
  String objectId = 'farm_0_0',
  SoilState soilState = SoilState.untilled,
  CropEntity? crop,
  int? lastWateredDay,
}) {
  return FarmObject(
    objectId: objectId,
    soilState: soilState,
    crop: crop,
    lastWateredDay: lastWateredDay,
  );
}

/// `GridTile` já contendo um `FarmObject`.
GridTile aFarmTile({
  int x = 0,
  int y = 0,
  SoilState soilState = SoilState.untilled,
  CropEntity? crop,
  int? lastWateredDay,
  Map<String, dynamic>? metadata,
}) {
  return GridTile(
    x: x,
    y: y,
    object: aFarmObject(
      objectId: 'farm_${x}_$y',
      soilState: soilState,
      crop: crop,
      lastWateredDay: lastWateredDay,
    ),
    metadata: metadata,
  );
}

// ---------------------------------------------------------------------------
// Inventory
// ---------------------------------------------------------------------------

/// Item genérico. `maxStackSize > 1` o torna empilhável.
HandItem anItem({
  HandItemId id = HandItemId.wood,
  String name = 'Wood',
  HandItemType type = HandItemType.material,
  HandItemQuality quality = HandItemQuality.normal,
  int baseValue = 10,
  int maxStackSize = 99,
  bool isTradeable = true,
}) {
  return HandItem(
    id: id,
    name: name,
    description: 'test item',
    type: type,
    quality: quality,
    baseValue: baseValue,
    maxStackSize: maxStackSize,
    isTradeable: isTradeable,
    iconData: kTestIcon,
  );
}

/// Item não-empilhável (ferramentas e armas usam `maxStackSize: 1`).
HandItem aNonStackableItem({
  HandItemId id = HandItemId.shovel,
  String name = 'Shovel',
}) {
  return anItem(id: id, name: name, type: HandItemType.tool, maxStackSize: 1);
}

InventorySlot aSlot({int index = 0, HandItem? item, int quantity = 0}) {
  return InventorySlot(index: index, item: item, quantity: quantity);
}

// ---------------------------------------------------------------------------
// Time
// ---------------------------------------------------------------------------

DayState aDayState({
  int dayNumber = 1,
  SeasonType requiredSeason = SeasonType.spring,
  WeatherType weather = WeatherType.sunny,
  int weekdayIndex = 0,
  bool isFestival = false,
  String? festivalId,
}) {
  return DayState(
    dayNumber: dayNumber,
    requiredSeason: requiredSeason,
    weather: weather,
    weekdayIndex: weekdayIndex,
    isFestival: isFestival,
    festivalId: festivalId,
  );
}

/// Gerador de clima determinístico — `DayState.defaultWeatherRng` usa `Random()`
/// global e tornaria qualquer teste de calendário instável.
WeatherType Function(SeasonType, int) fixedWeather([
  WeatherType weather = WeatherType.sunny,
]) {
  return (_, _) => weather;
}
